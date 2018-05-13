#!/bin/bash
## testing
## version 0.2.1 - allow real names and channels
#################################################
# issue -16- allow real names and channels
# <https://github.com/temptemp3/shed.sh/issues/16>
#-------------------------------------------------
# in src/aliases.sh
#-------------------------------------------------
test-message() { { local caller ; caller="${1}" ; local message ; message=${@:2} ; }
 cat << EOF

${message}

EOF
 ${caller}-help
 error "false" # hide error
 false
}
test-member-id() { { local caller ; caller="${1}" ; local member_id ; member_id="${2}" ; }
 test "${member_id}" || { test-message ${caller} "member id not specified" ; }
 test "${member_id:0:1}" = "U" || { test-message ${caller} "member id invalid" ; }
 # else ok
}
alias test-the-member-id='
{
  test-member-id ${FUNCNAME} ${member_id}
}
'
#------------------------------------------------
# in src/functions-get.sh
# -> src/aliases.sh
# -> src/functions-get.sh
# -> src/functions.sh
#-------------------------------------------------
# -> src/aliases.sh
#-------------------------------------------------
alias sed-escape-member-id='sed -e "s/\\\\s/ /g"'
#------------------------------------------------
# -> src/functions-get.sh
#-------------------------------------------------
# version 0.0.2 - remove member id test
slack-shed-get-user-channel-history-for-today() { { local member_id ; member_id="${1}" ; local channel_ids ; channel_ids=${@:2} ; }

  { 
    slack-shed-get-user-channel-history \
    $( date-today ) \
    ${member_id} \
    ${channel_ids}
  }

}
#-------------------------------------------------
# version 0.0.2 - pre process ids before test
slack-shed-get-user-channel-history() { { local date_oldest ; date_oldest="${1}" ; local member_id ; member_id="${2}" ; local channel_ids ; channel_ids=${@:3} ; }
    
  cecho green in ${FUNCNAME}

  {
    cecho yellow member: ${member_id}
    cecho yellow channels: ${channel_ids}
  }
  
  ## debug  
  #read

  ## pre process member id
  member_id=$( 
   case ${member_id} in
    U*) {
     cecho yellow candidate member id
     echo ${member_id} 
    } ;;
    *) {
     cecho yellow candidate field associated with member id
     ## try to convert associated field to member id
     trim $(
       get-user-id "real_name" "$( member-id-escaped )" ||
       echo ${member_id} # fallback 
     ) 
    } ;;
   esac
  )

  ## debug
  #read

  ## pre process channel ids
  channel_ids=$(
  for channel_id in ${channel_ids}
  do
   case ${channel_id} in
   C*) {
    cecho yellow candidate channel id
    echo ${channel_id} 
   } ;;
   *) {
    cecho yellow candidate field associated with channel id
    ## try to convert associated field to channel id
    trim $(
     get-channel-id-by-name "${channel_id}" ||
     echo ${channel_id} # fallback
    )
   } ;;
   esac 
  done
  )

  ## debug
  #read

  {
    cecho yellow member: ${member_id}
    cecho yellow channels: ${channel_ids}
  }
 
  ## debug
  #read

  cecho green testing member id
  test-the-member-id

  ## may add later
  #test-channel-ids

  ## debug
  #read

  {
    local member_ids
    member_ids="\"${member_id}\""
  }

  slack-shed-date-oldest ${date_oldest} ${channel_ids}

}
#-------------------------------------------------
# -> src/functions.sh
#-------------------------------------------------
member-id-escaped() {
  {
    echo ${member_id}
  } | sed-escape-member-id
}
#-------------------------------------------------
# in src/slack.sh/functions-api.sh
#-------------------------------------------------
# -> src/slack.sh/functions-api.sh
#-------------------------------------------------
get-channel-id() { { local candidate_field ; candidate_field="${1}" ; local candidate_value ; candidate_value=${@:2} ; }
  cecho green getting channel id ...
  { 
    local api_method
    api_method="channels.list"
    local query
    query="
.channels[]|
if .${candidate_field}? == \"${candidate_value}\"
then
.id
else
empty
end
"
  }
  slack-api-query
}
#-------------------------------------------------
get-channel-id-by-name() { { local candidate_value ; candidate_value=${@} ; }
 get-channel-id "name" "${candidate_value}"
}
#-------------------------------------------------
# -> srd/functions-test.sh
#-------------------------------------------------
slack-shed-test-get-channel-id-by-name() { { local candidate_value ; candidate_value=${@} ; }
 get-channel-id-by-name ${candidate_value}
}
#-------------------------------------------------
slack-shed-test-get-channel-id() { { local candidate_field ; candidate_field="${1}" ; local candidate_value ; candidate_value=${@:2} ; }
 get-channel-id ${candidate_field} ${candidate_value} 
}
##################################################
## objective:
## - retrieve user id from real name etc.
##################################################
# -> src/functions-get.sh
#-------------------------------------------------
slack-shed-get-user-id() { { local candidate_field ; local candidate_value ; candidate_field="${1}" ; candidate_value=${@:2} ; }
 get-user-id ${candidate_field} ${candidate_value}
}
#-------------------------------------------------
slack-shed-get-user-id-by() {
 commands
}
#-------------------------------------------------
slack-shed-get-user-id-by-real-name() { { local candidate_realname ; candidate_realname=${@} ; }
 get-user-id real_name ${candidate_realname}
}
##################################################
## generated by create-stub2.sh v0.1.1
## on Sat, 21 Apr 2018 09:05:08 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
