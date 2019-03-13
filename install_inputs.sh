#! /bin/bash

set -x


mkdir website
cd website

# grab the vmdk file image for all inputs
mkdir INPUTS
cd INPUTS
wget --progress=dot:mega http://mcc.lip6.fr/2018/archives/mcc2018-input.vmdk.tar.bz2
tar xvjf mcc2018-input.vmdk.tar.bz2
../../7z e mcc2018-input.vmdk
rm mcc2018-input.vmdk
rm mcc2018-input.vmdk.tar.bz2
cd ..

# create oracle files
mkdir oracle
wget --progress=dot:mega https://mcc.lip6.fr/2018/archives/raw-result-analysis.csv.zip
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



