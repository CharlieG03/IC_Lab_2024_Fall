#show latency and area: also check for latch and error in 02_SYN                                                                                              
set target_file = `grep -w "set\ DESIGN" ../02*/syn.log | sed 's/set DESIGN "//; s/"$/.v/'`
grep "Total cell area:" ../02*/syn.log | sed -e 's/^[[:space:]]*/\n\/\//' >> "$target_file"
grep "Total latency" ../01*/irun.log | sed -e 's/^[[:space:]]*/\/\//' >> "$target_file"
