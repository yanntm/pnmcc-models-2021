#! /bin/bash

set -x

# grab the vmdk file image for all inputs
mkdir INPUTS
cd INPUTS
wget --progress=dot:mega http://mcc.lip6.fr/2018/archives/mcc2018-input.vmdk
7z e mcc2018-input.vmdk
rm mcc2018-input.vmdk
cd ..

# create oracle files
mkdir oracle
wget --progress=dot:mega https://mcc.lip6.fr/2018/archives/raw-result-analysis.csv.zip
unzip raw-result-analysis.csv.zip
for line in $(cat raw-result-analysis.csv | cut -d ',' -f2,3,16 | sed 's/\? /?/g' | sort | uniq)
do
	
done


for i in MCC-INPUTS.tgz ;
do 
    if [ ! -f $i ] ; then 
	wget --progress=dot:mega http://mcc.lip6.fr/2017/archives/$i
    fi
    tar xzf $i
    rm -f $i
done
mv BenchKit/INPUTS/* ./INPUTS/
\rm -r BenchKit

mkdir test
cd test
cp ../scalar.tgz .
tar xzf scalar.tgz
cd ../INPUTS
for i in $(ls -1 ../test/scalar); do
    if [ -f $i.tgz ] ;
    then
	tar xzf $i.tgz && cp ../test/scalar/$i/* $i/ && \rm $i.tgz && tar czf $i.tgz $i/ && rm -rf $i/ ;
    fi
done

cd ..
\rm -rf scalar/    


