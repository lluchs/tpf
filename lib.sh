# stolen from https://unix.stackexchange.com/questions/364735/merge-multiple-files-with-join
xjoin() {
	local f

	if [ "$#" -lt 2 ]; then
		cat "$1"
	elif [ "$#" -lt 3 ]; then
		join "$1" "$2"
	else
		f=$1
		shift
		join "$f" <(xjoin "$@")
	fi
}
