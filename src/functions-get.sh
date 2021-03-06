#!/bin/bash
## functions-get
## - get functions for shed
## version 0.1.0 - post integration
##################################################
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

  {
    cecho yellow member: ${member_id}
    cecho yellow channels: ${channel_ids}
  }
 
  cecho green testing member id
  test-the-member-id

  ## may add later
  #test-channel-ids

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
## generated by create-stub2.sh v0.1.1
## on Sun, 06 May 2018 20:30:26 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
