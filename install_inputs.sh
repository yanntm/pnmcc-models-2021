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
	for exam in ReachabilityFireability ReachabilityCardinality UpperBounds ;
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
cat raw-result-analysis.csv | grep -v StateSpace | grep -v UpperBound | cut -d ',' -f2,3,16 | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl
# UpperBounds => do not remove whitespace
cat raw-result-analysis.csv | grep UpperBound | cut -d ',' -f2,3,16 | sort | uniq | ../csv_to_control.pl

 
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
sed -i -e "s/Sudoku-COL-AN05-LTLFireability-00 FALSE/Sudoku-COL-AN05-LTLFireability-00 TRUE/" Sudoku-COL-AN05-LTLF.out
sed -i -e "s/Sudoku-COL-AN09-LTLFireability-13 FALSE/Sudoku-COL-AN09-LTLFireability-13 TRUE/" Sudoku-COL-AN09-LTLF.out
sed -i -e "s/Sudoku-COL-AN11-LTLFireability-00 FALSE/Sudoku-COL-AN11-LTLFireability-00 TRUE/" Sudoku-COL-AN11-LTLF.out

# contradict Enpac but checked manually the XXXX part of the formula is satisfiable (in like 5 steps)
sed -i -e "s/Sudoku-COL-BN16-LTLFireability-04 TRUE/Sudoku-COL-BN16-LTLFireability-04 FALSE/" Sudoku-COL-BN16-LTLF.out

# contradict GreatSPN, but it has red on this model; proved using convergence knowledge (FGp)
sed -i -e "s/HouseConstruction-PT-00020-LTLFireability-07 FALSE/HouseConstruction-PT-00020-LTLFireability-07 TRUE/" HouseConstruction-PT-00020-LTLF.out

# contradict Lola, but the AP in this formula are actually invariant (according to ITS-tools K_INDUCTION(1) strategy, other tools seem to die on this model)
sed -i -e "s/ASLink-PT-08b-LTLFireability-15 FALSE/ASLink-PT-08b-LTLFireability-15 TRUE/" ASLink-PT-08b-LTLF.out

# contradict Lola, which is red on every point except when it answers alone on this model/examination.
sed -i -e "s/StableMarking TRUE/StableMarking FALSE/" ViralEpidemic-PT-S02D1C1A12-SM.out
sed -i -e "s/StableMarking TRUE/StableMarking FALSE/" ViralEpidemic-PT-S03D1C1A08-SM.out
sed -i -e "s/StableMarking TRUE/StableMarking FALSE/" ViralEpidemic-PT-S16D2C4A03-SM.out

# contradict Lola, which is very red on this model/examination + answers alone on these consensus
# there seems to be issues on Lola with COL symmetric models in 2021 for CTLF.
# built using this line of shell 
# grep estFail *out | grep CTL | grep COL > fails.txt
# for i in $(cat fails.txt | cut -d ' ' -f 8-12 | sed s/\'//g | sed 's/)//g' | sed 's#/##g' | sed 's/  / /g' | sed 's/ /:/g') ; do form=$(echo $i | cut -d ':' -f 1) ; exp=$(echo $i | cut -d ':' -f 2) ; real=$(echo $i | cut -d ':' -f 3) ; fil=$(echo $form | sed 's/CTLF.*/CTLF.out/') ; echo "sed -i -e \"s/$form $exp/$form $real/\" $fil" ; done
sed -i -e "s/BART-COL-020-CTLFireability-05 TRUE/BART-COL-020-CTLFireability-05 FALSE/" BART-COL-020-CTLF.out
sed -i -e "s/BART-COL-030-CTLFireability-10 FALSE/BART-COL-030-CTLFireability-10 TRUE/" BART-COL-030-CTLF.out
sed -i -e "s/DrinkVendingMachine-COL-76-CTLFireability-15 TRUE/DrinkVendingMachine-COL-76-CTLFireability-15 FALSE/" DrinkVendingMachine-COL-76-CTLF.out
sed -i -e "s/DrinkVendingMachine-COL-98-CTLFireability-00 TRUE/DrinkVendingMachine-COL-98-CTLFireability-00 FALSE/" DrinkVendingMachine-COL-98-CTLF.out
sed -i -e "s/DrinkVendingMachine-COL-98-CTLFireability-06 FALSE/DrinkVendingMachine-COL-98-CTLFireability-06 TRUE/" DrinkVendingMachine-COL-98-CTLF.out
sed -i -e "s/FamilyReunion-COL-L00010M0001C001P001G001-CTLFireability-12 TRUE/FamilyReunion-COL-L00010M0001C001P001G001-CTLFireability-12 FALSE/" FamilyReunion-COL-L00010M0001C001P001G001-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-06-CTLFireability-06 TRUE/GlobalResAllocation-COL-06-CTLFireability-06 FALSE/" GlobalResAllocation-COL-06-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-06-CTLFireability-00 TRUE/GlobalResAllocation-COL-06-CTLFireability-00 FALSE/" GlobalResAllocation-COL-06-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-06-CTLFireability-04 FALSE/GlobalResAllocation-COL-06-CTLFireability-04 TRUE/" GlobalResAllocation-COL-06-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-06-CTLFireability-08 FALSE/GlobalResAllocation-COL-06-CTLFireability-08 TRUE/" GlobalResAllocation-COL-06-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-06-CTLFireability-10 TRUE/GlobalResAllocation-COL-06-CTLFireability-10 FALSE/" GlobalResAllocation-COL-06-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-06-CTLFireability-14 TRUE/GlobalResAllocation-COL-06-CTLFireability-14 FALSE/" GlobalResAllocation-COL-06-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-07-CTLFireability-04 FALSE/GlobalResAllocation-COL-07-CTLFireability-04 TRUE/" GlobalResAllocation-COL-07-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-07-CTLFireability-05 FALSE/GlobalResAllocation-COL-07-CTLFireability-05 TRUE/" GlobalResAllocation-COL-07-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-07-CTLFireability-06 FALSE/GlobalResAllocation-COL-07-CTLFireability-06 TRUE/" GlobalResAllocation-COL-07-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-07-CTLFireability-07 TRUE/GlobalResAllocation-COL-07-CTLFireability-07 FALSE/" GlobalResAllocation-COL-07-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-07-CTLFireability-08 TRUE/GlobalResAllocation-COL-07-CTLFireability-08 FALSE/" GlobalResAllocation-COL-07-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-07-CTLFireability-11 FALSE/GlobalResAllocation-COL-07-CTLFireability-11 TRUE/" GlobalResAllocation-COL-07-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-09-CTLFireability-11 TRUE/GlobalResAllocation-COL-09-CTLFireability-11 FALSE/" GlobalResAllocation-COL-09-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-09-CTLFireability-14 FALSE/GlobalResAllocation-COL-09-CTLFireability-14 TRUE/" GlobalResAllocation-COL-09-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-09-CTLFireability-15 FALSE/GlobalResAllocation-COL-09-CTLFireability-15 TRUE/" GlobalResAllocation-COL-09-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-09-CTLFireability-06 FALSE/GlobalResAllocation-COL-09-CTLFireability-06 TRUE/" GlobalResAllocation-COL-09-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-09-CTLFireability-02 FALSE/GlobalResAllocation-COL-09-CTLFireability-02 TRUE/" GlobalResAllocation-COL-09-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-09-CTLFireability-04 FALSE/GlobalResAllocation-COL-09-CTLFireability-04 TRUE/" GlobalResAllocation-COL-09-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-10-CTLFireability-04 FALSE/GlobalResAllocation-COL-10-CTLFireability-04 TRUE/" GlobalResAllocation-COL-10-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-10-CTLFireability-09 FALSE/GlobalResAllocation-COL-10-CTLFireability-09 TRUE/" GlobalResAllocation-COL-10-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-10-CTLFireability-10 FALSE/GlobalResAllocation-COL-10-CTLFireability-10 TRUE/" GlobalResAllocation-COL-10-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-10-CTLFireability-11 FALSE/GlobalResAllocation-COL-10-CTLFireability-11 TRUE/" GlobalResAllocation-COL-10-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-11-CTLFireability-07 TRUE/GlobalResAllocation-COL-11-CTLFireability-07 FALSE/" GlobalResAllocation-COL-11-CTLF.out
sed -i -e "s/GlobalResAllocation-COL-11-CTLFireability-08 FALSE/GlobalResAllocation-COL-11-CTLFireability-08 TRUE/" GlobalResAllocation-COL-11-CTLF.out
sed -i -e "s/PermAdmissibility-COL-05-CTLFireability-09 TRUE/PermAdmissibility-COL-05-CTLFireability-09 FALSE/" PermAdmissibility-COL-05-CTLF.out
sed -i -e "s/TokenRing-COL-015-CTLFireability-03 TRUE/TokenRing-COL-015-CTLFireability-03 FALSE/" TokenRing-COL-015-CTLF.out
sed -i -e "s/TokenRing-COL-015-CTLFireability-12 FALSE/TokenRing-COL-015-CTLFireability-12 TRUE/" TokenRing-COL-015-CTLF.out

# Contradict Tapaal, but this was actually a rare bug, discussed with Jiri+Peter of Tapaal team
sed -i -e "s/ShieldRVt-PT-030A-CTLCardinality-10 FALSE/ShieldRVt-PT-030A-CTLCardinality-10 TRUE/" ShieldRVt-PT-030A-CTLCardinality-10
sed -i -e "s/DLCflexbar-PT-6a-CTLFireability-14 FALSE/DLCflexbar-PT-6a-CTLFireability-14 TRUE/" DLCflexbar-PT-6a-CTLF.out
sed -i -e "s/ShieldPPPt-PT-001B-CTLFireability-07 FALSE/ShieldPPPt-PT-001B-CTLFireability-07 TRUE/" ShieldPPPt-PT-001B-CTLF.out

mv *.out oracle/

#rm -f raw-result-analysis.csv*

cd oracle
tar xzf ../../oracleSS.tar.gz
cd ..
tar czf oracle.tar.gz  oracle/
rm -rf oracle/

tree -H "." > index.html

cd ..
