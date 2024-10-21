# create a new conda environment called myenv
conda create --name myenv

# create a new conda environment called myenv using python 3.9
conda create --name myenv2 python=3.9 

# install a package in the new environment
conda install azure-identity

# can also use Pip to install packages
pip install azure-identity

# check conda environments
# note that the active environment is marked with an asterisk (*)
conda env list

# activate the new environment
conda activate dataengforfree_env

python --version

# switch environments in VS Code using the Command Palette CTRL+SHIFT+P
# relaunch the terminal to see the new environment

conda env list

python --version

conda list

# many other options are available - clone environments, remove environments, etc.
# cheat sheet: https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html