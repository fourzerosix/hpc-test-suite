#!/bin/bash
# Author: Dolphin Whisperer
# Email: jeremy.bell@nih.gov
# Date: 2024.11.11
# Description: This script provides a comprehensive check of the core functionalities of our miniconda3 setup.
# (i.e., basic conda functionality, environment management, python execution, package management, and cleanup.
# There are additional tests covering a range of common scientific and data analysis libraries - this can be adjusted to run w/o SLURM

#SBATCH --job-name=N!NM@D@        # Job name
#SBATCH --output=conda_test.log   # Output log file
#SBATCH --error=conda_test.err    # Error log file
#SBATCH --time=00:33:33           # Max runtime
#SBATCH --partition=all           # Partition name
#SBATCH --ntasks=1                # Number of tasks
#SBATCH --cpus-per-task=1         # CPUs per task

# Load the Miniconda3 module
module load miniconda3

# Record conda version
echo "Conda Version:"
conda --version

# List conda envs
echo "Listing Conda Environments:"
conda env list

# Create a temp test environment
TEST_ENV="conda_test_env"
echo "Creating Test Environment: $TEST_ENV"
conda create -y -n $TEST_ENV python=3.9

# Activate the test environment w/env considerations (i.e., source activate)
echo "Activating Test Environment: $TEST_ENV"
source activate $TEST_ENV

# --- Test functionality inside the environment --- #
echo "Running tests inside $TEST_ENV:"
# Basic Python test
python -c "print('Python test passed')"
# Test package installation and import
pip install requests
python -c "import requests; print('Requests test passed')"
# Test NumPy installation and functionality
pip install numpy
python -c "import numpy as np; print(f'NumPy test passed: Version {np.__version__}')"
# Test pandas installation and basic DataFrame operations
pip install pandas
python -c "import pandas as pd; df = pd.DataFrame({'col1': [1, 2], 'col2': [3, 4]}); print('Pandas test passed:', df)"
# Test matplotlib installation and basic plot creation
pip install matplotlib
python -c "import matplotlib.pyplot as plt; plt.figure(); print('Matplotlib test passed')"
# Test SciPy installation and a basic computation
pip install scipy
python -c "from scipy.optimize import minimize; res = minimize(lambda x: x**2, 0.0); print(f'SciPy test passed: {res.success}')"
# Test OpenCV installation and basic usage
pip install opencv-python-headless
python -c "import cv2; print(f'OpenCV test passed: Version {cv2.__version__}')"

# Deactivate and remove the test environment
echo "Deactivating and Removing Test Environment: $TEST_ENV"
conda deactivate
conda env remove -y -n $TEST_ENV

# 10-4
echo "Conda Tests Completed. There are NO SNAKES ON THIS PLANE."
