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



if [ ! -f raw-result-analysis.csv ] 
then
	# grab the raw results file from MCC website
	wget --no-check-certificate --progress=dot:mega https://mcc.lip6.fr/2020/archives/raw-result-analysis.csv.zip
	unzip raw-result-analysis.csv.zip
fi

# create oracle files
mkdir oracle
mkdir poracle
# all results available
cat raw-result-analysis.csv | grep -v StateSpace | cut -d ',' -f2,3,16 | grep -v "?" | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl
mv *.out oracle/

# Due to parse errors of ITS-Tools+ITS-Lola that were not always interpreted as such in 2020
# consensus, and thus oracles on this model are unreliable on sizes above 1
mv oracle/Sudoku-COL-AN01* .
mv oracle/Sudoku-COL-BN01* .
rm oracle/Sudoku-COL*
rm Sudoku-COL*LTL?.out
mv Sudoku-COL* oracle/

# after manual examination, this consensus verdict (with weak support) is also wrong
# formula is reduced to true by e.g. Spot : https://spot.lrde.epita.fr/app/
# try it : X !X !(X G "k38" | F !X "k38")
sed -i -e "s/Angiogenesis-PT-15-14 FALSE/Angiogenesis-PT-15-14 TRUE/" oracle/Angiogenesis-PT-15-LTLF.out

# this oracle is also wrong, formula is :!(F(!G((G(X(p0))||!p0)))||G(p0))
# which spot reduces to :  !( (G p0) | (F !G (!p0 | G X p0)))
# which produces an automaton with !p0 on the only outgoing edge from initial state.
# But p0=enabled(Prepare_request), *is indeed* true in initial state, see model here
# https://mcc.lip6.fr/2020/pdf/CSRepetitions-form.pdf
sed -i -e "s/CSRepetitions-PT-04-03 FALSE/CSRepetitions-PT-04-03 TRUE/" oracle/CSRepetitions-PT-04-LTLF.out
sed -i -e "s/CSRepetitions-COL-04-03 FALSE/CSRepetitions-COL-04-03 TRUE/" oracle/CSRepetitions-COL-04-LTLF.out

# another wrong oracle, GreatSPN sole to answer on this but has errors on smaller instances of the model
# negated formula is : !(X((!p0||X(X(F((G(F(p2))||p1)))))))
# our proof approach discards it quite convincingly using knowledge  : ... & (F (G p2)) 
sed -i -e "s/AirplaneLD-COL-0200-10 FALSE/AirplaneLD-COL-0200-10 TRUE/" oracle/AirplaneLD-COL-0200-LTLF.out

# Due to ITS-Tools in 2020 believing NUPN implies one-safe, consensus on these RERS examinations are wrong (sorry everyone !)
rm oracle/RERS17pb113-PT-7-RC.out oracle/RERS17pb113-PT-8-RC.out 
rm oracle/RERS17pb114-PT-2-RC.out oracle/RERS17pb114-PT-5-RC.out oracle/RERS17pb114-PT-6-RC.out oracle/RERS17pb114-PT-7-RC.out oracle/RERS17pb114-PT-8-RC.out oracle/RERS17pb114-PT-9-RC.out 
rm oracle/RERS17pb115-PT-4-RC.out oracle/RERS17pb115-PT-5-RC.out oracle/RERS17pb115-PT-6-RC.out oracle/RERS17pb115-PT-7-RC.out oracle/RERS17pb115-PT-8-RC.out oracle/RERS17pb115-PT-9-RC.out

rm oracle/RERS17pb114-PT-6-RF.out oracle/RERS17pb114-PT-7-RF.out oracle/RERS17pb114-PT-8-RF.out oracle/RERS17pb114-PT-9-RF.out 
rm oracle/RERS17pb115-PT-5-RF.out oracle/RERS17pb115-PT-6-RF.out oracle/RERS17pb115-PT-7-RF.out oracle/RERS17pb115-PT-8-RF.out oracle/RERS17pb115-PT-9-RF.out

# more errors due to RERS not being 1-safe
sed -i -e "s/RERS17pb114-PT-6-08 TRUE/RERS17pb114-PT-6-08 FALSE/" oracle/RERS17pb114-PT-6-LTLF.out


#rm -f raw-result-analysis.csv*

cd oracle
tar xvzf ../../oracleSS.tar.gz
cd ..
tar cvzf oracle.tar.gz  oracle/
#rm -rf oracle/

# partial oracles may contain '?'
cat raw-result-analysis.csv | grep -v StateSpace | cut -d ',' -f2,3,16 | grep "?" | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl

# Sudoku unreliable oracles
cat raw-result-analysis.csv | grep -v StateSpace | grep Sudoku-COL | cut -d ',' -f2,3,16 | grep -v "?" | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl
for i in *.out ; do 
if [ -f "oracle/$i" ]
then 
rm $i 
fi
done 
for i in Sudoku-COL-*UB.out Sudoku-COL-*CTL?.out Sudoku-COL-*LTL?.out Sudoku-COL-*RF.out Sudoku-COL-*RC.out ; do cat $i | perl -pe 's/\w+ TECHNIQUES/? TECHNIQUES/g' > $i.tmp ; mv -f $i.tmp $i ; done

# errors due to enpac
sed -i -e "s/SharedMemory-COL-000050-15 TRUE/SharedMemory-COL-000050-15 FALSE/" SharedMemory-COL-000050-LTLF.out
sed -i -e "s/AirplaneLD-PT-4000-13 TRUE/AirplaneLD-PT-4000-13 FALSE/" AirplaneLD-PT-4000-LTLC.out


mv *.out poracle/

tar cvzf poracle.tar.gz  poracle/
#rm -rf poracle/

cd ..



