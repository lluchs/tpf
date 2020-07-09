#!/usr/bin/env bash
### Usage: balance.sh <file>

INPUT=${1?need input file}
OUTPUT="balance-${INPUT%.json}.png"

gnuplot -e 'file = "'"$INPUT"'"' -e 'out = "'"$OUTPUT"'"' <(cat <<GNUPLOT
set term pngcairo
set output out

set xdata time
set timefmt "%Y-%m-%d"
set format x "%F"
set xtics rotate by -45

#unset key
set title "Money"

plot sprintf("< jq -r '[.date, .balance, .loan] | @tsv' '%s'", file) using 1:2 with lines title "Balance", \
	"" using 1:3 with lines title "Loan"
GNUPLOT
)
