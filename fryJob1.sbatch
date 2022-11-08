#!/usr/bin/bash
#SBATCH -N 1
#SBATCH --cpus-per-task=1
#SBATCH --tasks-per-node=16
#SBATCH --job-name=job_1
#SBATCH --output=results1.txt
#SBATCH --time=00:15:00

#sed strings to replace
#1 : my attempt number
#attempt1     : my working directory


#make a working directory
mkdir -p attempt1

#change to working directory
cd attempt1

#for initial and consequent pickles
ln -s ../database03.pickle database03.pickle

ln -s ~w006jwn/proj03data/distance0* . 2> /dev/null


touch STARTED

for task in $(seq 0 15);
do
    singularity exec -B /home/w006jwn/proj03data -B /home/w006jwn/proj03data/tspMod.py ~w006jwn/python3.sif python3 /home/w006jwn/proj03data/tspMod.py 3 database03.pickle $(($task+50)) 100 &   
done
wait

current_best_1_NUM=`cut -d ":" -f2 ../results1.txt| uniq |sort | head -n1`
#echo $current_best_1_NUM

best_pickle_file=`grep "$current_best_1_NUM" ../results1.txt | cut -d ":" -f1 | head -n 1`

#touch best_1_detail.txt
echo $current_best_1_NUM >>  job_1_detail.txt

echo $best_pickle_file >> job_1_detail.txt

mv STARTED FINISHED
