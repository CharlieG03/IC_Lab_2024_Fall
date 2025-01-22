#show latency and area: also check for latch and error in 02_SYN                                                                                              
echo "                  ____                 _ _   "
echo "                 |  _ \ ___  ___ _   _| | |_ "
echo "                 | |_) / _ \/ __| | | | | __|"
echo "                 |  _ <  __/\__ \ |_| | | |_ "
echo "                 |_| \_\___||___/\__,_|_|\__|"
echo "\033[30;47m===============================================================\033[0m"
grep -w "set\ DESIGN" ../02*/syn.log | sed 's/set DESIGN "/Current Design: /; s/"$/\.sv/'
echo "\033[30;41m                             Area                              \033[0m"
grep "Total cell area:" ../02*/syn.log | sed -e 's/^[[:space:]]*//'
echo "\033[30;46m                            Latency                            \033[0m"
grep "Total latency" ../01*/irun.log | sed -e 's/^[[:space:]]*//'
grep "slack" ../02*/syn.log | sed -e 's/^[[:space:]]*//'
echo "\033[30;44m                         Critical path                         \033[0m"
grep "Startpoint:" ../02*/syn.log | sed -e 's/^[[:space:]]*//'
grep "Endpoint:" ../02*/syn.log | sed -e 's/^[[:space:]]*//'
echo "\033[30;43m                        Latch and Error                        \033[0m"
grep -i latch ../02*/syn.log || echo "\033[1;5;32m                        No latch found                         \033[0m"
echo "\033[30;37m---------------------------------------------------------------\033[0m"
grep -i error ../02*/syn.log || echo "\033[1;5;32m                        No error found                         \033[0m"
echo "\033[30;47m===============================================================\033[0m"
