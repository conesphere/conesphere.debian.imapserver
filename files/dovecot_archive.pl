#!/bin/bash
/usr/bin/perl -x -I `dirname $0` $0 $*
exit $?
#!perl

# Call basedir box time
my $oneday=86400;
my $expire=time-(${oneday}*360*1);
my $base="/home/".getpwuid($<)."/Maildir"; 
my $archiv="history"; # this is somewhat fixed because we use that hardcoded later on 

if ( $ARGV[0] =~ /^\d+$/ ) {
	$expire=time-($oneday*$ARGV[0]) or die "time is not numeric\n";
}

opendir(DIR, $base) or die "cant open ${base}"; 

while (readdir DIR) {
	#print "got $_\n";
	if ( $_ =~ /^\.\./ ) { next; }
	if ( $_ =~ /^\.$/ ) {  next; }
	if ( $_ =~ /^\.history\..*/ ) {  next; }
	
	my $box=$_; 
	if ( $_ eq "cur" ) {
		# this is INBOX
		$box=".Inbox"; 
		if ( ! -d $base."/".$_ ) { 
			#print "$_ is no dir\n"; 
			next; 
		}
		chdir("$base/$_") or die "cant change to $box dir\n";
	} else {
		if ( ! -d $base."/".$_."/cur" ) { 
			#print "$_ is no dir\n"; 
			next; 
		}
		chdir("$base/$box/cur") or die "cant change to $box dir\n";
	}

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($expire);
	$year=$year+1900; 

	$target=$base."/.".$archiv.".".($year).$box;
	#print "creating $target \n";
	if ( ! -d $target ) {
		#print "creating $target \n";
		mkdir($target) or die "cant create archive year\n";
		mkdir($target."/cur") or die "cant create archive year target cur\n";
		mkdir($target."/tmp") or die "cant create archive year target tmp\n";
		mkdir($target."/new") or die "cant create archive year target new\n";
	}  


	foreach $file (glob("*")){
		$time=$file;
		$time=~s/\..*//g;
		if ($time <= $expire) {
			#print ("Archive Message $file \n");
			link($file, "$target/new/$file") or die "can't link file to backup \n"; 
			unlink ($file);
			#} else {
			#print "message $file isnt old enough\n"; 
		}
	}
}

