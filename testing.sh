#!/bin/bash
## testing
## version 0.3.1 - Fix date format
##################################################
## objective:
## + implement
## ++ get-user-channel-history
## +++ taking arguments
## ++++ 1) start-date
## ++++ 2) user_id (member_id)
## ++++ 3-optional) channel_ids..
## ++ get-user-channel-history-for-today
## +++ taking arguments
## ++++ 1) user_id
## ++++ 2-optional) channel_ids..
##################################################
shopt -s expand_aliases
alias sed-escape-slash='sed -e "s/\([/]\)/\\\\\1/g"'
escape-slash() {
  {
    echo ${@} 
  } | sed-escape-slash
}
slack-shed-test-escape-slash() {
 escape-slash ${@}
}
## testing
#$ shed test escape-slash 01/17/18 13:03
#01\/17\/18 13:03
#-------------------------------------------------
# version 0.0.2 - using double quotes
date-today() {
 date "+%Y-%m-%d"
}
#-------------------------------------------------
alias test-member-id='
{
 test "${member_id}" || {
  {
    echo 
    echo member id not specified
    echo 
    ${FUNCNAME}-help
  } 1>&2
  error "false" # hide error
  false
 }
}
'
#-------------------------------------------------
slack-shed-get-user-channel-history-for-today-help() {
 cat << EOF
shed get user-channel-history-for-today

- return channel history for a single user since beginning of day for one or more channels

shed-get-user-channel-history member_id [channel_ids..]

REQUIRED

1  - member id (U1234567890)

OPTIONAL

2- - channel ids (C123456779889 C..)
EOF
}
#-------------------------------------------------
slack-shed-get-user-channel-history-for-today() { { local member_id ; member_id="${1}" ; local channel_ids ; channel_ids=${@:2} ; }
  test-member-id
  { 
    slack-shed-get-user-channel-history \
    $( date-today ) \
    ${member_id} \
    ${channel_ids}
  }
}
#-------------------------------------------------
slack-shed-get-user-channel-history-help() { 
 cat << EOF
shed get user-channel-history

- return channel history for a single user since start date for one or more channels

shed-get-user-channel-history start_date member_id [channel_ids..]

REQUIRED

1  - start date (yyyy-mm-dd)

2  - member id (U1234567890)

OPTIONAL

3- - channel ids (C123456779889 C..)
EOF
}
#-------------------------------------------------
slack-shed-get-user-channel-history() { { local date_oldest ; date_oldest="${1}" ; local member_id ; member_id="${2}" ; local channel_ids ; channel_ids=${@:3} ; }
 test-member-id
 {
   local member_ids
   member_ids="\"${member_id}\""
 }
 slack-shed-date-oldest ${date_oldest} ${channel_ids}
}
#-------------------------------------------------
slack-shed-get() {
 commands
}
##################################################
## objective:
## + map username to user id
##################################################
list-users-payload() { 
 slack-users-list
}
list-users() { 
 local candidate_key
 candidate_key=${cache}/temp-${FUNCNAME}
 cache \
 ${candidate_key} \
 ${FUNCNAME}-payload
}
get-user-id-payload() { 
 list-users | jq "
.members[]|
if ..|.${candidate_field}? == \"${candidate_value}\"
then
.id
else
empty
end
"
}
get-user-id-test() { 
 test "${candidate_field}" # error handler not yet implemented
 test "${candidate_value}" # error handler not yet implemented
}
get-user-id() { { local candidate_field ; candidate_field="${1}" ; local candidate_value ; candidate_value="${@:2}" ; }
 ${FUNCNAME}-test
 ${FUNCNAME}-payload | sort | uniq
}
slack-shed-test-get-user-id() {
 get-user-id ${@}
}
slack-shed-test-list-users() {
 list-users 
}
##################################################
## objective:
## + implement feature to change output format
## +++ -v (verbose) => set output verbose
## ++++ option to return json
## ++++ by default, return csv
## "channel", "username", "date-time", "text" 
#-------------------------------------------------
## aliases
shopt -s expand_aliases # alias expansion
## sed
alias sed-strip-double-quotes='sed -e "s/\"//g"'
#-------------------------------------------------
# import
# - cache
declare -f cache &>/dev/null || { 
 . $( find $( dirname ${0} ) -name cache.sh ) 
}
# - cecho
declare -f cecho &>/dev/null || { 
  {
    . $( find $( dirname ${0} ) -name cecho.sh ) 
  } &>/dev/null
}
#-------------------------------------------------
alias slack-shed-set-output-format='
 echo ${output_format} > set-output
'
#-------------------------------------------------
slack-shed-set-output-text() { 
  {
    local output_format
    output_format="text"
  }
  slack-shed-set-output-format
}
#-------------------------------------------------
slack-shed-set-output-json() { 
  {
    local output_format
    output_format="json"
  }
  slack-shed-set-output-format
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
alias slack-shed-debug-setter='
 echo ${debug} > set-debug
'
#-------------------------------------------------
slack-shed-set-debug-false() {
  {
    local debug
    debug="false"
  }
  slack-shed-debug-setter
}
#-------------------------------------------------
slack-shed-set-debug-true() {
  {
    local debug
    debug="true"
  }
  slack-shed-debug-setter
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
#-------------------------------------------------
strip-double-quotes() {
  {
    echo ${@} \
    | sed -e 's/"//g'
  }
}
#-------------------------------------------------
slack-shed-start-date() { 
 slack-shed-date-oldest ${@}
}
#-------------------------------------------------
slack-shed-date-oldest-test() { 
 test "${date_oldest}"  &&
 date --date="${date_oldest}" &>/dev/null &&
 true
}
#-------------------------------------------------
# slack-shed-date-oldest
# - returns message since date specified
# version 0.0.2 - for-each-channel inheriting context
#-------------------------------------------------
slack-shed-date-oldest() { { local date_oldest ; date_oldest="${1}" ; local channel_ids ; channel_ids=${@:2} ; { test "${channel_ids}" || { channel_ids="all" ; } ; } ; }
  {
    ${FUNCNAME}-test || { 
      slack-shed-help 
      { error false ; false ; }
    }
  }
  {
    for-each-channel #${date_oldest}
  } #2>/dev/null
}
#-------------------------------------------------
slack-users-info-case() { 
  case ${field} in 
   ts) {
    echo ${users_info} | jq '.["user"]["real_name"]'
   } ;;
   real-name) {
    echo ${users_info} | jq '.["user"]["real_name"]'
   } ;;
   *) {
    echo ${users_info}
   } ;;
  esac
}
#-------------------------------------------------
# + caching
slack-users-info() { { local user ; user="${1}" ; local field ; field="${2}" ; }

  test "${user}"

  {
    local method_url
    method_url="https://slack.com/api/users.info"
    local method_query
    method_query="user=$( trim ${user} )&pretty=1"
  }

  local users_info
  users_info=$(
   slack-api-call
  )

  {
    #cache \
    #"${cache}/${FUNCNAME}-${user}-${field}" \
    "${FUNCNAME}-case"
  }
}
#-------------------------------------------------
slack-shed-test-list-channels() {
 list-channels ${@}
}
#-------------------------------------------------
# version 0.0.2 - csv,text synonyms
list-channels() { { local output ; output=${1-csv} ; }
 case ${output} in
  json) {
   get-channels
  } ;;
  csv) {
   get-channels-csv
  } ;;
  text) {
   get-channels-csv
  } ;;
  text-names|names) {
   get-channel-names
  } ;;
  text-ids|ids) {
   get-channel-ids
  } ;;
  *) {
   error "unsupported output '${output}'" "" ""
   false
  } ;;
 esac
}
#-------------------------------------------------
slack-shed-test-get-channel-ids() {
 get-channel-ids | sed-strip-double-quotes
}
#-------------------------------------------------
slack-shed-test() {
 commands
}
#-------------------------------------------------
# version 0.0.3 - case all cecho starting
for-each-channel-get-user-channel-history-payload-channels() {
 test ! "${channel_ids}" = "all" || {
  cecho green getting all channel ids..
  channel_ids=$( 
   get-channel-ids | sed-strip-double-quotes
  )
 }
 cecho yellow channel_ids: ${channel_ids}
}
#-------------------------------------------------
get-user-channels-history() { { local candidate_id ; candidate_id="${1}" ; }
  test "${candidate_id}" || {
   error "empty member id" "${funcname}" "${lineno}"
   false
  }
  { 
    local api_method
    api_method="channels.history"
    local query
    query="
.messages[]|
if .user == ${candidate_id} 
then 
(
  . + {\"channel\":\"${channel}\"}
)
else 
empty
end
"
  }
  slack-api-query
}
## testing
#echo testing get-user-channels-history ... 1>&2
#set -v -x
#channel="channel"
#get-user-channels-history "U8D6NBMGT"
#cat temp-get-user-channels-history
#exit
alias setup-user-channel-history='
{
  local user_channel_history
  user_channel_history=$( 
    get-user-channels-history ${member_id} 
  )
}
'
slack-channels-history-empty-query() { 
  {
    cat temp-slack-channels-history \
    | jq '.messages|length'
  }
}
slack-channels-history-empty() { 
 test ! $( ${FUNCNAME}-query ) -eq 0
}
alias for-each-channel-get-user-channel-history-payload-on-empty-channel=' 
{ 
  slack-channels-history-empty || {
    {
      cecho white empty channel history 
      cecho white next
    } 1>&2
    continue
  }
}
'
alias for-each-channel-get-user-channel-history-payload-on-empty-user-channel='
{
  test "${user_channel_history}" || {
    {
      cecho white empty user channel history 
      cecho white next
    } 1>&2
    continue
  }
}
'
#-------------------------------------------------
# version 0.0.2 - using channel_ids
for-each-channel-get-user-channel-history-payload() { 

 ${FUNCNAME}-channels # ${channel_ids}

 local channel
 for channel in ${channel_ids}
 do

  cecho yellow channel: ${channel} 1>&2 

  { # initialize channel history
    slack-channels-history ${date_oldest} # > temp-slack-channels-history
  } 1>/dev/null

  for-each-channel-get-user-channel-history-payload-on-empty-channel # continue on empty channel history

  ## test has more true case 

  cecho yellow member_ids: ${member_ids}
 
  local member_id
  for member_id in ${member_ids}
  do

   cecho yellow member_id: ${member_id} 1>&2

   setup-user-channel-history # ${user_channel_history} > temp-get-user-channels-history
   
   for-each-channel-get-user-channel-history-payload-on-empty-user-channel # continue on empty user channel history

   echo ${user_channel_history} | jq '.' 

  done

 done 

}
#-------------------------------------------------
# + caching 
for-each-channel-get-user-channel-history() {
  cecho green [ begin ${FUNCNAME}
  {
    #cache \
    #"${cache}/${FUNCNAME}" \
    "${FUNCNAME}-payload"
  }

  cecho green end of ${FUNCNAME} ]
}
#-------------------------------------------------
# ! only retrieves top level user field
for-each-channel-convert-user-ids-get-unique-user-ids-prior() {
  {
    jq '.[]["user"]' temp-user-channel-history 
  }
}
#-------------------------------------------------
for-each-channel-convert-user-ids-get-unique-user-ids-using-grep() {
  {
    grep -e '\"U[^"]*.' --only-matching temp-user-channel-history
  }
}
#-------------------------------------------------
for-each-channel-convert-users-ids-get-unique-user-ids-experimental() {
 #    echo ${user_channel_history} \
 #    | jq '.[]["user"]' 
 #    echo ${user_channel_history} \
 #    | jq '.[]["replies"]["user"]' 
 #    echo ${user_channel_history} \
 #    | jq '.[]["reactions"]["users"]' 
 true
}
#-------------------------------------------------
for-each-channel-convert-user-ids-get-unique-user-ids() {
  {
    #${FUNCNAME}-prior 
    ${FUNCNAME}-using-grep
  } \
  | sort \
  | uniq \
  | sed -e 's/null//g'
}
## testing
#jq '.' temp-user-channel-history 
#echo --- prior
#for-each-channel-get-unique-user-ids-prior # < temp-user-channel-history
#echo --- using-grep
#for-each-channel-get-unique-user-ids-using-grep # < temp-user-channel-history
#echo --- prod
#for-each-channel-get-unique-user-ids # < temp-user-channel-history
#exit
#-------------------------------------------------
alias setup-user-real-name='
{
  user_real_name=$(
   slack-users-info ${user} real-name 
  )
}
'
#-------------------------------------------------
setup-ts-date-case-default() {
 echo "+%m/%d/%y %H:%M"
}
#-------------------------------------------------
setup-ts-date-case() {
 case ${date_output_format} in
  default|mmddyyhhmm) { 
   ${FUNCNAME}-default
  } ;;
  # other formats
  *) {
   ${FUNCNAME}-default
  } ;;
 esac
}
#-------------------------------------------------
# version 0.0.2 - setup-ts-date as function
setup-ts-date() {
  # debug
  cecho yellow ts: ${ts}
  cecho yellow ts_trim: $( trim ${ts} )
  ts_date=$( 
   escape-slash $( 
    date --date="@$( trim ${ts} )" "$( ${FUNCNAME}-case )" 
   )
  )
  cecho yellow ts_date: ${ts_date}
}
#-------------------------------------------------
for-each-channel-convert-tss-get-prior() { 
  cat temp-user-channel-history \
  | jq '.[]["ts"]' \
  | sort \
  | uniq \
  | sed -e 's/null//g'
}
#-------------------------------------------------
for-each-channel-convert-tss-get-using-grep() { 
  {
    cat temp-user-channel-history \
	    | grep -e '"ts":\s"[^"]*.' --only-matching || true
  } \
  | cut '-f2' '-d:'
}
#-------------------------------------------------
for-each-channel-convert-tss-get() { 
  {
    #${FUNCNAME}-prior
    ${FUNCNAME}-using-grep
  } \
  | sort \
  | uniq
}
## testing
#cat temp-user-channel-history
#for-each-channel-get-tss
#exit
#-------------------------------------------------
# version 0.0.2 - setup-ts-date documentation
for-each-channel-convert-tss() { 

 #------------------------------------------------
 ## get list of tss
 local tss
 tss=$(
  ${FUNCNAME}-get
 )
 #{ # debug tss
 #  echo tss: ${tss} 
 #} 
 #------------------------------------------------

 #------------------------------------------------
 ## replace ts w/ date
 local ts
 local ts_date
 for ts in ${tss}
 do

  setup-ts-date # ${ts_date} (= 02\/06\/18 02:27)

  #-----------------------------------------------
  ## debug ts to ts_date conversion
  #set -v -x 
  #{
    sed -i -e "s/${ts}/\"${ts_date}\"/g" temp-user-channel-history-copy
  #} 2>&1
  #set +v +x
  #-----------------------------------------------

 done
 #------------------------------------------------

 #------------------------------------------------
 #{ # debug post ts replacement
 #  cat temp-user-channel-history-copy | jq '.'
 #}
 #------------------------------------------------

}
#-------------------------------------------------
for-each-channel-convert-user-ids() {

 #------------------------------------------------
 # start replacing user ids
 #------------------------------------------------
 ## get list of unique users
 local unique_users
 unique_users=$(
  ${FUNCNAME}-get-unique-user-ids # < temp-user-channel-history
 )
 #{ # debug unique users 
 #  echo unique_users: ${unique_users} 
 #}
 #------------------------------------------------

 #------------------------------------------------
 ## replace user w/ user real_name in user channel history
 local user 
 local user_real_name
 for user in ${unique_users} 
 do

  setup-user-real-name

  #{ # debug user(id,real_naem)
  #  echo ${user} 
  #  echo ${user_real_name} 
  #} 

  sed -i -e "s/${user}/${user_real_name}/g" temp-user-channel-history-copy

  ##----------------------------------------------
  ## debug text user id to real name conversion
  #set -v -x
  #{
    sed -i -e "s/<@$( strip-double-quotes ${user} )>/$( strip-double-quotes ${user_real_name} )/g" temp-user-channel-history-copy
  #} 2>&1
  #set +v +x
  ##----------------------------------------------

 done
 #{ # debug post user id replacement
 #  cat temp-user-channel-history-copy | jq '.'
 #}
 #------------------------------------------------
 # end replacing user ids
 #------------------------------------------------

}
#-------------------------------------------------
for-each-channel-convert() { 
 ${FUNCNAME}-user-ids
 ${FUNCNAME}-tss
}
#-------------------------------------------------
alias setup-global-user-channel-history='
{
  local user_channel_history 
  user_channel_history=$( 
   for-each-channel-get-user-channel-history \
   | tee temp-user-channel-history
  )
}
'
#-------------------------------------------------
for-each-channel-output-json() { 
 cat temp-user-channel-history-copy \
 | jq '.[]'
}
#-------------------------------------------------
for-each-channel-output-text() { 
 cat temp-user-channel-history-copy \
 | jq '
 .[]|[.["channel"],.["user"],.["ts"],.["text"]]|join(",")
'
}
#-------------------------------------------------
for-each-channel-output() { 
 commands
}
#-------------------------------------------------
# for-each-channel
# - do something on each channel
# + currently fectching user channel history
# version 0.0.5 - inherit channel ids
#-------------------------------------------------
for-each-channel() { #{ local date_oldest ; date_oldest="${1}" ; local channel_ids ; channel_ids=${@:2} ; { test "${channel_ids}" || { channel_ids="all" ; } ; } ; }

 { # debug
  cecho green in ${FUNCNAME}
  cecho yellow date_oldest: ${date_oldest}
  cecho yellow channel_ids: ${channel_ids}
 } 
       
 setup-global-user-channel-history # ${user_channel_history} > temp-user-channel-history

 # test empty user channel history

 { # convert messages to array
   sed -e 's/^}/},/' -e '$s/.*/}]/' -e '1s/.*/[{/' temp-user-channel-history  
 } > temp-user-channel-history-copy
 
 ${FUNCNAME}-convert # (user ids, tss)

 ${FUNCNAME}-output ${output_format}

}
##################################################
## generated by create-stub2.sh v0.1.1
## on Sat, 21 Apr 2018 09:05:08 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
