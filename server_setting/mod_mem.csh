#!/bin/csh

# Loop through all Memory.lef files in the current directory
foreach file (mem*.lef)
    echo "Processing $file..."
    
    # Create a temporary file for modifications
    set tempfile = "$file.temp"
    
    # Perform the modifications
    sed -e 's/core/core_5040/g' \
        -e 's/ME1/metal1/g' \
        -e 's/ME2/metal2/g' \
        -e 's/ME3/metal3/g' \
        -e 's/ME4/metal4/g' \
        -e 's/ME5/metal5/g' \
        -e 's/ME6/metal6/g' \
        -e 's/ME7/metal7/g' \
        -e 's/ME8/metal8/g' \
        -e 's/ME9/metal9/g' \
        -e 's/VI1/via/g' \
        -e 's/VI2/via2/g' \
        -e 's/VI3/via3/g' \
        -e 's/VI4/via4/g' \
        -e 's/VI5/via5/g' \
        -e 's/VI6/via6/g' \
        -e 's/VI7/via7/g' \
        -e 's/VI8/via8/g' \
        "$file" > "$tempfile"
    
    # Replace the original file with the modified one
    mv "$tempfile" "$file"
    
    echo "Finished processing $file"
end

echo "All Memory.lef files have been modified."