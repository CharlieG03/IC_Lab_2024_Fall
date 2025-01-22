#!/bin -f

# Function to display usage information
alias show_usage 'echo; echo "Usage: source c_check.csh [OPTION]"; \
echo "Options:"; \
echo "  -a, --all         Run all checks (default if no option is provided)"; \
echo "  -1, --rtl         Run only RTL simulation check"; \
echo "  -2, --syn         Run only SYN simulation check"; \
echo "  -3, --gate        Run only GATE simulation check"; \
echo "  -b, -12           Run RTL and SYN checks"; \
echo "  -c, -23           Run SYN and GATE checks, and compute performance"; \
echo "  -p, --perf        Compute performance only (use latency of RTL and area of previous SYN result)"; \
echo "  -h, --help        Display this help message and exit"; echo'

# Function for cleanup
alias cleanup 'rm -rf ~/.vim/check_*'

# Parse command line arguments
set run_rtl = 0
set run_syn = 0
set run_gate = 0
set run_perf = 0

if ($#argv == 0) then
  set run_rtl = 1
  set run_syn = 1
  set run_gate = 1
  set run_perf = 1
else
  if ("$argv[1]" == "-a" || "$argv[1]" == "--all") then
    set run_rtl = 1
    set run_syn = 1
    set run_gate = 1
    set run_perf = 1
  else if ("$argv[1]" == "-1" || "$argv[1]" == "--rtl") then
    set run_rtl = 1
  else if ("$argv[1]" == "-2" || "$argv[1]" == "--syn") then
    set run_syn = 1
  else if ("$argv[1]" == "-3" || "$argv[1]" == "--gate") then
    set run_gate = 1
  else if ("$argv[1]" == "-b" || "$argv[1]" == "--12") then
    set run_rtl = 1
    set run_syn = 1
  else if ("$argv[1]" == "-c" || "$argv[1]" == "-23") then
    set run_syn = 1
    set run_gate = 1
    set run_perf = 1
  else if ("$argv[1]" == "-p" || "$argv[1]" == "--perf") then
    set run_rtl = 1
    set run_syn = 1
    set run_perf = 2
  else if ("$argv[1]" == "-h" || "$argv[1]" == "--help") then
    show_usage
    exit 0
  else
    echo "\033[1;91mInvalid option.\033[0m"
    show_usage
    exit 1
  endif
endif

# Check RTL simulation
if ($run_rtl == 1) then
  cd ../01_RTL
  ./08_* > ~/.vim/check_rtl.log

  echo
  \cat ~/.vim/check_rtl*
  echo

  grep -i "01_RTL PATTERN PASS" ~/.vim/check_rtl.log > /dev/null
  if ($status != 0) then
    cleanup
    exit 1
  endif
endif

# Check SYN simulation
if ($run_syn == 1) then
  cd ../02_SYN
  if ($run_perf != 2) then
    if ($run_rtl == 0) then
      ./01_* # > /dev/null
    else
      ./01_* > /dev/null
    endif
  endif
  ./08_* > ~/.vim/check_syn.log

  \cat ~/.vim/check_syn*
  echo

  grep -i "02_SYN Success" ~/.vim/check_syn.log > /dev/null
  if ($status != 0) then
    cleanup
    exit 1
  endif
endif

# Check GATE simulation
if ($run_gate == 1) then
  cd ../03_GATE
  ./08_* > ~/.vim/check_gate.log

  \cat ~/.vim/check_gate*
  echo

  grep -i "03_GATE PATTERN PASS" ~/.vim/check_gate.log > /dev/null
  if ($status != 0) then
    cleanup
    exit 1
  endif
endif

# Compute the performance
if ($run_perf == 2) then
  cat ~/.vim/check_rtl.log > ~/.vim/check_gate.log
  python3 ~/.vim/fom_calculate.py
  echo
else if ($run_perf == 1) then
  python3 ~/.vim/fom_calculate.py
  echo
endif

cleanup
exit 0