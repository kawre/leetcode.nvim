#!/usr/bin/env bash
# Runs the test files at once on every core, and shows how far they are as
# they run. Under LuaCov when COVERAGE is set.
#
#   [##########..........]  362/727 cases  50%  0:41  test_view 120/200, test_fuzz 31/70
#
# In a terminal the line updates in place; elsewhere, such as CI, a new one
# comes every PROGRESS_EVERY seconds. A file that passes takes one line at the
# end; one that fails or runs past the limit shows what failed and the last
# cases before it, and keeps its whole log in .tests/logs.
#
#   scripts/run_tests.sh <jobs> <timeout> <nvim command...>
#
# `make test` and `make coverage` call it. Exits 1 when a file failed
# or ran too long.

set -u

logs=.tests/logs

# One file, as each of the parallel runs: `--one <file> <timeout> <nvim...>`.
if [[ ${1:-} == --one ]]; then
	file=$2 limit=$3
	shift 3
	log=$logs/$(basename "$file").log
	if TEST_TRACE=1 timeout "$limit" \
		"$@" -c "lua MiniTest.run_file(\"$file\")" >"$log" 2>&1; then
		echo ok >"$log.status"
	else
		echo "!! $file failed or ran past $limit" >>"$log"
		echo failed >"$log.status"
	fi
	exit 0
fi

jobs=$1 limit=$2
shift 2
nvim_test=("$@")

mkdir -p "$logs"
every=${PROGRESS_EVERY:-10}

# Every case of every file, to measure against.
total=$("${nvim_test[@]}" -c 'lua io.stdout:write(#MiniTest.collect() .. "\n")' -c 'qa!' 2>/dev/null | tail -n 1)
[[ $total =~ ^[0-9]+$ ]] || total=0

# A case is done when its trace line ends in Pass or Fail.
done_in() {
	sed 's/\x1b\[[0-9;]*m//g' "$1" 2>/dev/null | grep -acE ': (Pass|Fail)( with notes)?$'
}
total_in() {
	sed 's/\x1b\[[0-9;]*m//g' "$1" 2>/dev/null | grep -aom1 'Total number of cases: [0-9]*' | grep -o '[0-9]*$'
}

rm -f "$logs"/*.log "$logs"/*.status
start=$(date +%s)

# The largest first, so the cores finish together.
ls -S tests/test_*.lua | xargs -P "$jobs" -I{} "$0" --one {} "$limit" "${nvim_test[@]}" &
runner=$!

progress() {
	local done=0 running=() file log d t width=20 filled bar pct elapsed
	for log in "$logs"/*.log; do
		[[ -e $log ]] || continue
		d=$(done_in "$log")
		done=$((done + d))
		if [[ ! -e $log.status ]]; then
			t=$(total_in "$log")
			file=$(basename "$log" .lua.log)
			running+=("$file ${d}/${t:-?}")
		fi
	done
	if ((total > 0)); then
		pct=$((done * 100 / total))
		filled=$((done * width / total))
	else
		pct=0 filled=0
	fi
	bar=$(printf '%*s' "$filled" '' | tr ' ' '#')$(printf '%*s' "$((width - filled))" '' | tr ' ' '.')
	elapsed=$(($(date +%s) - start))
	local list
	list=$(printf '%s, ' "${running[@]}")
	printf '[%s] %4d/%d cases %3d%%  %d:%02d  %s' "$bar" "$done" "$total" "$pct" \
		$((elapsed / 60)) $((elapsed % 60)) "${list%, }"
}

if [[ -t 1 ]]; then
	while kill -0 "$runner" 2>/dev/null; do
		printf '\r\033[K%s' "$(progress)"
		sleep 1
	done
	printf '\r\033[K%s\n' "$(progress)"
else
	last=0
	while kill -0 "$runner" 2>/dev/null; do
		now=$(date +%s)
		if ((now - last >= every)); then
			echo "$(progress)"
			last=$now
		fi
		sleep 1
	done
	echo "$(progress)"
fi
wait "$runner"

failed=0
for log in "$logs"/*.log; do
	file=tests/$(basename "$log" .log)
	if [[ $(cat "$log.status" 2>/dev/null) == ok ]]; then
		echo "ok $file: $(sed 's/\x1b\[[0-9;]*m//g' "$log" | grep -a '^Fails' | tail -n 1)"
	else
		failed=1
		# What failed, and the last cases before it: the whole log is on disk.
		clean=$(sed 's/\x1b\[[0-9;]*m//g' "$log")
		echo "== $file"
		echo "$clean" | grep -aE '^\[[0-9:]+\]|^[ox]\[' | grep -av 'Executing' | tail -n 15
		echo "$clean" | sed -n '/^Fails (/,$p'
		echo "   (whole log: $log)"
	fi
done
exit $failed
