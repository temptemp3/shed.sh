#!/bin/bash
## entry
## - entry for shed
## version 0.0.1 - initial
##################################################
slack-shed() { 
 # - cecho
 test ! "${debug}" = "false" || {
  cecho() {
   true
  }
 }
 commands
}
#-------------------------------------------------
shed() {
 slack shed ${@}
}
##################################################
## generated by create-stub2.sh v0.1.1
## on Sun, 06 May 2018 20:59:10 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
