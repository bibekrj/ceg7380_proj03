#!/usr/bin/bash

#sed strings to replace
#0 : my attempt number
#attempt0     : my working directory


#make a working directory
mkdir -p attempt0

#change to working directory
cd attempt0

#for initial and consequent pickles
ln -s ../initialGuess.pickle initialGuess.pickle

ln -s ../distance0* . 2> /dev/null


touch STARTED

singularity exec ../python3.sif python3 ../tspMod.py 0 initialGuess.pickle $(($task+8)) 100 > ../results0.txt
wait

current_best_0_NUM=`cut -d ":" -f2 ../results0.txt| uniq |sort | head -n1`
#echo $current_best_0_NUM

best_pickle_file=`grep "$current_best_0_NUM" ../results0.txt | cut -d ":" -f1 | head -n 1`

#touch best_0_detail.txt
echo $current_best_0_NUM >>  job_0_detail.txt

echo $best_pickle_file >> job_0_detail.txt

mv STARTED FINISHED
