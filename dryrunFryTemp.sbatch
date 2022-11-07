#!/usr/bin/bash
#SBATCH -N 1
#SBATCH --cpus-per-task=1
#SBATCH --tasks-per-node=16
#SBATCH --job-name=nothing
#SBATCH --output=resultsMYATTEMPTNUM.txt

#sed strings to replace
#MYATTEMPT : my attempt number
#MYDIR     : my working directory


#make a working directory
mkdir -p MYDIR

#change to working directory
cd MYDIR

#for initial and consequent pickles
ln -s ../initialGuess.pickle initialGuess.pickle

ln -s ~w006jwn/proj03data/distance0* . 2> /dev/null


touch STARTED

for task in $(seq 0 15);
do
    singularity exec -B /home/w006jwn/proj03data -B /home/w006jwn/proj03data/tspMod.py ~w006jwn/python3.sif python3 /home/w006jwn/proj03data/tspMod.py 0 initialGuess.pickle $(($task+10)) 1 &   
done
wait

current_best_MYATTEMPT_NUM=`cut -d ":" -f2 ../resultsMYATTEMPTNUM.txt| uniq |sort | head -n1`
#echo $current_best_MYATTEMPT_NUM

best_pickle_file=`grep "$current_best_MYATTEMPT_NUM" ../resultsMYATTEMPTNUM.txt | cut -d ":" -f1`

#touch best_ATTEMPTNUM_detail.txt
echo $current_best_MYATTEMPT_NUM >>  best_ATTEMPTNUM_detail.txt

echo $best_pickle_file >> best_ATTEMPTNUM_detail.txt


mv STARTED FINISHED
