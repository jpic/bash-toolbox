
#: bert(3) -- Bash-Toolbox Command Parser
#: ======================================
#:
#: ## SYNOPSIS
#:
#: `#!/usr/bin/env bash-toolbox`
#: `source bert.sh`
#:
#: ## DESCRIPTION
#:
#: This script is a library and must be used in source script file. The goal
#: is implements a lightweight interface to create a command list of commands and
#: manager.
#:
#: ## AUTHOR
#:
#: Written by Hallison Batista &lt;hallison@codigorama.com$gt;
#:
#: ## COPYRIGHT
#:
#: Copyright (C) 2009,2010 Codigorama &lt;code@codigorama.com&gt;
#:
#: Permission is hereby granted, free of charge, to any person obtaining a copy
#: of this software and associated documentation files (the "Software"), to deal
#: in the Software without restriction, including without limitation the rights
#: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#: copies of the Software, and to permit persons to whom the Software is
#: furnished to do so, subject to the following conditions:
#: 
#: The above copyright notice and this permission notice shall be included in
#: all copies or substantial portions of the Software.
#: 
#: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#: THE SOFTWARE.
#:
#: ## SEE ALSO
#:
#: [bert(1)](bert.1.html), [bert(5)](bert.5.html), [bake(1)](bake.1.html)
#:

# Timestamp: 2010-01-08 17:59:17 -04:00

# Variables for stacks
declare -a command_titles=()
declare    command_return=0
declare -a command_errors=()

# Formats
#declare  COMMAND_COMMAND="${COMMAND_COMMAND:-'* %-74s [busy]\\e[5D\\n'}"
#declare  COMMAND_COMMAND="${COMMAND_COMMAND:-\e[G* %-72s [%03d/%03d]}"
declare  COMMAND_COMMAND="${COMMAND_COMMAND:-  > %-66s [%5s]\e[6D}"
declare  COMMAND_STATUS="${COMMAND_STATUS:-* %-76s\n}"

# Aliases
alias noerrors='test ! "${command_errors[*]}"'

function = {
  test "${*}" && {
    declare new=${#command_titles[@]}

    command_titles[new]="${@}"

    eval "command_${new}=()"
  } || {
    fail $"command title is required"
    exit 1
  }
}

# Add commands in current command item.
function + {
  test "${command_titles[*]}" && {
    declare current=$(( ${#command_titles[@]} - 1 ))

    eval "command_${current}[\${#command_${current}[@]}]='${*}'"
  } || {
    fail $"command list not defined"
    exit 1
  }
}

#   no-errors && {
#     printf "%4s\n" $"done"
#     return 0
#   } || {
#     printf "%4s\n" $"fail"
#     return ${command_return}
#   }'

function @ {
  + "dump \"${1}\""
}

# Display a status message
function - {
  + "status:${*}"
}

# Run commands redirecting output to null
function pop {
  test ${#} -gt 0 && {
    declare new=${#command_errors[@]}
    eval "${@# } &> /dev/null"
    command_return=${?}
    test ${command_return} -gt 0 && command_errors[new]=${command_return}
    return ${command_return}
  } || {
    return 0
  }
}

# Dump item from current command
function dump {
  test ${#} -gt 0 && {
    declare runner="command_${1:-0}"
    declare status="busy"
    declare index

    eval "index=\${!${runner}[@]}"

    cursor --turn-off

    for i in ${index}; do
      eval "command=\${${runner}[${i}]}"
      eval "n=\${#${runner}[@]}"
      test "${command%%:*}" == "status" && {
        printf "${COMMAND_STATUS}" "${command:7:76}"
      } || {
        status="busy"
        printf "${COMMAND_COMMAND}" "${command:0:66}" "${status}"
        pop ${command}
        test ${command_return} -gt 0 && status="error" || status="done"
        printf "%5s\n" "${status}"
      }
      #printf "  \e[?25l[%03d/%03d] %-70s\e[G" "$(( i + 1 ))" "${n}" "${command:0:72}"
    done
    cursor --turn-on
    return 0
  }
}

function defined {
  test ${1} -lt ${#command_titles[@]} && return 0 || return 1
}

# vim: filetype=sh

