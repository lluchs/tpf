#!/usr/bin/env bash
### Usage: balance.sh <file> <name> ...

OUTPUT="graph/balance.svg"

args=()
names=()
while (($# >= 2)); do
	args+=('<(jq -r "[.date, .balance - .loan] | @tsv" "'$1'")')
	shift
	names+=("$1")
	shift
done

tmpfile=$(mktemp)
{
	echo date ${names[@]}
	eval join "${args[@]}"
} > "$tmpfile"

gnuplot -e 'file = "'"$tmpfile"'"' -e 'out = "'"$OUTPUT"'"' <(cat <<GNUPLOT
set term svg
set output out

set xdata time
set timefmt "%Y-%m-%d"
set format x "%F"
set xtics rotate by -45

set key autotitle columnhead
set title "Money"

plot for [col=2:*] file using 1:col with lines

GNUPLOT
)

rm "$tmpfile"
