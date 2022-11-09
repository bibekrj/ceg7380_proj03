#!/usr/bin/bash

#sed strings to replace
#MYATTEMPT : my attempt number
#MYDIR     : my working directory


#make a working directory
mkdir -p MYDIR

#change to working directory
cd MYDIR

#for initial and consequent pickles
ln -s ../PICKLEFILENAME PICKLEFILENAME

ln -s ../distance0* . 2> /dev/null


touch STARTED

singularity exec ../python3.sif python3 ../tspMod.py DISTANCEPICKLENUMBER PICKLEFILENAME $(($task+RANDSEED)) NOOFTRYS > ../resultsMYATTEMPT.txt
wait

current_best_MYATTEMPT_NUM=`cut -d ":" -f2 ../resultsMYATTEMPT.txt| uniq |sort | head -n1`
#echo $current_best_MYATTEMPT_NUM

best_pickle_file=`grep "$current_best_MYATTEMPT_NUM" ../resultsMYATTEMPT.txt | cut -d ":" -f1 | head -n 1`

#touch best_MYATTEMPT_detail.txt
echo $current_best_MYATTEMPT_NUM >>  job_MYATTEMPT_detail.txt

echo $best_pickle_file >> job_MYATTEMPT_detail.txt

mv STARTED FINISHED
