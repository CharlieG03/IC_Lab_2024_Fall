import re
import os

# File paths
syn_log_path = '~/.vim/check_syn.log'
gate_log_path = '~/.vim/check_gate.log'

# Function to extract cycle and area from the check_syn.log
def extract_cycle_and_area(log_path):
    # Expand the path
    log_path = os.path.expanduser(log_path)
    # Open and read the log file
    with open(log_path, 'r') as file:
        log_content = file.read()
    
    # Clean up escape sequences
    log_content = re.sub(r'\x1b\[[0-9;]*[a-zA-Z]', '', log_content)
    
    # Extracting cycle and area using regex
    cycle_match = re.search(r'Cycle:\s*([0-9]+\.[0-9]+)', log_content)
    area_match = re.search(r'Area:\s*([0-9]+\.[0-9]+)', log_content)
    
    cycle = float(cycle_match.group(1)) if cycle_match else None
    area = float(area_match.group(1)) if area_match else None
    
    return cycle, area

# Function to extract execution cycle from the check_gate.log
def extract_execution_cycle(log_path):
    # Expand the path
    log_path = os.path.expanduser(log_path)
    # Open and read the log file
    with open(log_path, 'r') as file:
        log_content = file.read()
    
    # Clean up escape sequences
    log_content = re.sub(r'\x1b\[[0-9;]*[a-zA-Z]', '', log_content)
    
    # Adjusting the regex to handle the "cycles" word after the number
    exec_cycle_match = re.search(r'Execution cycles:\s*([0-9]+)\s*cycles', log_content)
    
    exec_cycle = int(exec_cycle_match.group(1)) if exec_cycle_match else None
    
    return exec_cycle

# Extract values
cycle, area = extract_cycle_and_area(syn_log_path)
execution_cycle = extract_execution_cycle(gate_log_path)

# Calculate performance
if cycle is not None and area is not None and execution_cycle is not None:
    performance = cycle * area * execution_cycle
    print(f"\033[1;33mPerformance: {performance:.8e}\033[0m")
else:
    print("Error: Could not extract all values.")
