#!/bin/bash
## testing
## version 0.1.0 - verbose initial
## + new requirements 180418 
## ++ new feature: verbose option 
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
declare -f cache &>/dev/null || { # caching
 . $( find $( dirname ${0} ) -name cache.sh ) 
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
    output_format="text"
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
# ! not modified
slack-shed-start-date() { 
 slack-shed-date-oldest ${@}
}
#-------------------------------------------------
# ! not modified
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
# ! not modified
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
    cache \
    "${cache}/${FUNCNAME}-${user}-${field}" \
    "${FUNCNAME}-case"
  }
}
#-------------------------------------------------
for-each-channel-get-user-channel-history-payload-channels() {
 test "${channel_ids}" = "all" && {
  get-channel-ids | sed-strip-double-quotes
 true 
 } || {
  echo ${channel_ids}
 }
}
#-------------------------------------------------
for-each-channel-get-user-channel-history-payload() { 
 cat << EOF
[
EOF
 local channel
 local channels
 channels=$( ${FUNCNAME}-channels )
 echo "channels: ${channels}" 1>&2
 for channel in ${channels}
 do
  slack-channels-history ${date_oldest} 1>/dev/null
  local member_id
  for member_id in ${member_ids}
  do
   setup-user-channel-history
   test ! "${user_channel_history}" || {
    ## replace with user channel history function name later
    {
      echo ${user_channel_history} \
      | jq '
if .["type"] == "message" and .["subtype"]|not
then
.
else
 empty
end
'
    }
   }
  done
 done | sed -e 's/^[}]$/},/'
 cat << EOF
{}
]
EOF
}
#-------------------------------------------------
# + caching 
for-each-channel-get-user-channel-history() {
  {
    #cache \
    #"${cache}/${FUNCNAME}" \
    "${FUNCNAME}-payload"
  }
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
alias setup-ts-date='
{

  ts_date=$( date --date="@$( trim ${ts} )" )
}
'
alias setup-global-user-channel-history='
{
  local user_channel_history 
  user_channel_history=$( 
   ${FUNCNAME}-get-user-channel-history \
   | tee temp-user-channel-history \
   | tee temp-user-channel-history-transformed 
  )
}
'
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

  setup-ts-date

  ## debug ts,ts_date
  #echo ${ts} 1>&2
  #echo ${ts_date} 1>&2

  #-----------------------------------------------
  ## debug ts to ts_date conversion
  #set -v -x 
  #{
    sed -i -e "s/${ts}/\"${ts_date}\"/g" temp-user-channel-history-transformed
  #} 2>&1
  #set +v +x
  #-----------------------------------------------

 done
 #------------------------------------------------

 #------------------------------------------------
 #{ # debug post ts replacement
 #  cat temp-user-channel-history-transformed | jq '.'
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

  sed -i -e "s/${user}/${user_real_name}/g" temp-user-channel-history-transformed

  ##----------------------------------------------
  ## debug text user id to real name conversion
  #set -v -x
  #{
    sed -i -e "s/<@$( strip-double-quotes ${user} )>/$( strip-double-quotes ${user_real_name} )/g" temp-user-channel-history-transformed
  #} 2>&1
  #set +v +x
  ##----------------------------------------------

 done
 #{ # debug post user id replacement
 #  cat temp-user-channel-history-transformed | jq '.'
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
# for-each-channel
# - do something on each channel
# + currently fectching user channel history
# version 0.0.5 - inherit channel ids
for-each-channel() { #{ local date_oldest ; date_oldest="${1}" ; local channel_ids ; channel_ids=${@:2} ; { test "${channel_ids}" || { channel_ids="all" ; } ; } ; }

 #{ # debug
 # echo ${FUNCNAME}
 # echo date_oldest: ${date_oldest}
 # echo channel_ids: ${channel_ids}
 #}
       
 ## depreciated may remove later
 #{ local function_name ; function_name="${1}" ; }
 
 setup-global-user-channel-history

 ${FUNCNAME}-convert # (user ids, tss)

 ## expect
 cat temp-user-channel-history-transformed | jq '.'
 # > temp-user-channel-history-transformed

}
#-------------------------------------------------
#testing() {
# true
#}
##################################################
#if [ ${#} -eq 0 ] 
#then
# true
#else
# exit 1 # wrong args
#fi
##################################################
#testing
##################################################
## generated by create-stub2.sh v0.1.1
## on Sat, 21 Apr 2018 09:05:08 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
