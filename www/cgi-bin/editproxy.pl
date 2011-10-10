#!/usr/bin/perl -w

use strict;
use DBI;
use CGI;

my $sitename="http://telephone.local";
my $db_password="kjgfcnb";
my $db_user="cdr";
my $dsn="DBI:mysql:telephone:localhost";
my $dbh=DBI->connect($dsn,$db_user,$db_password);
my $q=new CGI;

sub form {
    my $id='';
    my $pname='';
    my $pstring='';
    my $pcost='';
    my $punit='';
    my $act=$_[0];
    $id=$_[5];
    $pname=$_[1];
    $pstring=$_[2];
    $pcost=$_[3];
    $punit=$_[4];
    print "<form action \"editproxy.pl\" method=\"post\">";
    print "<table cellspasing=0 border=0>";
    print "<tr><td>Имя шлюза</td><td><input type=\"text\" name=\"pname\" value=\"$pname\"></td></tr>";
    print "<tr><td>Идентификатор шлюза</td><td><input type=\"text\" name=\"pstring\" value=\"$pstring\"></td></tr>";
    print "<tr><td>Стоимость</td><td><input type=\"text\" name=\"pcost\" value=\"$pcost\"></td></tr>";
    print "<tr><td>Тип тарификации</td><td>";
    print "<select name=\"punit\">";
    if($punit==60)
    {
	print "<option value=\"1\">Посекундная</option>";
	print "<option value=\"60\" selected>Поминутная</option>";
    }
    else
    {
	print "<option value=\"1\">Посекундная</option>";
	print "<option value=\"60\">Поминутная</option>";
    }
    my $subact;
    
    if($act eq 'add')
    {
	$subact='add';
    }
    else
    {
	$subact='update';
    }
    print "<input type=\"hidden\" name=\"subact\" value=\"$subact\">";
    print "</select><input type=\"hidden\" name=\"id\" value=\"$id\"><input type=\"hidden\" name=\"act\" value=\"submit\" >";
    print "</td></tr>";
    print "<tr><td colspan=2><input type=\"submit\" value=\"Ок\"></td></tr>";
    print "</table>";


    print "</form>";

    if($act eq 'edit')
    {
	print "<form action=\"editproxy.pl\" method=\"post\">";
	print "<input type=\"hidden\" name=\"id\" value=\"$id\"><input type=\"hidden\" name=\"act\" value=\"delete\"><input type=\"submit\" value=\"Удалить\">";
	print "</form>";

    }
    print "<a href=\"".$sitename."/cgi-bin/editproxy.pl\">Вернуться назад</a>";
}

print $q->header(-charset=>'utf-8');
print $q->start_html(-title=>'редактирование списка шлюзов');
my $act=$q->param('act');
if($act eq 'add')
{
#   Добавление шлюза
    &form('add');
}
if($act eq 'submit')
{
    my $pname=$q->param('pname');
    my $pstring=$q->param('pstring');
    my $pcost=$q->param('pcost');
    my $punit=$q->param('punit');
    my $id=$q->param('id');
    my $subact=$q->param('subact');
    my $mess;
    my $sth;
    print "Изменение/добавление записи:<br>";
    if($subact eq 'add')
    {
	$sth=$dbh->prepare("insert into proxylist (proxyname,proxystring,cost,unit) values ('$pname','$pstring',$pcost,$punit)");
	$mess="Добавлено";
    }
    else
    {
	$sth=$dbh->prepare("update proxylist set proxyname='$pname',proxystring='$pstring',cost=$pcost,unit=$punit where id=$id");
	$mess="Изменено";
    }
    $sth->execute() or die $DBI::errstr;
    print $mess."<br>";
    print "<a href=\"".$sitename."/cgi-bin/editproxy.pl\">Вернуться</a>";
    $sth->finish();
}
if($act eq 'edit')
{
#   Редактирование шлюза
    my $id=$q->param('id');
    my $sth=$dbh->prepare("select proxyname,proxystring,cost,unit from proxylist where id=$id");
    $sth->execute() or die $DBI::errstr;
    my ($pname,$pstring,$pcost,$punit)=$sth->fetchrow_array();
    &form('edit',$pname,$pstring,$pcost,$punit,$id);
}
if($act eq 'delete')
{
#   Удаление шлюза
    my $id=$q->param('id');
    my $sth=$dbh->prepare("delete from proxylist where id=$id");
    $sth->execute() or die $DBI::errstr;
    $sth->finish();
    print "Запись удалена<br>";
    print "<a href=\"".$sitename."/cgi-bin/editproxy.pl\">Вернуться</a>";
}
if ($act eq '')
{
#   Вывод по умолчанию
    print "<table cellspacing=0 border=1>";
    print "<tr><td>Название шлюза</td><td>Идентификатор шлюза</td><td>Стоимость минуты</td><td>Тип тарификации</td><td>Действие</td></tr>";
    my $sth=$dbh->prepare("select id,proxyname,proxystring,cost,unit from proxylist");
    $sth->execute() or die $DBI::errstr;
    while(my ($id,$pname,$pstring,$pcost,$punit)=$sth->fetchrow_array())
    {
	print "<tr><td>$pname</td><td>$pstring</td><td>$pcost</td><td>";
	if($punit==60)
	{
	    print "поминутная";
	}
	if($punit==1)
	{
	    print "посекундная";
	}
	print "</td><td><a href=\"".$sitename."/cgi-bin/editproxy.pl?act=edit&id=$id\">Изменить</a>";
	print "</td></tr>";
    }
    print "</table>";
    print "<a href=\"".$sitename."/cgi-bin/editproxy.pl?act=add\">Добавить шлюз</a><br>";
    print "<a href=\"".$sitename."/\">Главная</a>";
    $sth->finish();
}


print $q->end_html();

