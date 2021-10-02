#! /bin/bash

set -x

mkdir website
cd website

# grab the vmdk file image for all inputs
mkdir INPUTS
wget --no-check-certificate --progress=dot:mega http://mcc.lip6.fr/archives/mcc2021-input.vmdk.tar.bz2
tar xvjf mcc2021-input.vmdk.tar.bz2
../7z e mcc2021-input.vmdk
../ext2rd 0.img ./:INPUTS
rm -f *.vmdk 0.img *.bz2 1

if [ ! -f raw-result-analysis.csv ] 
then
	# grab the raw results file from MCC website
	wget --no-check-certificate --progress=dot:mega https://mcc.lip6.fr/archives/raw-result-analysis.csv.zip
	unzip raw-result-analysis.csv.zip
fi

# create oracle files
mkdir oracle
mkdir poracle
# all results available
cat raw-result-analysis.csv | grep -v StateSpace | cut -d ',' -f2,3,16 | grep -v "?" | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl
mv *.out oracle/
 
#rm -f raw-result-analysis.csv*

cd oracle
tar xvzf ../../oracleSS.tar.gz
cd ..
tar cvzf oracle.tar.gz  oracle/
rm -rf oracle/

# partial oracles may contain '?'
cat raw-result-analysis.csv | grep -v StateSpace | cut -d ',' -f2,3,16 | grep "?" | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl


mv *.out poracle/

tar cvzf poracle.tar.gz  poracle/
rm -rf poracle/

tree -H "." > index.html

cd ..
