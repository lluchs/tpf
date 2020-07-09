#!/usr/bin/env bash
### Usage: score.sh <file>

INPUT=${1?need input file}
OUTPUT="score-${INPUT%.json}.png"

gnuplot -e 'file = "'"$INPUT"'"' -e 'out = "'"$OUTPUT"'"' <(cat <<GNUPLOT
set term pngcairo
set output out

set xdata time
set timefmt "%Y-%m-%d"
set format x "%F"
set xtics rotate by -45

set yrange [0:10]

unset key
set title "Score"

plot sprintf("< jq -r '[.date, .score] | @tsv' '%s'", file) using 1:2 with lines
GNUPLOT
)
