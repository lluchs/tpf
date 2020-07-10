#!/usr/bin/env bash
### Usage: vehicles.sh <file> ...

. ./lib.sh

OUTPUT=${OUTPUT:-vehicles.svg}

args=()
names=()
while (($# >= 1)); do
	args+=('<(jq -r "[.date, .vehicleTypes.RAIL.count // 0, .vehicleTypes.AIR.count // 0, .vehicleTypes.ROAD.count // 0, .vehicleTypes.SEA.count // 0] | @tsv" "'$1'")')
	n=$(basename ${1%.*})
	names+=("$n/Rail" "$n/Air" "$n/Road" "$n/Sea")
	shift
done

tmpfile=$(mktemp)
{
	echo date ${names[@]}
	eval xjoin "${args[@]}"
} > "$tmpfile"

gnuplot -e 'file = "'"$tmpfile"'"' -e 'out = "'"$OUTPUT"'"' <(cat <<GNUPLOT
set term svg
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
