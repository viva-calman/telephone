#!/usr/bin/perl -w

use strict;
use DBI;
use CGI;

my $db_password="kjgfcnb";
my $db_user="cdr";
my $dsn="DBI:mysql:telephone:localhost";
my $dbh=DBI->connect($dsn,$db_user,$db_password);

my $q=new CGI;

print $q->header(-charset=>'utf-8');
print $q->start_html(-title=>'Full list');
print "<table cellspacing=0 border=1>";
print "<tr><td>Источник</td><td>Приемник</td><td>Время начала</td><td>Время ответа</td><td>Время окончания</td><td>Продолжительность</td><td>Статус</td></tr>";
my $sth=$dbh->prepare("select calls.source,calls.destination,calls.start,calls.answer,calls.end,calls.duration,status.status from calls,status where calls.status=status.id");
$sth->execute() or die $DBI::errstr;
while(my($source,$destination,$start,$answer,$end,$duration,$status)=$sth->fetchrow_array())
{
    print "<tr><td>$source</td><td>$destination</td><td>$start</td><td>$answer</td><td>$end</td><td>$duration</td><td>$status</td></tr>";
}
print "</table>";
print $q->end_html();
$sth->finish();
