#! /bin/bash

set -x


mkdir website
cd website

# grab the vmdk file image for all inputs
mkdir INPUTS
wget --progress=dot:mega http://mcc.lip6.fr/archives/mcc2019-input.vmdk.tar.bz2
tar xvjf mcc2019-input.vmdk.tar.bz2
../7z e mcc2019-input.vmdk
../ext2rd 0.img ./:INPUTS
rm -f *

# create oracle files
mkdir oracle
wget --progress=dot:mega https://mcc.lip6.fr/archives/raw-result-analysis.csv.zip
unzip raw-result-analysis.csv.zip
cat raw-result-analysis.csv | cut -d ',' -f2,3,16 | grep -v "?" | sort | uniq | ../csv_to_control.pl
cat raw-result-analysis.csv | grep ReachabilityDeadlock | cut -d ',' -f2,3,16 | grep -v "?" | sort | uniq | sed 's/ReachabilityDeadlock/GlobalProperties/g' | ../csv_to_control.pl
mv *.out oracle/
rm -f raw-result-analysis.csv*

cd oracle
tar xvzf ../../oracleSS.tar.gz
cd ..
tar cvzf oracle.tar.gz  oracle/
rm -rf oracle/

cd ..



