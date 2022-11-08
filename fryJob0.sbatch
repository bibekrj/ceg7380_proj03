#!/usr/bin/bash
#SBATCH -N 1
#SBATCH --cpus-per-task=1
#SBATCH --tasks-per-node=16
#SBATCH --job-name=job_0
#SBATCH --output=results0.txt
#SBATCH --time=00:15:00

#sed strings to replace
#0 : my attempt number
#attempt0     : my working directory


#make a working directory
mkdir -p attempt0

#change to working directory
cd attempt0

#for initial and consequent pickles
ln -s ../initialGuess.pickle initialGuess.pickle

ln -s ~w006jwn/proj03data/distance0* . 2> /dev/null


touch STARTED

for task in $(seq 0 15);
do
    singularity exec -B /home/w006jwn/proj03data -B /home/w006jwn/proj03data/tspMod.py ~w006jwn/python3.sif python3 /home/w006jwn/proj03data/tspMod.py 1 initialGuess.pickle $(($task+10)) 500000 &   
done
wait

current_best_0_NUM=`cut -d ":" -f2 ../results0.txt| uniq |sort | head -n1`
#echo $current_best_0_NUM

best_pickle_file=`grep "$current_best_0_NUM" ../results0.txt | cut -d ":" -f1`

#touch best_0_detail.txt
echo $current_best_0_NUM >>  best_0_detail.txt

echo $best_pickle_file >> best_0_detail.txt

mv STARTED FINISHED
