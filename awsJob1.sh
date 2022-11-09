#!/usr/bin/bash

#sed strings to replace
#1 : my attempt number
#attempt1     : my working directory


#make a working directory
mkdir -p attempt1

#change to working directory
cd attempt1

#for initial and consequent pickles
ln -s ../database00.pickle database00.pickle

ln -s ../distance0* . 2> /dev/null


touch STARTED

singularity exec ../python3.sif python3 ../tspMod.py 0 database00.pickle $(($task+8)) 100 > ../results1.txt
wait

current_best_1_NUM=`cut -d ":" -f2 ../results1.txt| uniq |sort | head -n1`
#echo $current_best_1_NUM

best_pickle_file=`grep "$current_best_1_NUM" ../results1.txt | cut -d ":" -f1 | head -n 1`

#touch best_1_detail.txt
echo $current_best_1_NUM >>  job_1_detail.txt

echo $best_pickle_file >> job_1_detail.txt

mv STARTED FINISHED
