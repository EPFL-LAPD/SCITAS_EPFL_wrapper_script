#!/bin/bash

# Default time limit
time_limit="00:45:00"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --time=*)
            time_limit="${1#*=}"
            shift
            ;;
        *)
            config_file="$1"
            shift
            ;;
    esac
done

# Check if a config file is provided
if [ -z "$config_file" ]; then
    echo "Error: No config file provided. Please provide the path to the config file."
    echo "Usage: $0 [--time=HH:MM:SS] config_file_path"
    exit 1
fi

# Create a unique temporary file name based on the current timestamp
temp_script=$(mktemp)

# Extract the folder name from the provided path
folder_name=$(basename "$(dirname "$config_file")")

# Write the Slurm script content to the temporary file
cat > "$temp_script" << EOF
#!/bin/bash
#SBATCH --job-name=$folder_name
#SBATCH --output=job_output.log
#SBATCH --error=job_error.log
#SBATCH --partition=l40s
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --mem=30G
#SBATCH --time=$time_limit
#SBATCH --cpus-per-task=16

LOGFILE="\`pwd\`/logs/\$(date '+%Y-%m-%d_%H-%M-%S')_$folder_name.log"

mkdir -p logs
# Run the command
apptainer run --bind /scratch/$USER --nv /home/$USER/container.sif drtvam \$1 >> "\$LOGFILE" 2>&1
EOF

# Make the temporary script executable
chmod +x "$temp_script"

# Submit the job using sbatch
sbatch "$temp_script" "$config_file"

# Remove the temporary script (optional, but recommended to avoid clutter)
rm "$temp_script"
