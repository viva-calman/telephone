#!/usr/bin/perl -w

use strict;
use DBI;
use CGI;

my $sitename="http://telephone.local";
my $db_password="kjgfcnb";
my $db_user="cdr";
my $dsn="DBI:mysql:telephone:localhost";
my $dbh=DBI->connect($dsn,$db_user,$db_password);
my $interval=5;

my $q=new CGI;

print $q->header(-charset=>'utf-8');
print $q->start_html(-title=>'User stats');
my $month=0;
my $user=$q->param('source');
$month=$q->param('month');
my ($lsec,$lmin,$lhour,$lday,$lmonth,$lyear)=localtime();
my $prevdate=($lyear+1900)."-".($lmonth+1)."-".($lday)." ".$lhour.":".$lmin.":".$lsec;
#print $prevdate;
my $sth=$dbh->prepare("select userlist.number,userlist.name,districtlist.name,userlist.description from userlist,districtlist where number=$user and userlist.district=districtlist.id");
$sth->execute() or die $DBI::errstr;
my($number,$name,$district,$description)=$sth->fetchrow_array();
print "Статистика по номеру $number<br>Владелец: $name, Отдел: $district,$description";
print "<br>Полная статистика:<br>";
print "<br><table cellspacing=0 border=1>";
print "<tr><td>Номер</td><td>Время начала</td><td>Время ответа</td><td>Время окончания</td><td>Продолжительность</td><td>Статус</td></tr>";
my $dur;
if($month==0)
{
	$sth=$dbh->prepare("select sum(duration) from calls where source=$user");
	$dur="все время";
}
else
{
	$sth=$dbh->prepare("select sum(duration) from calls where source=$user and start>'$prevdate'-INTERVAL $interval  day");
	$dur="месяц";
}
$sth->execute() or die $DBI::errstr;
my $sum=$sth->fetchrow_array();
my($sec,$min,$hour)=gmtime($sum);
print "Общая продолжительность звонков за $dur: $hour ч. $min мин. $sec сек. ($sum сек.) <br>";
if($month==0)
{
	print "<a href=\"".$sitename."/cgi-bin/userstat.pl?month=1&source=$user\">Статистика за прошедший месяц</a>";
	$sth=$dbh->prepare("select calls.destination,userlist.name,calls.start,calls.answer,calls.end,calls.duration,status.status from userlist right join calls on userlist.number=calls.destination join status on status.id=calls.status where calls.source=$user order by calls.start");
}
else
{
	print "<a href=\"".$sitename."/cgi-bin/userstat.pl?source=$user\">Полная статистика</a>";
	$sth=$dbh->prepare("select calls.destination,userlist.name,calls.start,calls.answer,calls.end,calls.duration,status.status from userlist right join calls on userlist.number=calls.destination join status on status.id=calls.status where calls.source=$user and start>'$prevdate'-INTERVAL $interval day order by calls.start");

}
$sth->execute() or die $DBI::errstr;
while(my($destination,$username,$start,$answer,$end,$duration,$status)=$sth->fetchrow_array())
{
	($sec,$min,$hour)=gmtime($duration);
	print "<tr><td>($destination) $username</td><td>$start</td><td>$answer</td><td>$end</td><td>$hour:$min:$sec</td><td>$status</td></tr>";
}
print "</table>";
my %proxy;
my %proxyunit;
print "Тарифицируемые звонки:";
$sth=$dbh->prepare("select proxystring,cost,unit from proxylist");
$sth->execute() or die $DBI::errstr;
while(my ($pstring,$pcost,$unit)=$sth->fetchrow_array())
{
    $proxy{$pstring}=$pcost;
    $proxyunit{$pstring}=$unit;
}

print "<table border=1 cellspacing=0>";
print "<tr><td>Номер</td><td>Время начала</td><td>Время ответа</td><td>Время окончания</td><td>Продолжительность</td><td>Стоимость</td><td>Статус</td></tr>";
$sth=$dbh->prepare("select calls.destination,userlist.name,calls.start,calls.answer,calls.end,calls.duration,status.status from userlist right join calls on userlist.number=calls.destination join status on status.id=calls.status where calls.source=$user and destination like \"%@%\" order by calls.start");
$sth->execute() or die $DBI::errstr;
my ($pexit,$cost,$total,$unit,$t_meth);
while(my($destination,$username,$start,$answer,$end,$duration,$status)=$sth->fetchrow_array())
{
	$pexit=$destination;
	$pexit=~s/\d+@//;
	$cost=$proxy{$pexit};
	$unit=$proxyunit{$pexit};
	if($unit==1)
	{
		$total=sprintf("%.2f",($cost/60)*$duration);
		$t_meth="посекундно";
	}
	if($unit==60)
	{
		$total=sprintf("%.2f",$cost*($duration/60));
		$t_meth="поминутно";
	}
	($sec,$min,$hour)=gmtime($duration);
	if($status eq 'No answer')
	{
	    $total=0;
	}
	print "<tr><td>($destination) $username</td><td>$start</td><td>$answer</td><td>$end</td><td>$hour:$min:$sec</td><td>$total р. ($cost р./мин, $t_meth)</td><td>$status</td></tr>";
}
print "</table>";
print "<a href=\"".$sitename."/\">Главная</a>";


$sth->finish();
print $q->end_html();

