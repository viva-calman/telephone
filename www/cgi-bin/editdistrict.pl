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
    my $district='';
    my $act=$_[0];
    $id=$_[2];
    $district=$_[1];
    print "<form action \"editdistrict.pl\" method=\"post\">";
    print "<table cellspasing=0 border=0>";
    print "<tr><td>Название отдела</td><td><input type=\"text\" name=\"district\" value=\"$district\"></td></tr>";
    my $subact;
    if($act eq 'add')
    {
	$subact='add';
    }
    else
    {
	$subact='update';
    }
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
    print "<a href=\"".$sitename."/cgi-bin/editdistrict.pl\">Вернуться назад</a>";
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
    my $sth=$dbh->prepare("select name from districtlist where id=$id");
    $sth->execute() or die $DBI::errstr;
    my($district)=$sth->fetchrow_array();
    &form('edit',$district,$id);
}
if($act eq 'submit')
{
    my $district=$q->param('district');
    my $id=$q->param('id');
    my $subact=$q->param('subact');
    my $mess;
    my $sth;
    print "Изменение/добавление записи:<br>";
    if($subact eq 'add')
    {
	$sth=$dbh->prepare("insert into districtlist (name) values ('$district')");
	$mess="Добавлено";
    }
    else
    {
	$sth=$dbh->prepare("update districtlist set name='$district' where id=$id");
	$mess="Изменено";
    }
    $sth->execute() or die $DBI::errstr;
    print $mess."<br>";
    print "<a href=\"".$sitename."/cgi-bin/editdistrict.pl\">Вернуться</a>";
    $sth->finish();

}
if($act eq 'delete')
{
    my $id=$q->param('id');
    my $sth=$dbh->prepare("delete from districtlist where id=$id");
    $sth->execute() or die $DBI::errstr;
    $sth->finish();
    print "Запись удалена<br>";
    print "<a href=\"".$sitename."/cgi-bin/editdistrict.pl\">Вернуться</a>";

}
if($act eq '')
{
    print "<table cellspacing=0 border=1>";
    print "<tr><td>Отдел</td><td>Действие</td></tr>";
    my $sth=$dbh->prepare("select id,name from districtlist order by districtlist.name");
    $sth->execute() or die $DBI::errstr;
    while(my($id,$name)=$sth->fetchrow_array())
    {
	print "<tr><td>$name</td><td>";
	print "<a href=\"".$sitename."/cgi-bin/editusers.pl?act=edit&id=$id\">Изменить</td></tr>";
    }
    print "</table>";
    print "<a href=\"".$sitename."/cgi-bin/editdistrict.pl?act=add\">Добавить</a>";
    print "<br><a href=\"".$sitename."/\">Главная</a>";  
    $sth->finish();
}

print $q->end_html();


