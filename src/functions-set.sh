#!/bin/bash
## functions-set
## set functions for shed
## version 0.0.1 - initial
##################################################
slack-shed-set-output-text() { 
  {
    local output_format
    output_format="text"
  }
  set-output-format
}
#-------------------------------------------------
slack-shed-set-output-json() { 
  {
    local output_format
    output_format="json"
  }
  set-output-format
}
#-------------------------------------------------
slack-shed-set-output-clear() { 
 slack-shed-set-output-reset
}
#-------------------------------------------------
slack-shed-set-output-reset() { 
 test ! -f "set-output" || {
  rm set-output
 }
}
#-------------------------------------------------
slack-shed-set-output() { 
 commands
 test -f "set-output" && {
  cat set-output
 true
 } || {
  commands
 }
}
#-------------------------------------------------
slack-shed-set-debug-false() {
  {
    local debug
    debug="false"
  }
  set-debug
}
#-------------------------------------------------
slack-shed-set-debug-true() {
  {
    local debug
    debug="true"
  }
  set-debug
}
#-------------------------------------------------
slack-shed-set-debug() {
 commands
 test -f "set-debug" && {
  cat set-debug
 true
 } || {
  commands
 }
}
#-------------------------------------------------
slack-shed-set() {
 commands
}
##################################################
## generated by create-stub2.sh v0.1.1
## on Sun, 06 May 2018 20:26:38 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
