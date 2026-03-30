# MotionCorr2 For Cryosparc

This repo contains the required files to run MotionCorr2 within Cryosparc.
MotionCorr2 requires some older versions of CUDA, cuDNN, and Tiff libraries,
so to prevent you from having to install them systemwide and messing up other
programs, you can use the provided `environment.yaml` file to create a conda
environment with all the necessary dependencies.

The provided `hacky_bash_script.sh` is a simple script that you can run to 
make sure MotionCorr2 will run in the provided conda environment. The 
assumed name of the conda environment is `motioncorr2`.

Variables to change in script:
- `MAMBA_ENV`: The name of the conda environment you created using the provided `environment.yaml` file. The default is `motioncorr2`.
- `BINARY_PATH`: The path to the MotionCorr2 executable. 
- `ENV_PATH`: The path to the directory where the conda/mamba environments are located. To find you
    where your conda environment is located, you can run `conda info --envs` and look at the paths listed there.
- 'ADDITIONAL_ARGS': Any additional arguments you want to pass to MotionCorr2. 
    You can leave this empty if you don't have any additional arguments to pass.
  - It should be somewhat in the format of `list[str]`, where the string format is
  of the format `-ArgumentName ArgumentValue`. 
  - For example, if you wanted to pass the argument `-SplitSum 1`, 
  you would add `-SplitSum 1` to the `ADDITIONAL_ARGS` variable.
  - Do this in place of the Additional Arguments field in Cryosparc, since it does not appear to pass those arguments to MotionCorr2 properly (as of version 5.0.3).

The script will pass all arguments from Cryosparc (version 5.0.3) to MotionCorr2. It will make
a modification only to the -LogFile argument, which has been updated to -LogDir
in the latest version of MotionCorr2. The script will modify the -LogFile argument to -LogDir.
Then, it will copy over the log files to where Cryosparc expects them to be, so that 
Cryosparc can read them and display the results properly. All other arguments
are passed as is to MotionCorr2.

