#/usr/bin/env bash

# OSx and linux realpath utilities are quite different. This is a bash-specific replacement:
function get_realpath() {
    [[ ! -f "$1" ]] && return 1 # failure : file does not exist.
    [[ -n "$no_symlinks" ]] && local pwdp='pwd -P' || local pwdp='pwd' # do symlinks.
    echo "$( cd "$( echo "${1%/*}" )" 2>/dev/null; $pwdp )"/"${1##*/}" # echo result.
    return 0 # success
}
# we want symlink resolution
no_symlinks='on'

_script="$(get_realpath ${BASH_SOURCE[0]})"

## Delete last component from $_script ##
_mydir="$(dirname $_script)"

export PLAN4RESROOT=${PLAN4RESROOT:-${_mydir}/..}

_p4r_completions()
{
    # Check for add-on command
    if test "${COMP_WORDS[1]}" = "add-on"; then
	ADDONS_DIR=${PLAN4RESROOT}/scripts/add-ons
	# Check for add-on options
	if test "${#COMP_WORDS[@]}" != "3"; then
	    SHOWTARGETS=1
	    # Loop over the targets to check if show only variables
	    for ((index=3 ; index<${#COMP_WORDS[@]}-1; index++)); do
		if [[ "${COMP_WORDS[${index}]}" =~ [[:lower:]] ]]; then
		    SHOWTARGETS=0
		    break
		fi
	    done
	    if test -f ${ADDONS_DIR}/${COMP_WORDS[2]}; then
		TARGETS=""
		if test "$SHOWTARGETS" = "1"; then
		    TARGETS=`grep HELP ${ADDONS_DIR}/${COMP_WORDS[2]} | grep -v printf | grep -v "####" | grep -v "VARHELP" | awk -F"\"|:" '{ gsub(/ /, "", $2);  print $2}'`
		    TARGETS+=" "
		fi
		TARGETS+=`grep VARHELP ${ADDONS_DIR}/${COMP_WORDS[2]} | grep -v printf | grep -v "####" | awk -F"\"|:|=" '{ gsub(/ /, "", $3);  print $3"="}'`
		COMPREPLY=($(compgen -W "${TARGETS}" "${COMP_WORDS[${#COMP_WORDS[@]} - 1]}"))
	    fi
	    return
	fi
	RECIPES=`find ${ADDONS_DIR} -maxdepth 1 -not -name '.*' -type f -perm -111 -print0 |xargs -0 -n1 basename`
	COMPREPLY=($(compgen -W "${RECIPES}" "${COMP_WORDS[2]}"))
	return
    fi

    if test "${#COMP_WORDS[@]}" != "2"; then
	return
    fi
    if test "${COMP_WORDS[1]}" = "-h" -o "${COMP_WORDS[1]}" = "-t" -o "${COMP_WORDS[1]}" = "-c"; then
	return
    fi
    COMPREPLY=($(compgen -W "-h -t -c add-on run-cs1 run-cs2 run-cs3" "${COMP_WORDS[1]}"))
}


OLDOPTS=$(shopt -po errexit)
set +e
complete -o nosort -F _p4r_completions p4r > /dev/null 2>&1
CHECKERR=$?
eval "$OLDOPTS"
# check if -nosort is supported
if test ${CHECKERR} -ne 0; then
    complete -F _p4r_completions p4r > /dev/null 2>&1
fi
