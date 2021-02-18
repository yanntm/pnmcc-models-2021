#! /usr/bin/perl


my @index = ("00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15");

while (my $line = <STDIN>) {
    # print $line;
    chomp $line;
  my @fields = split /,/, $line;
  my $modelname = @fields[0];
  
  my $examination = @fields[1];
  my $prefix = $modelname."-".@fields[1];
 # so does this one
 $prefix =~ s/HouseConstruction-PT-00020/HouseConstruction-PT-0020/;

  if ($examination =~ /LTL.*/) {
  	# in 2020 no examination in these formulas
  	$prefix = $modelname ;
  }

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
  
  my $outff = $modelname."-".$abbrev.".out";

  if (-f $outff) {
      print "Not overwriting existing oracle file $outff\n";
  } else {
      print "doing $prefix, in file $outff has ".($#verdicts + 1)." entries \n";  
      open OUT, "> $outff";
      print OUT @fields[0]." ".@fields[1] ."\n";
      for (my $i=0 ; $i <= $#verdicts ; $i++) {
		  my $res = @verdicts[$i];   
		  $res =~ s/F/FALSE/g;
		  $res =~ s/T/TRUE/g;
		  if ($#verdicts != 0) {
		  	  # ordianry formulas
			  print OUT "FORMULA ".$prefix."-".@index[$i]." ".$res." TECHNIQUES ORACLE2020\n";
		  } else {
		  	# GlobalProperties cases : formula name is simply examination
		  	print OUT "FORMULA ".$examination." ".$res." TECHNIQUES ORACLE2020\n";
		  }
      }
      close OUT;
  }
}

# for COL formula names in PT models, it might be necassary to run this in sh.
# for j in `(for i in *COL*.out ; do echo $i | sed 's/-.*\.out//'  ; done) | uniq ` ; do for k in $j*PT*.out ; do cat $k | sed -re 's/(FORMULA.*)PT(.*)/\1COL\2/g' > $k.bak ; \mv $k.bak $k  ; done ; done 
