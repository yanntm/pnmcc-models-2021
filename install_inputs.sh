#! /bin/bash

set -x

mkdir website
cd website

# grab the vmdk file image for all inputs
mkdir INPUTS
wget --no-check-certificate --progress=dot:mega http://mcc.lip6.fr/2020/archives/mcc2020-input.vmdk.tar.bz2
tar xvjf mcc2020-input.vmdk.tar.bz2
../7z e mcc2020-input.vmdk
../ext2rd 0.img ./:INPUTS
rm -f *.vmdk 0.img *.bz2 1

# special patch for MAPK bad formula names e.g. : MAPK-PT--GlobalProperties-0
cd INPUTS
tar xzf MAPK-PT-00640.tgz
cd MAPK-PT-00640/
for i in *.xml *.txt ; do sed -i 's/MAPK-PT--/MAPK-PT-00640-/g' $i ; done
cd ..
rm -f MAPK-PT-00640.tgz
tar czf MAPK-PT-00640.tgz MAPK-PT-00640/
rm -rf MAPK-PT-00640/
cd ..

# special patch for RefineWMG bad formula names e.g. : n0-ReachabilityFireability-08
cd INPUTS
for i in RefineWMG*.tgz ;
do
	tar xzf $i
	name=$(echo $i | sed 's/\.tgz//')
	cd $name
	for ff in *.xml *.txt ; do sed -i "s/<id>n0/<id>$name/g" $ff ; done
	cd ..
	rm -f $i
	tar czf $i $name/
	rm -rf $name/
done
cd ..



# create oracle files
mkdir oracle
wget --no-check-certificate --progress=dot:mega https://mcc.lip6.fr/2020/archives/raw-result-analysis.csv.zip
unzip raw-result-analysis.csv.zip
cat raw-result-analysis.csv | cut -d ',' -f2,3,16 | grep -v "?" | sort | uniq | ../csv_to_control.pl
mv *.out oracle/

# Due to parse errors of ITS-Tools+ITS-Lola that were not always interpreted as such in 2020
# consensus, and thus oracles on this model are unreliable on sizes above 1
mv oracle/Sudoku-COL-AN01* .
mv oracle/Sudoku-COL-BN01* .
rm oracle/Sudoku-COL*
mv Sudoku-COL* oracle/

# after manual examination, this consensus verdict (with weak support) is also wrong
# formula is reduced to true by e.g. Spot : https://spot.lrde.epita.fr/app/
# try it : X !X !(X G "k38" | F !X "k38")
sed -i -e "s/Angiogenesis-PT-15-14 FALSE/Angiogenesis-PT-15-14 TRUE/" oracle/Angiogenesis-PT-15-LTLF.out

# Due to ITS-Tools in 2020 believing NUPN implies one-safe, consensus on these RERS examinations are wrong (sorry everyone !)
rm oracle/RERS17pb113-PT-7-RC.out oracle/RERS17pb113-PT-8-RC.out 
rm oracle/RERS17pb114-PT-2-RC.out oracle/RERS17pb114-PT-5-RC.out oracle/RERS17pb114-PT-6-RC.out oracle/RERS17pb114-PT-7-RC.out oracle/RERS17pb114-PT-8-RC.out oracle/RERS17pb114-PT-9-RC.out 
rm oracle/RERS17pb115-PT-4-RC.out oracle/RERS17pb115-PT-5-RC.out oracle/RERS17pb115-PT-6-RC.out oracle/RERS17pb115-PT-7-RC.out oracle/RERS17pb115-PT-8-RC.out oracle/RERS17pb115-PT-9-RC.out

rm oracle/RERS17pb114-PT-6-RF.out oracle/RERS17pb114-PT-7-RF.out oracle/RERS17pb114-PT-8-RF.out oracle/RERS17pb114-PT-9-RF.out 
rm oracle/RERS17pb115-PT-5-RF.out oracle/RERS17pb115-PT-6-RF.out oracle/RERS17pb115-PT-7-RF.out oracle/RERS17pb115-PT-8-RF.out oracle/RERS17pb115-PT-9-RF.out


#rm -f raw-result-analysis.csv*

cd oracle
tar xvzf ../../oracleSS.tar.gz
cd ..
tar cvzf oracle.tar.gz  oracle/
#rm -rf oracle/

cd ..



