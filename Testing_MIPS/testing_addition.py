import os
import subprocess

cwd = os.getcwd()
path = os.path.join(cwd,'Microprocessor')

os.chdir(path)

subprocess.run(['iverilog','-o','Adder','Main.v','Micro_TB.v'])
subprocess.run(['vvp','Adder'])

os.chdir(cwd)