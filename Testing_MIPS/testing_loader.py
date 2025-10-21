import os
import subprocess

cwd = os.getcwd()
path = os.path.join(cwd,'Microprocessor')

os.chdir(path)

subprocess.run(['iverilog','-o','Ldr','Main.v','Loader_TB.v'])
subprocess.run(['vvp','Ldr'])

os.chdir(cwd)