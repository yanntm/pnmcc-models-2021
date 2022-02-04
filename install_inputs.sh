#! /bin/bash

set -x

mkdir website
cd website

# grab the vmdk file image for all inputs
mkdir INPUTS
wget --no-check-certificate --progress=dot:mega http://mcc.lip6.fr/2021/archives/mcc2021-input.vmdk.tar.bz2
tar xvjf mcc2021-input.vmdk.tar.bz2
../7z e mcc2021-input.vmdk
../ext2rd 0.img ./:INPUTS
rm -f *.vmdk 0.img *.bz2 1

# patch formula names
echo "Patching formula names"
set +x
cd INPUTS
for i in *.tgz ;
do
	tar xzf $i
	model=$(echo $i | sed 's/.tgz//g')
	echo "Treating : $model"
	cd $model/
	for exam in ReachabilityFireability ReachabilityCardinality ;
	do
		cat $exam.xml | sed "s/id\>.*-$exam/id>$model-$exam/g" > $exam.tmp
		\mv $exam.tmp $exam.xml
	done
	for exam in LTLFireability LTLCardinality ;
	do
		cat $exam.xml | sed "s/id>$model-/id>$model-$exam-/g" > $exam.tmp
		\mv $exam.tmp $exam.xml
	done
	cd ..
	rm $i
	tar czf $i $model/
	rm -rf $model/
done
cd ..
set -x

if [ ! -f raw-result-analysis.csv ] 
then
	# grab the raw results file from MCC website
	wget --no-check-certificate --progress=dot:mega https://mcc.lip6.fr/2021/archives/raw-result-analysis.csv.zip
	unzip raw-result-analysis.csv.zip
fi

# create oracle files
mkdir oracle
mkdir poracle
# all results available
cat raw-result-analysis.csv | grep -v StateSpace | cut -d ',' -f2,3,16 | grep -v "?" | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl
mv *.out oracle/
 
# contradict GreatSPN, but confirmed by Tapaal (in Dec 2021) and ITS-Tools
# consensus is poor in 2021, since only ITS-Tools and GreatSPN could parse it
sed -i -e "s/UtilityControlRoom-COL-Z2T3N06-LTLCardinality-08 TRUE/UtilityControlRoom-COL-Z2T3N06-LTLCardinality-08 FALSE/" UtilityControlRoom-COL-Z2T3N06-LTLC.out
sed -i -e "s/UtilityControlRoom-COL-Z2T3N10-LTLCardinality-08 TRUE/UtilityControlRoom-COL-Z2T3N10-LTLCardinality-08 FALSE/" UtilityControlRoom-COL-Z2T3N10-LTLC.out
sed -i -e "s/UtilityControlRoom-COL-Z2T3N10-LTLCardinality-11 TRUE/UtilityControlRoom-COL-Z2T3N10-LTLCardinality-11 FALSE/" UtilityControlRoom-COL-Z2T3N10-LTLC.out
sed -i -e "s/UtilityControlRoom-COL-Z4T4N02-LTLCardinality-08 TRUE/UtilityControlRoom-COL-Z4T4N02-LTLCardinality-08 FALSE/" UtilityControlRoom-COL-Z4T4N02-LTLC.out
sed -i -e "s/UtilityControlRoom-COL-Z2T3N06-LTLFireability-14 TRUE/UtilityControlRoom-COL-Z2T3N06-LTLFireability-14 FALSE/" UtilityControlRoom-COL-Z2T3N06-LTLF.out
sed -i -e "s/UtilityControlRoom-COL-Z2T4N06-LTLFireability-14 TRUE/UtilityControlRoom-COL-Z2T4N06-LTLFireability-14 FALSE/" UtilityControlRoom-COL-Z2T4N06-LTLF.out
sed -i -e "s/UtilityControlRoom-COL-Z4T4N10-LTLFireability-08 TRUE/UtilityControlRoom-COL-Z4T4N10-LTLFireability-08 FALSE/" UtilityControlRoom-COL-Z4T4N10-LTLF.out


#rm -f raw-result-analysis.csv*

cd oracle
tar xzf ../../oracleSS.tar.gz
cd ..
tar czf oracle.tar.gz  oracle/
rm -rf oracle/

# partial oracles may contain '?'
cat raw-result-analysis.csv | grep -v StateSpace | cut -d ',' -f2,3,16 | grep "?" | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl


mv *.out poracle/

tar czf poracle.tar.gz  poracle/
rm -rf poracle/

tree -H "." > index.html

cd ..
