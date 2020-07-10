#!/usr/bin/env bash
### Usage: balance.sh <file> <name> ...

. ./lib.sh

OUTPUT=${OUTPUT:-balance.svg}

args=()
names=()
while (($# >= 1)); do
	args+=('<(jq -r "[.date, .balance - .loan] | @tsv" "'$1'")')
	n=$(basename ${1%.*})
	names+=("$n")
	shift
done

tmpfile=$(mktemp)
{
	echo date ${names[@]}
	eval xjoin "${args[@]}"
} > "$tmpfile"

cat "$tmpfile"

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
