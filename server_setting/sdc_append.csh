#!/bin/csh

# Copy the file
cp ../02_SYN/Netlist/TMIP_SYN.sdc CHIP.sdc

# Check if the copy was successful
if ($status != 0) then
    echo "Error: Failed to copy TMIP_SYN.sdc to CHIP.sdc"
    exit 1
endif

# Comment out specified lines
sed -i.bak \
    -e 's/^set_wire_load_mode/#set_wire_load_mode/' \
    -e 's/^set_wire_load_model/#set_wire_load_model/' \
    CHIP.sdc

# Check if sed command was successful
if ($status != 0) then
    echo "Error: Failed to modify CHIP.sdc"
    exit 1
endif

echo "CHIP.sdc has been created and modified successfully."

# Copy the file
cp CHIP.sdc CHIP_cts.sdc

# Check if the copy was successful
if ($status != 0) then
    echo "Error: Failed to copy CHIP.sdc to CHIP_cts.sdc"
    exit 1
endif

# Comment out specified lines
sed -i.bak \
    -e 's/^set_clock_uncertainty/#set_clock_uncertainty/' \
    -e 's/^set_clock_transition/#set_clock_transition/' \
    CHIP_cts.sdc

# Check if sed command was successful
if ($status != 0) then
    echo "Error: Failed to modify CHIP_cts.sdc"
    exit 1
endif

echo "CHIP_cts.sdc has been created and modified successfully."