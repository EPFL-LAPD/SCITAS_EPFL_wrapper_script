# README
SLURM does not really allow to change the job name with a single line.
In our case, we use a script to make things easier. Copy the script, make it executable with `chmod +x optimize_slurm.sh`. 
Then launch with `./optimize_slurm.sh TVAM_patterns/FVJ1/config.json --time=00:20:00`
