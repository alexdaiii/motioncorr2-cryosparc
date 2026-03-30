#!/usr/bin/env bash
set -euo pipefail

# 1. Setup Paths
# Use the absolute path to ensure CryoSPARC can always find the binary
MAMBA_ENV="motioncorr2"
BINARY_PATH="$HOME/Documents/MotionCor2_1.6.4_Mar31_2023/MotionCor2_1.6.4_Cuda121_Mar312023"
ENV_PATH="$HOME/.pyenv/versions/miniforge3-latest/envs/$MAMBA_ENV"

# 2. Environment & Library Fixes
# LD_PRELOAD fixes the 'libtinfo' version mismatch noise
export LD_PRELOAD=/lib/x86_64-linux-gnu/libtinfo.so.6
export LD_LIBRARY_PATH="$ENV_PATH/lib:${LD_LIBRARY_PATH:-}"
export PATH="$ENV_PATH/bin:$PATH"

# 3. Argument Transformation
args=("$@")
new_args=()
log_dir=""
log_index="0"

for ((i=0; i<${#args[@]}; i++)); do
    if [[ "${args[i]}" == "-LogFile" ]]; then
        raw_path="${args[i+1]}"
        log_index=$(basename "$raw_path")
        
        # Determine the parent directory
        parent_dir=$(dirname "$raw_path")
        if [[ "$parent_dir" != *"motioncor2_logs" ]]; then
            parent_dir="${parent_dir%/}/motioncor2_logs"
        fi
        
        # Create a unique subdirectory for THIS specific movie index
        # e.g., /.../motioncor2_logs/0/
        log_dir="${parent_dir}/${log_index}"
        mkdir -p "$log_dir"
        
        new_args+=("-LogDir" "$log_dir")
        ((i++))
    else
        new_args+=("${args[i]}")
    fi
done

# Apply your padding: 1 becomes 10, 0 becomes 00
padded_index="${log_index}0"

# 4. Run MotionCor2
"$BINARY_PATH" "${new_args[@]}"

# print the original and new arguments for debugging
echo -e "Original Arguments:\n${args[*]}"
echo -e "Transformed Arguments:\n${new_args[*]}"

# 5. Copy and Rename Logs for CryoSPARC
# Since we are in a private subdirectory, 'find' will only see one set of logs.
if [ -d "$log_dir" ]; then
    parent_log_dir=$(dirname "$log_dir")
    
    copy_log() {
        local suffix=$1
        local target="${padded_index}${suffix}"
        
        # Look specifically inside the movie's isolated subfolder
        local found_file=$(find "$log_dir" -maxdepth 1 -name "*${suffix}" | head -n 1)
        
        if [ -n "$found_file" ]; then
            # Copy from the subfolder UP to the parent directory
            echo "Copying $found_file -> $parent_log_dir/$target"
            cp "$found_file" "$parent_log_dir/$target"
        fi
    }

    copy_log "-Patch-Full.log"
    copy_log "-Patch-Frame.log"
    copy_log "-Patch-Patch.log"
fi

exit $?