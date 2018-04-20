#!/bin/bash
## shed
## - export workdspace slack history
## version 0.1.1 - show stderr
## + new requirements 180418 
## requires:
## - slack.sh
##################################################
. $( dirname ${0} )/slack.sh/functions.sh
##################################################
list-available-commands-filter-exclude-list() { 
 cat << EOF
$( ${FUNCNAME}-default )
date-oldest
EOF
}
#-------------------------------------------------
slack-shed-env() {
 cat << EOF
alias shed='bash $( pwd $( dirname ${0} ) )/shed.sh'
EOF
}
#-------------------------------------------------
slack-shed-start-date() { 
 slack-shed-date-oldest ${@}
}
#-------------------------------------------------
slack-shed-date-oldest-test() {
 test "${date_oldest}"  &&
 date --date="${date_oldest}" &&
 true
}
#-------------------------------------------------
slack-shed-date-oldest() { { local date_oldest ; date_oldest="${1}" ; }
  {
    ${FUNCNAME}-test || { 
      slack-shed-help 
      { error false ; false ; }
    }
  }
  {
    for-each-channel ${date_oldest}
  } 2>/dev/null
}
#-------------------------------------------------
slack-shed-help() {
 cat << EOF
slack-shed

SUBCOMMANDS

	start-date	yyyy-mm-dd
	date-oldest	yyyy-mm-dd

	- get channel histories between now and oldest date

EOF
}
#-------------------------------------------------
slack-shed() { 
 commands
}
#-------------------------------------------------
shed() {
 slack shed ${@}
}
##################################################
if [ ! ]
then
 true
else
 exit 1 # wrong args
fi
##################################################
shed ${@}
##################################################
## generated by create-stub2.sh v0.1.0
## on Mon, 09 Apr 2018 20:05:08 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
