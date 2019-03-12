#! /usr/bin/perl


my @index = ("00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15");

while (my $line = <STDIN>) {
    # print $line;
    chomp $line;
  my @fields = split /,/, $line;
  my $prefix = @fields[0]."-".@fields[1];
  my @verdicts = split //, @fields[2];

   # print "Verdicts ($#verdicts) = @verdicts \n";
  if ($#verdicts != 15 && $#verdicts != 0) {
    @verdicts = split / /, @fields[2];
    if ($#verdicts != 15) {
	    next;
	}
  }
  my $abbrev = @fields[1];
  $abbrev =~ s/[a-z]//g;
  my $outff = @fields[0]."-".$abbrev.".out";

  if (-f $outff) {
      print "Not overwriting existing oracle file $outff\n";
  } else {
      print "doing $prefix, in file $outff has ".($#verdicts)." entries \n";  
      open OUT, "> $outff";
      print OUT "./runatest.sh ".@fields[0]." ".@fields[1] ."\n";
      for (my $i=0 ; $i <= $#verdicts ; $i++) {
	  my $res = @verdicts[$i];   
	  $res =~ s/F/FALSE/g;
	  $res =~ s/T/TRUE/g;
	  print OUT "FORMULA ".$prefix."-".@index[$i]." ".$res." TECHNIQUES ORACLE2018\n";
      }
      close OUT;
  }
}

# for COL formula names in PT models, it might be necassary to run this in sh.
# for j in `(for i in *COL*.out ; do echo $i | sed 's/-.*\.out//'  ; done) | uniq ` ; do for k in $j*PT*.out ; do cat $k | sed -re 's/(FORMULA.*)PT(.*)/\1COL\2/g' > $k.bak ; \mv $k.bak $k  ; done ; done 
