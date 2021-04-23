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

# same kind of initial state bug it seems
sed -i -e "s/Diffusion2D-PT-D05N200-15 FALSE/Diffusion2D-PT-D05N200-15 TRUE/" oracle/Diffusion2D-PT-D05N200-LTLC.out

# another wrong oracle, GreatSPN sole to answer on this but has errors on smaller instances of the model
# negated formula is : !(X((!p0||X(X(F((G(F(p2))||p1)))))))
# our proof approach discards it quite convincingly using knowledge  : ... & (F (G p2)) 
sed -i -e "s/AirplaneLD-COL-0200-10 FALSE/AirplaneLD-COL-0200-10 TRUE/" oracle/AirplaneLD-COL-0200-LTLF.out

# manually examined, confirmed by LTSmin, contradicts Lola
sed -i -e "s/Philosophers-COL-000200-06 TRUE/Philosophers-COL-000200-06 FALSE/" oracle/Philosophers-COL-000200-LTLF.out


# contest trusted Smart but should have trusted GreatSpn on these examinations
sed -i -e "s/Liveness FALSE/Liveness TRUE/" oracle/JoinFreeModules-PT-0010-L.out
sed -i -e "s/Liveness FALSE/Liveness TRUE/" oracle/NeighborGrid-PT-d3n3m1t11-L.out
# a bunch of them here
sed -i -e "s/Liveness FALSE/Liveness TRUE/" oracle/RefineWMG-PT-*-L.out

# Due to ITS-Tools in 2020 believing NUPN implies one-safe, consensus on these RERS examinations are wrong/should not be trusted (sorry everyone !)
rm oracle/RERS17*-RC.out oracle/RERS17*-RF.out 

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

# RERS unreliable oracles
cat raw-result-analysis.csv | grep -v StateSpace | grep RERS17 | grep Reachability | cut -d ',' -f2,3,16 | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl
for i in RERS17*RC.out RERS17*RF.out ; do cat $i | perl -pe 's/\w+ TECHNIQUES/? TECHNIQUES/g' > $i.tmp ; mv -f $i.tmp $i ; done


# errors due to enpac
sed -i -e "s/SharedMemory-COL-000050-15 TRUE/SharedMemory-COL-000050-15 FALSE/" SharedMemory-COL-000050-LTLF.out
sed -i -e "s/AirplaneLD-PT-4000-13 TRUE/AirplaneLD-PT-4000-13 FALSE/" AirplaneLD-PT-4000-LTLC.out
sed -i -e "s/NoC3x3-PT-7B-10 TRUE/NoC3x3-PT-7B-10 FALSE/" NoC3x3-PT-7B-LTLC.out
sed -i -e "s/ShieldPPPs-PT-020A-06 TRUE/ShieldPPPs-PT-020A-06 FALSE/" ShieldPPPs-PT-020A-LTLC.out
sed -i -e "s/SharedMemory-COL-000100-13 TRUE/SharedMemory-COL-000100-13 FALSE/" SharedMemory-COL-000100-LTLF.out
sed -i -e "s/TokenRing-COL-050-15 TRUE/TokenRing-COL-050-15 FALSE/" TokenRing-COL-050-LTLF.out
sed -i -e "s/JoinFreeModules-PT-0100-12 TRUE/JoinFreeModules-PT-0100-12 FALSE/" JoinFreeModules-PT-0100-LTLC.out


# more GreatSPN solo answers on LTL where it makes errors when there are other tools answering
sed -i -e "s/HouseConstruction-PT-00020-01 FALSE/HouseConstruction-PT-00020-01 TRUE/" HouseConstruction-PT-00020-LTLC.out
sed -i -e "s/Referendum-COL-0100-13 FALSE/Referendum-COL-0100-13 TRUE/" Referendum-COL-0100-LTLC.out

# more RERS bad answers by ITS tools or Its-lola
sed -i -e "s/RERS17pb113-PT-7-08 TRUE/RERS17pb113-PT-7-08 FALSE/" RERS17pb113-PT-7-LTLC.out
sed -i -e "s/RERS17pb114-PT-9-03 TRUE/RERS17pb114-PT-9-03 FALSE/" RERS17pb114-PT-9-LTLC.out
sed -i -e "s/RERS17pb114-PT-7-03 TRUE/RERS17pb114-PT-7-03 FALSE/" RERS17pb114-PT-7-LTLF.out
sed -i -e "s/RERS17pb114-PT-8-04 TRUE/RERS17pb114-PT-8-04 FALSE/" RERS17pb114-PT-8-LTLF.out


mv *.out poracle/

tar cvzf poracle.tar.gz  poracle/
#rm -rf poracle/

cd ..



