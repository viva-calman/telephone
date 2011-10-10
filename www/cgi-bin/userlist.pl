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

print $q->header(-charset=>'utf-8');
print $q->start_html(-title=>'User list');

print "<table cellspacing=0 border=1>";
print "<tr><td>Номер</td><td>Владелец</td><td>Отдел</td><td>Описание</td><td>Действие</td></tr>";

my $sth=$dbh->prepare("select distinct calls.source,userlist.name,districtlist.name,userlist.description from userlist right join calls on calls.source=userlist.number left join districtlist on userlist.district=districtlist.id order by calls.source");
$sth->execute() or die $DBI::errstr;
while(my($source,$name,$district,$desc)=$sth->fetchrow_array())
{
	print "<tr><td>$source</td><td>$name</td><td>$district</dt><td>$desc</td><td><a href=\"".$sitename."/cgi-bin/userstat.pl?source=$source\">Статистика</a></td></tr>";
}
$sth->finish();

print "</table>";
print "<a href=\"".$sitename."/\">Главная</a>";
print $q->end_html();

