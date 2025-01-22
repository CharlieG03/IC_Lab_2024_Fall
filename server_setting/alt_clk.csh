#!/bin/csh -f

# Check if the user provided an argument (new value for CYCLE_TIME)
if ($#argv != 1) then
  echo "Usage: source change_clk.csh <num>"
  exit 1
endif

# Store the new value from the argument
set new_cycle = $argv[1]

# Validate if the new_cycle is a number (integer or floating point)
# This uses 'echo' with awk to check for a valid number
echo $new_cycle | awk '/^[+-]?[0-9]+([.][0-9]+)?$/ { exit 0 } { exit 1 }'
if ($status != 0) then
  echo "Error: $new_cycle is not a valid number."
  exit 1
endif

# Extract the current CYCLE_TIME value and remove any carriage return from PATTERN.v
set old_cycle_pat = `grep "define CYCLE_TIME" ../00_TESTBED/PATTERN.v | sed "s/.*define CYCLE_TIME \([0-9.]\+\).*/\1/" | tr -d '\r'`
if ($status != 0 || $old_cycle_pat == "") then
  echo "Error: Could not extract current CYCLE_TIME value from PATTERN.v"
  exit 1
endif

# Use sed to replace the current value of CYCLE_TIME with the new value
sed -i.bak "s/\(define CYCLE_TIME \)[0-9.]\+/\1$new_cycle/" ../00_TESTBED/PATTERN.v

if ($status == 0) then
  echo
  echo "Successfully updated CYCLE_TIME in PATTERN.v"
  echo "Cycle period changed from $old_cycle_pat to $new_cycle"
else
  echo "Error: Failed to update PATTERN.v"
  exit 1
endif

# Extract the current CYCLE value and remove any carriage return from syn.tcl
set old_cycle_tcl = `grep "set CYCLE" ../02_SYN/syn.tcl | sed "s/set CYCLE \([0-9.]\+\).*/\1/" | tr -d '\r'`
if ($status != 0 || $old_cycle_tcl == "") then
  echo "Error: Could not extract current CYCLE value from syn.tcl"
  exit 1
endif

# Use sed to replace the CYCLE value in syn.tcl
sed -i.bak "s/set CYCLE [0-9.]\+/set CYCLE $new_cycle/" ../02_SYN/syn.tcl

if ($status == 0) then
  echo
  echo "Successfully updated CYCLE in syn.tcl"
  echo "Cycle period changed from $old_cycle_tcl to $new_cycle"
else
  echo "Error: Failed to update syn.tcl"
  exit 1
endif
echo
exit 0
