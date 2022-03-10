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
# all results available
cat raw-result-analysis.csv | grep -v StateSpace | cut -d ',' -f2,3,16 | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl
 
# contradict GreatSPN, but confirmed by Tapaal (in Dec 2021) and ITS-Tools
# consensus is poor in 2021, since only ITS-Tools and GreatSPN could parse it
sed -i -e "s/UtilityControlRoom-COL-Z2T3N06-LTLCardinality-08 TRUE/UtilityControlRoom-COL-Z2T3N06-LTLCardinality-08 FALSE/" UtilityControlRoom-COL-Z2T3N06-LTLC.out
sed -i -e "s/UtilityControlRoom-COL-Z2T3N10-LTLCardinality-08 TRUE/UtilityControlRoom-COL-Z2T3N10-LTLCardinality-08 FALSE/" UtilityControlRoom-COL-Z2T3N10-LTLC.out
sed -i -e "s/UtilityControlRoom-COL-Z2T3N10-LTLCardinality-11 TRUE/UtilityControlRoom-COL-Z2T3N10-LTLCardinality-11 FALSE/" UtilityControlRoom-COL-Z2T3N10-LTLC.out
sed -i -e "s/UtilityControlRoom-COL-Z4T4N02-LTLCardinality-08 TRUE/UtilityControlRoom-COL-Z4T4N02-LTLCardinality-08 FALSE/" UtilityControlRoom-COL-Z4T4N02-LTLC.out
sed -i -e "s/UtilityControlRoom-COL-Z2T3N06-LTLFireability-14 TRUE/UtilityControlRoom-COL-Z2T3N06-LTLFireability-14 FALSE/" UtilityControlRoom-COL-Z2T3N06-LTLF.out
sed -i -e "s/UtilityControlRoom-COL-Z2T4N06-LTLFireability-14 TRUE/UtilityControlRoom-COL-Z2T4N06-LTLFireability-14 FALSE/" UtilityControlRoom-COL-Z2T4N06-LTLF.out
sed -i -e "s/UtilityControlRoom-COL-Z4T4N10-LTLFireability-08 TRUE/UtilityControlRoom-COL-Z4T4N10-LTLFireability-08 FALSE/" UtilityControlRoom-COL-Z4T4N10-LTLF.out

# no answer in 2021, except 2020gold very red on this example, proved using Knowledge approach
sed -i -e "s/Sudoku-COL-AN09-LTLFireability-13 FALSE/Sudoku-COL-AN09-LTLFireability-13 TRUE/" Sudoku-COL-AN09-LTLF.out
sed -i -e "s/Sudoku-COL-AN11-LTLFireability-00 FALSE/Sudoku-COL-AN11-LTLFireability-00 TRUE/" Sudoku-COL-AN11-LTLF.out

# contradict Enpac but checked manually the XXXX part of the formula is satisfiable (in like 5 steps)
sed -i -e "s/Sudoku-COL-BN16-LTLFireability-04 TRUE/Sudoku-COL-BN16-LTLFireability-04 FALSE/" Sudoku-COL-BN16-LTLF.out

# contradict GreatSPN, but it has red on this model; proved using convergence knowledge (FGp)
sed -i -e "s/HouseConstruction-PT-00020-LTLFireability-07 FALSE/HouseConstruction-PT-00020-LTLFireability-07 TRUE/" HouseConstruction-PT-00020-LTLF.out

# contradict Lola, but the AP in this formula are actually invariant (according to ITS-tools K_INDUCTION(1) strategy, other tools seem to die on this model)
sed -i -e "s/ASLink-PT-08b-LTLFireability-15 FALSE/ASLink-PT-08b-LTLFireability-15 TRUE/" ASLink-PT-08b-LTLF.out


mv *.out oracle/

#rm -f raw-result-analysis.csv*

cd oracle
tar xzf ../../oracleSS.tar.gz
cd ..
tar czf oracle.tar.gz  oracle/
rm -rf oracle/

tree -H "." > index.html

cd ..
