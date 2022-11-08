#!/usr/bin/bash
#SBATCH -N 1
#SBATCH --cpus-per-task=1
#SBATCH --tasks-per-node=16
#SBATCH --job-name=job_MYATTEMPT
#SBATCH --output=resultsMYATTEMPT.txt
#SBATCH --time=00:15:00

#sed strings to replace
#MYATTEMPT : my attempt number
#MYDIR     : my working directory


#make a working directory
mkdir -p MYDIR

#change to working directory
cd MYDIR

#for initial and consequent pickles
ln -s ../PICKLEFILENAME PICKLEFILENAME

ln -s ~w006jwn/proj03data/distance0* . 2> /dev/null


touch STARTED

for task in $(seq LOOPSTART LOOPEND);
do
    singularity exec -B /home/w006jwn/proj03data -B /home/w006jwn/proj03data/tspMod.py ~w006jwn/python3.sif python3 /home/w006jwn/proj03data/tspMod.py DISTANCEPICKLENUMBER PICKLEFILENAME $(($task+RANDSEED)) NOOFTRYS &   
done
wait

current_best_MYATTEMPT_NUM=`cut -d ":" -f2 ../resultsMYATTEMPT.txt| uniq |sort | head -n1`
#echo $current_best_MYATTEMPT_NUM

best_pickle_file=`grep "$current_best_MYATTEMPT_NUM" ../resultsMYATTEMPT.txt | cut -d ":" -f1 | head -n 1`

#touch best_MYATTEMPT_detail.txt
echo $current_best_MYATTEMPT_NUM >>  job_MYATTEMPT_detail.txt

echo $best_pickle_file >> job_MYATTEMPT_detail.txt

mv STARTED FINISHED
