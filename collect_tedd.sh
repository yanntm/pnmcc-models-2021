#! /bin/bash

# 1. Grab full logs of the MCC, decompress it

# 2. isolate our target files : state space from tedd
# mkdir ss/
# mv */*/*/tedd*StateSpace* ss/

# 3. run this script in ss/ folder
for i in *.stdout ;
do
    # model name
    j=$(echo $i | cut -d '_' -f 2) ;
    # grab and massage the answer, replace techniques by TEDD2020
    (echo $j StateSpace ; cat $i | grep STATE_SPACE | cut -d ' ' -f 1-4 | while read line; do echo ${line}" TEDD2020"; done ;) > $j-SS.out ;
done ;

# only keep files with 5 lines = all results
for f in *-SS.out;
do
    a=$(cat "$f" | wc -l) ;
    if [ "$a" -ne "5" ]
    then
	rm -f "$f" 
    fi 
done 


