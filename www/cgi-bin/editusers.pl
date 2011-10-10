#!/usr/bin/perl -w

use strict;
use DBI;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $sitename="http://telephone.local";
my $db_password="kjgfcnb";
my $db_user="cdr";
my $dsn="DBI:mysql:telephone:localhost";
my $dbh=DBI->connect($dsn,$db_user,$db_password);

my $q=new CGI;

sub form {
    my $id='';
    my $name='';
    my $district='';
    my $desc='';
    my $number='';
    my $act=$_[0];
    $id=$_[5];
    $name=$_[1];
    $district=$_[2];
    $desc=$_[3];
    $number=$_[4];
    print "<form action \"editusers.pl\" method=\"post\">";
    print "<table cellspasing=0 border=0>";
    print "<tr><td>Номер</td><td><input type=\"text\" name=\"number\" value=\"$number\"></td></tr>";
    print "<tr><td>Имя пользователя</td><td><input type=\"text\" name=\"name\" value=\"$name\"></td></tr>";
    print "<tr><td>Отдел</td><td>";
    print "<select name=\"district\">";
    my $sth=$dbh->prepare("select id,name from districtlist order by name");
    $sth->execute() or die $DBI::errstr;
    my $selected='';
    while(my($did,$dname)=$sth->fetchrow_array())
    {
	if($district==$did)
	{
	    $selected='selected';
	}
	print "<option $selected value=\"$did\">$dname</option>"

    }
    print "</select>";
    
    my $subact;
    if($act eq 'add')
    {
	$subact='add';
    }
    else
    {
	$subact='update';
    }

    print "<tr><td>Описание</td><td><textarea name=\"desc\">$desc</textarea></td></tr>";
    print "<input type=\"hidden\" name=\"id\" value=\"$id\"><input type=\"hidden\" name=\"act\" value=\"submit\" >";
    print "</td></tr>";
    print "<input type=\"hidden\" name=\"subact\" value=\"$subact\">";
    print "<tr><td colspan=2><input type=\"submit\" value=\"Ок\"></td></tr>";
    print "</table>";


    print "</form>";

    if($act eq 'edit')
    {
	print "<form action=\"editusers.pl\" method=\"post\">";
	print "<input type=\"hidden\" name=\"id\" value=\"$id\"><input type=\"hidden\" name=\"act\" value=\"delete\"><input type=\"submit\" value=\"Удалить\">";
	print "</form>";

    }
    print "<a href=\"".$sitename."/cgi-bin/editusers.pl\">Вернуться назад</a>";
    $sth->finish();
}



print $q->header(-charset=>'utf-8');
print $q->start_html(-title=>'Список пользователей');
my $act=$q->param('act');
if($act eq 'add')
{
    &form('add');
}
if($act eq 'edit')
{
    my $id=$q->param('id');
    my $sth=$dbh->prepare("select number,name,district,description from userlist where id=$id");
    $sth->execute() or die $DBI::errstr;
    my($number,$name,$district,$desc)=$sth->fetchrow_array();
    &form('edit',$name,$district,$desc,$number,$id);
}
if($act eq 'submit')
{
    my $number=$q->param('number');
    my $name=$q->param('name');
    my $desc=$q->param('desc');
    my $district=$q->param('district');
    my $id=$q->param('id');
    my $subact=$q->param('subact');
    my $mess;
    my $sth;
    print "Изменение/добавление записи:<br>";
    if($subact eq 'add')
    {
	$sth=$dbh->prepare("insert into userlist (number,name,district,description) values ('$number','$name','$district','$desc')");
	$mess="Добавлено";
    }
    else
    {
	$sth=$dbh->prepare("update userlist set name='$name',number='$number',district='$district',description='$desc' where id=$id");
	$mess="Изменено";
    }
    $sth->execute() or die $DBI::errstr;
    print $mess."<br>";
    print "<a href=\"".$sitename."/cgi-bin/editusers.pl\">Вернуться</a>";
    $sth->finish();

}
if($act eq 'delete')
{
    my $id=$q->param('id');
    my $sth=$dbh->prepare("delete from userlist where id=$id");
    $sth->execute() or die $DBI::errstr;
    $sth->finish();
    print "Запись удалена<br>";
    print "<a href=\"".$sitename."/cgi-bin/editusers.pl\">Вернуться</a>";

}
if($act eq '')
{
    print "<table cellspacing=0 border=1>";
    print "<tr><td>Номер</td><td>Владелец</td><td>Отдел</td><td>Описание</td><td>Действие</td></tr>";
    my $sth=$dbh->prepare("select userlist.id,userlist.number,userlist.name,districtlist.name,userlist.description from userlist,districtlist where userlist.district=districtlist.id order by userlist.name");
    $sth->execute() or die $DBI::errstr;
    while(my($id,$number,$name,$district,$description)=$sth->fetchrow_array())
    {
	print "<tr><td>$number</td><td>$name</td><td>$district</td><td>$description</td><td>";
	print "<a href=\"".$sitename."/cgi-bin/editusers.pl?act=edit&id=$id\">Изменить</td></tr>";
    }
    print "</table>";
    print "<a href=\"".$sitename."/cgi-bin/editusers.pl?act=add\">Добавить</a><br>";
    print "<a href=\"".$sitename."/\">Главная</a>";
    $sth->finish();
}

print $q->end_html();


