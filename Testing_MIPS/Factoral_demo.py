import os
import subprocess
import re

fact = int(input("Enter a number: "))

cwd = os.getcwd()
path = os.path.join(cwd,'Microprocessor')

os.chdir(path)

subprocess.run(['iverilog','-o','Fact','Main.v','Factorial_TB.v'])
result = subprocess.run(['vvp','Fact',f"+Val={fact}"],capture_output=True,text=True)
output = result.stdout

for line in output.splitlines():
    match = re.match(r"Mem\[198\]\s+:\s+(\d+)", line)
    if match: factorial = int(match.group(1))

print("The Factorial of",fact,"is:",factorial)

os.chdir(cwd)