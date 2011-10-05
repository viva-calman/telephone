#!/usr/bin/perl -w

use strict;
use LWP;
use HTTP::Request::Common;
use DBI;

my $db_password="kjgfcnb";
my $db_user="cdr";
my $dsn="DBI:mysql:telephone:localhost";
my $dbh=DBI->connect($dsn,$db_user,$db_password);


my $ua = LWP::UserAgent->new();
$ua->agent("PerlUA/0.1");
my $output="cdr.csv";
open (FILE,">$output");
my $url = "http://192.168.200.17/cgi-bin/webctrl.cgi";
my $request = POST $url, [action => 'cdr_download'];
my $document = $ua->request($request);
if ($document->is_success)
{
	    print FILE $document->content;
}
else
{
	  print "Content-Type: text/html\n\n";
	    print "Couldn't post to $url\n";
}
close (FILE);

my $spool=`./parce.sh`;
open (PARCE,"<cdr.parce");
my $sth;
my $queue;
my ($source,$destination,$start,$answer,$end,$duration,$status);
while (<PARCE>)
{
	$queue=$_;
	$queue=~s/\"/\'/g;
#	$queue=~s///;
	($source,$destination,$start,$answer,$end,$duration,$status)=split(",",$queue);
	$status=~s/\n//;
	if($status eq '\'ANSWERED\'')
	{
		$status=1;
	}
	if($status eq '\'NO ANSWER\'')
	{
		$status=2;
	}
	$queue=$source.",".$destination.",".$start.",".$answer.",".$end.",".$duration.",".$status;
	$sth=$dbh->prepare("insert into calls (source,destination,start,answer,end,duration,status) values ($queue)");
	$sth->execute() or die $DBI::errstr;
	$sth->finish();
}
close (PARCE);

