#!/usr/bin/env bash
### Usage: vehicles.sh <file> <name> ...

OUTPUT="graph/vehicles.png"

args=()
names=()
while (($# >= 2)); do
	args+=('<(jq -r "[.date, .vehicleTypes.RAIL.count // 0, .vehicleTypes.AIR.count // 0, .vehicleTypes.ROAD.count // 0, .vehicleTypes.SEA.count // 0] | @tsv" "'$1'")')
	shift
	names+=("$1/Rail" "$1/Air" "$1/Road" "$1/Sea")
	shift
done

tmpfile=$(mktemp)
{
	echo date ${names[@]}
	eval join "${args[@]}"
} > "$tmpfile"

gnuplot -e 'file = "'"$tmpfile"'"' -e 'out = "'"$OUTPUT"'"' <(cat <<GNUPLOT
set term pngcairo
set output out

set xdata time
set timefmt "%Y-%m-%d"
set format x "%F"
set xtics rotate by -45

set key autotitle columnhead
set title "Vehicles"

plot for [col=2:*] file using 1:col with lines
GNUPLOT
)

rm "$tmpfile"
