#!/usr/bin/env bash
### Usage: vehicles.sh <file>

INPUT=${1?need input file}
OUTPUT="vehicles-${INPUT%.json}.png"

gnuplot -e 'file = "'"$INPUT"'"' -e 'out = "'"$OUTPUT"'"' <(cat <<GNUPLOT
set term pngcairo
set output out

set xdata time
set timefmt "%Y-%m-%d"
set format x "%F"
set xtics rotate by -45

set title "Vehicles"

plot sprintf("< jq -r '[.date, .vehicleTypes.RAIL.count // 0, .vehicleTypes.AIR.count // 0, .vehicleTypes.ROAD.count // 0, .vehicleTypes.SEA.count // 0] | @tsv' '%s'", file) using 1:2 with lines title "Rail", \
	"" using 1:3 with lines title "Air", \
	"" using 1:4 with lines title "Road", \
	"" using 1:5 with lines title "Sea"
GNUPLOT
)
