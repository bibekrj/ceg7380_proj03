#!/usr/bin/bash
#SBATCH --account=PWSU0493
#SBATCH -N 1
#SBATCH --tasks-per-node=16
#SBATCH --job-name=proj03
#SBATCH --output=proj03.output


# touch STARTED

singularity exec ~w006jwn/python3.sif python3 tspMod.py 0 initialGuess.pickle 15 500000

#mv STARTED FINISHED
