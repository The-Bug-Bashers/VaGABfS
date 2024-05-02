#!/bin/bash

# ************************************************************ License ************************************************************
# VaGABfS (Voting and Group Administration Bot for Signal) © 2024 by Justus David Dicker is licensed under CC BY-NC-SA 4.0.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
# **********************************************************************************************************************************

# Get index of element by its content
getIndex() {
   local arr=("$@")  # Get all arguments into array
   local array=("${arr[@]:0:$((${#arr[@]} - 1))}")  # extract target array from input
   local element="${arr[-1]}" # extract target element from input
   # Cycle through every element in order to check if the current element equals the target element
   for (( i=0; i<${#array[@]}; i++ )); do
      # check if current element equals target element
      if [[ "${array[i]}" == "$element" ]]; then
         echo "$i" # outputting index of target element
         return # quitting
      fi
   done
   echo "Element not found" # outputting error message beacause array does not contain target element
}

# Multidimensional arrays functions
# Output upcoming action
logUpcomingAction() {
    local i="$1" # gett number of target upcoming action
    # output target upcoming action
    echo "1: ${upcomingActions1[$i]} "
    echo "2: ${upcomingActions2[$i]} "
    echo "3: ${upcomingActions3[$i]} "
    echo "4: ${upcomingActions4[$i]} "
    echo "5: ${upcomingActions5[$i]} "
    echo "6: ${upcomingActions6[$i]} "
    echo "7: ${upcomingActions7[$i]} "
    echo "8: ${upcomingActions8[$i]} "
}

# Delete upcoming action
deleteUpcomingAction() {
   local index=$1 # gett number of target upcoming action
   # Check if index is valid
   if [ $index -ge 0 ] && [ $index -lt ${#upcomingActions1[@]} ]; then
      # Delete element at target index
      unset 'upcomingActions1[index]'
      unset 'upcomingActions2[index]'
      unset 'upcomingActions3[index]'
      unset 'upcomingActions4[index]'
      unset 'upcomingActions5[index]'
      unset 'upcomingActions6[index]'
      unset 'upcomingActions7[index]'
      unset 'upcomingActions8[index]'
      # Reindex the array
      upcomingActions1=("${upcomingActions1[@]}")
      upcomingActions2=("${upcomingActions2[@]}")
      upcomingActions3=("${upcomingActions3[@]}")
      upcomingActions4=("${upcomingActions4[@]}")
      upcomingActions5=("${upcomingActions5[@]}")
      upcomingActions6=("${upcomingActions6[@]}")
      upcomingActions7=("${upcomingActions7[@]}")
      upcomingActions8=("${upcomingActions8[@]}")
   fi
}

# Add upcoming action
addUpcomingAction() {
   local input=("$@") # Get all arguments into array
   local i=1 # define index variable
   # cycle throu every input
   for item in "${input[@]}"; do
      # add element to corresponding upcoming action array
      case $i in
         1) upcomingActions1+=("$item") ;;
         2) upcomingActions2+=("$item") ;;
         3) upcomingActions3+=("$item") ;;
         4) upcomingActions4+=("$item") ;;
         5) upcomingActions5+=("$item") ;;
         6) upcomingActions6+=("$item") ;;
         7) upcomingActions7+=("$item") ;;
         8) upcomingActions8+=("$item") ;;
      esac
      ((i++))
   done

   # Check if every upcoming actions array got an detecated input and if not fix it
   if ((i <= 8)); then
      # add 0 to every upcoming action withput new element
      for ((j=i; j<=8; j++)); do
         # add 0 to corresponding upcoming action array
         case $j in
            1) upcomingActions1+=("0") ;;
            2) upcomingActions2+=("0") ;;
            3) upcomingActions3+=("0") ;;
            4) upcomingActions4+=("0") ;;
            5) upcomingActions5+=("0") ;;
            6) upcomingActions6+=("0") ;;
            7) upcomingActions7+=("0") ;;
            8) upcomingActions8+=("0") ;;
         esac
      done
   fi
}

# Change upcoming anction
changeUpcomingAction() {
   local inputArray=("$@") # get input into array
   local position=${inputArray[@]: -1} # Extract last argument as upcoming action to delete
   local inputArray=("${inputArray[@]::${#inputArray[@]}-1}") # Extract array without target upcoming action
   deleteUpcomingAction $position # Delete target upcoming action
   addUpcomingAction ${inputArray[@]} # add new upcoming action
}

# Declare variables and arrays
read -a Admins < admins.txt # get bot admins from confilg file
read -a Moderators < moderators.txt # get bot moderators from config file
Moderators+=("${Admins[@]}") # add admins to list of moderatores to enable admins to execuet moderator commands
stopBot=0 # boolean for checking if the bot shoud stop running
upcomingActions1=() # Associated command of upcoming action
upcomingActions2=() # Timestamp of original message of upcoming action
upcomingActions3=() # Author of original message of upcoming action
upcomingActions4=() # replyAddress for further messages of upcoming action
upcomingActions5=() # Expiration time in UNIX (date +%s%N | cut -b1-13) of upcoming action
upcomingActions6=() # Special Parameter 1 of upcoming action
upcomingActions7=() # Special Parameter 2 of upcoming action
upcomingActions8=() # Special Parameter 3 of upcoming action

# Check if upcoming action should be performed
upcomingActionShouldBePerformed() {
   local Time="$(date +%s%N | cut -b1-13)" # gett current time in UNIX time in ms
   # cycle through every upcomging action and determaine if it expired
   for l in "${!upcomingActions5[@]}"; do
      local expirationTime="${upcomingActions5[$l]}" # get expiration time of current upcoming action
      # check if upcoming action expired
      if [[ "${upcomingActions5[$l]}" == "$Time" ]] || (( expirationTime < Time )); then
         action=$l # set action to number of expired upcoming action for further actions
         return 0 # quitt and return that expired upcoming actions exist
      fi
   done
   return 1 # return that no expired upcoming actions exist
}

# Execute upcoming actions
executeUpcomingActions() {
   # repeating as long as there are expired upcoming actions
   while upcomingActionShouldBePerformed; do

      # Check if expired upcoming action equals send and if it does execute it
      if [[ "${upcomingActions1[$action]}" =~ "send" ]]; then
         signal-cli send ${upcomingActions4[$action]} "${upcomingActions6[$action]}" # send specifyed message
         # check if message should get send again and if it does ad new uppcoming action
         if [[ "${upcomingActions7[$action]}" =~ "-m" || "${upcomingActions7[$action]}" =~ "-h" || "${upcomingActions7[$action]}" =~ "-d" ]]; then
            # check if message intervall got specifyed in minutes and if it did add upcoming acion
            if [[ "${upcomingActions7[$action]}" =~ "-m" ]]; then
               addUpcomingAction "send" "${upcomingActions2[$action]}" "${upcomingActions3[$action]}" ${upcomingActions4[$action]} "$(( $(date +%s%N | cut -b1-13)+$(echo "${upcomingActions7[$action]}" | grep -Po '\d+')*60000))" "${upcomingActions6[$action]}" "${upcomingActions7[$action]}" # add upcoming action to send message again
            # check if message intervall got specifyed in hours and if it did add upcoming acion
            elif [[ "${upcomingActions7[$action]}" =~ "-h" ]]; then
               addUpcomingAction "send" "${upcomingActions2[$action]}" "${upcomingActions3[$action]}" ${upcomingActions4[$action]} "$(( $(date +%s%N | cut -b1-13)+$(echo "${upcomingActions7[$action]}" | grep -Po '\d+')*3600000))" "${upcomingActions6[$action]}" "${upcomingActions7[$action]}" # add upcoming action to send message again
            # message interval got specifyed in days, add upcomign action
            else
               addUpcomingAction "send" "${upcomingActions2[$action]}" "${upcomingActions3[$action]}" ${upcomingActions4[$action]} "$(( $(date +%s%N | cut -b1-13)+$(echo "${upcomingActions7[$action]}" | grep -Po '\d+')*86400000))" "${upcomingActions6[$action]}" "${upcomingActions7[$action]}" # add upcoming action to send message again
            fi
         fi

      # Check if expired upcoming action equals stopBot and if it does execute it
      elif [[ "${upcomingActions1[$action]}" =~ "stopBot" ]]; then
         # tell user, that he took to long to respond
         signal-cli sendReaction ${upcomingActions4[$action]} -t ${upcomingActions2[$action]} -e⏰ -a ${upcomingActions3[$action]} # indicate that timing has run out
         signal-cli send ${upcomingActions4[$action]} -m" You took too long to respond. stopBot will be cancelled" --mention "0:0:${upcomingActions3[$action]}" --quote-timestamp ${upcomingActions2[$action]} --quote-author ${upcomingActions3[$action]} # tell user that stopBot got canceled beacause he toock to long to respond
         deleteUpcomingAction $action # cancle stopping of VaFABfS
      fi
   deleteUpcomingAction $action # delete expired Upcoming action to prevent multiple executions
   done
}

# execute config file
while IFS= read -r line; do
   eval "$line" # executingcurrent line
done < config.txt # declaring file to read

# Main loop that runs until bot is stopped
while [ $stopBot -ne 1 ]; do

echo "run" # debuging information (will get remooved later) ******************************************************************************************************************************************************************************************************************************************************************************************************************

# Gett and forat new messages
RawData="$(signal-cli receive --ignore-stories --ignore-attachments)Envelope" # gett new messages
Data="$(echo $RawData)" # format new messages to get rid of new line indicators, emojis als well as aother not supportet caracters
ConvertetData="${Data// /_}" # Convert spaces into _ inorder for grep command to not split envelopes at spaces
# **********************explenation of 1 line of code just for funn************************************
# $() The expression within the brackets is executed as a command and the result is returned.
# echo "$newMessages" returns the value of a string
#  | is a pipe operator that uses the output of the previous command as input for the next command.
# grep is used to search and return lines in files that match a specified search pattern.
   # -o causes grep to display only the matching parts, not the entire line.
   # -p '' activates the Perl-compatible regular expression (PCRE) mode of grep. It supports commands like you where programing in Pearl.
   # (?<=Envelope) means that the match must occur before the text "Envelope", but "Envelope" itself is not included in the match.
   # .*? is used to search for the first occurrence of a pattern surrounded by other text without capturing the longest possible match range.
   # .*? means that the regular expression tries to match as little as possible by accepting zero or more occurrences of any character (except a newline)
      # . Match any character except a line break
      # * Match with zero or more occurrences of the preceding element (here .)
      # ? Makes the preceding quantifier (here *) ungreedy, meaning that it tries to match as little as possible
      # (?=Envelope) means that the match must occur behind the text "Envelope" but "Envelope" itself is not included in the match.
# | is a pipe operator that uses the output of the previous command as input for the next command.
# grep 'Body: ' filters the output of the previous grep command to only include lines containing the string "Body:".
   # this is donne to get rid of sync, read receipt, reveived receipts, startet typing and stopped typing as well as reacted to and delete messages
newConvertetMessages=($(echo "$ConvertetData" | grep -oP '(?<=Envelope).*?(?=Envelope)' | grep 'Body:')) # split new messages into array with one ellement for every message, delete unnasasary information
newMessages=("${newConvertetMessages[@]//_/ }") # Convert new messages back ("_" to "")

executeUpcomingActions # Execute expired upcoming actions

cycle=0 # reset cycle indicator
# execute command contained in current new message
for element in "${newMessages[@]}"; do

   executeUpcomingActions # Execute expired upcoming actions

   # debuging information
   echo "$cycle: " # log current cycle
   echo "$element" # log current message

   # Gett basic data about current new message
   messageAuthor=$(echo "${newMessages[cycle]}" | grep -oP '\+\d+' | head -n 1) # get message author from current message
   messageTimestamp=$(echo "${newMessages[cycle]}" | grep -oP 'Timestamp: \K\d+') # get message timestamp from current message
   # get author role from current message author
   if [[ " ${Admins[@]} " =~ "$messageAuthor" ]]; then # check if current message author role equals admin
      authorRole="Admin" # set current message author role to admin
   elif [[ " ${Moderators[@]} " =~ "$messageAuthor" ]]; then # check if current message author role equals moderator
      authorRole="Moderator" # set current message author role to moderator
   else
      authorRole="Member" # set current message author role to member
   fi
   replyAdress=$(echo "${newMessages[cycle]}" | grep -oP ' Group info: Id: \K\S+') # get and set current message source
   # check if messasge source is not from a group
   if [[ "$replyAdress" = "" ]]; then
      replyAdress=$messageAuthor # set message source to message author
   else
      replyAdress="-g$replyAdress" # add -g to message source to indicate that the source is a group
   fi

   # Check if VaGABfS was mentioned (in case of message getting send trough group), an autoreply trigger word or command got used and there is no quotet message (beacause signal servers compleately resend quotet messages)
   if [[ ("${newMessages[cycle]}" =~ " Mentions: - “VaGABfS " || ! "$replyAdress" =~ "-g" || "${newMessages[cycle],,}" =~ " nein " || "${newMessages[cycle],,}" =~ " nö " || "${newMessages[cycle],,}" =~ " nee" || "${newMessages[cycle],,}" =~ "gute nacht" || "${newMessages[cycle],,}" =~ "guten morgen" || "${newMessages[cycle],,}" =~ "🦦" || "${newMessages[cycle],,}" =~ "allo") && ! "${newMessages[cycle]}" =~ " Quote: Id: " ]]; then

      # Check if auto-reply-trigger-word got received and replying
      # reply if trigger word for "doch" got send and there is no timeout
      if [[ "${newMessages[cycle],,}" =~ " nein " || "${newMessages[cycle],,}" =~ " nö " || "${newMessages[cycle],,}" =~ " nee" ]]; then
         signal-cli send $replyAdress -m"Doch‼" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # reply to no with doch
      # reply if "guten morgen" triggerword got send and there is no timeout
      elif [[  "${newMessages[cycle],,}" =~ "guten morgen" ]]; then
         # reply if there is no timeout for message author for reply
         if ! [[ "${upcomingActions6[@]}" =~ "gutenMorgen" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "gutenMorgen")]}" =~ "$replyAdress" ]]; then
            signal-cli send $replyAdress -m"Guten Morgen‼👋" # reply to guten morgen with guten morgen
            addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+1800000))" "gutenMorgen" # add timeout for message author for reply
         fi
      # reply if "Süßer otter" triggerword git send and there is no timeout
      elif [[  "${newMessages[cycle],,}" =~ "🦦" ]]; then
         # reply if there is no timeout for message author for reply
         if ! [[ "${upcomingActions6[@]}" =~ "otter" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "otter")]}" =~ "$replyAdress" ]]; then
            signal-cli send $replyAdress -m" Süßer Otter 🦦 😍" # reply to "<otter emoji> with Süßer Otter
            addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+43200000))" "otter" # add timeout for curent meessage autho for Süßer otter
         fi
      # reply if "hallo" triggerword got send and there is no timeout
      elif [[  "${newMessages[cycle],,}" =~ "allo" ]]; then
         # reply if there is no timeout for current message author for reply
         if ! [[ "${upcomingActions6[@]}" =~ "hallo" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "hallo")]}" =~ "$replyAdress" ]]; then
            signal-cli send $replyAdress -m" Hallo! 👋" # reply to hallo with hallo
            addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+1800000))" "hallo" # add timeout for current message author for reply
         fi
      # reply if "gute nacht" tiggerword got send
      elif [[  "${newMessages[cycle],,}" =~ "gute nacht" ]]; then
         # reply differently if action got trigert by specific account
         if [[ "$messageAuthor" =~ "+4915255665313" ]]; then
            # Reply spetialy if there is no timeout
            if ! [[ "${upcomingActions6[@]}" =~ "sleepWellInYourBetgestell" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "sleepWellInYourBetgestell")]}" =~ "$replyAdress" ]]; then
               signal-cli send $replyAdress -m"Sleep well in your Bettgestell🛏️" --quote-timestamp $messageTimestamp --quote-author $messageAuthorr # reply to gute nacht with sleep well in your betgestell
               addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+18000000))" "sleepWellInYourBetgestell" # add timeout for message author for reply
            fi
         # reply normaly if message got not send from specific account and there is no timeout
         elif ! [[ "${upcomingActions6[@]}" =~ "guteNacht" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "guteNacht")]}" =~ "$replyAdress" ]]; then
            signal-cli send $replyAdress -m"Gute Nacht💤" # reply to gute nacht with gute nacht
            addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+900000))" "guteNacht" # add tiemout for current message author for reply
         fi

      # Check if a command should be executed that doesn't require moderator or admin rights
      elif [[ "${newMessages[cycle]}" =~ "whoAreYou" || "${newMessages[cycle]}" =~ "whatRoleIs" || "${newMessages[cycle]}" =~ "help" ]]; then

         # execute "help" if "help" should get executed
         if [[ "${newMessages[cycle]}" =~ "help" ]]; then
            signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command was received succesfully
            signal-cli send $replyAdress -m"`echo -e " To find more information about me, visit: https://github.com/The-Bug-Bashers/VaGABfS If you got further questions, feel free to contact my programmer @Flottegurke. To contact @Flottegurke, open a new issue here: https://github.com/The-Bug-Bashers/VaGABfS/issues/new and add the label „question“."`" --preview-url  https://github.com/The-Bug-Bashers/VaGABfS --preview-title "My GitHub repository" --preview-description "Here you can find information about me and get help if you have any questions."  --preview-image github-6980894_1280.png --quote-timestamp $messageTimestamp --quote-author $messageAuthor --mention "0:0:$messageAuthor" # explain how VaFABsF works

         # execute "whoAreYou" if "whoAreYou" should get executed
         elif [[ "${newMessages[cycle]}" =~ "whoAreYou" ]]; then
            # Check if someone else then message author should be mentioned and if it does correct message author
            if [[ "${newMessages[cycle]}" =~ "-m" || "${newMessages[cycle]}" =~ "--mention" ]]; then
               # correcht mesage author if message author has moderator rights
               if [[ "${Moderators[@]}" =~ "$messageAuthor" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
                  messageAuthor=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-m|--mention)\s*\+\d+') # set new message author in order to reply to coorect account
               else
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor # indicate that message author does not have the rights to proceed
                  signal-cli send $replyAdress -m" You are a member, you need to be a moderator or admin in order to add the -m / --mention attribute. You can execute whoAreYou without -m / --mention. You are also allowed to add the -p switch." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # tell message author, that he does not have the rights mendetory to proceed
               fi
            fi

            # Check if message should be sent via a personal chat and if it does sow correch reply adress
            if [[ "${newMessages[cycle]}" =~ "-p" || "${newMessages[cycle]}" =~ "--private" ]]; then
               replyAdress="$messageAuthor" # currect reply adress
            fi
            signal-cli send $replyAdress -m"`echo -e " Hello! I am VaGABfS, a Voting and Group Administration Bot for Signal! It's Wsmy job to manage votings in our Signal group and tell you the results. Go to the Wiki-page of my GitHub-Repository (https://github.com/The-Bug-Bashers/VaGABfS/wiki#manual (YES, I HAVE A GITHUB REPO AND I'M VERY PROUD OF THAT‼ (REALLY‼))) to see the commands you can use while chatting with me. If you're too lazy to click on that link, here are some basic commands:\n- vote [voting-number] [answer]: Give your opinion to one of the currently running votings\n- voteInfo [voting-number]: Have a summary of all running votings and see the current state of the results"`" --text-style "449:29:ITALIC" "449:29:MONOSPACE" "449:29:BOLD" "540:24:ITALIC" "540:24:BOLD" "540:24:MONOSPACE" --preview-url https://github.com/The-Bug-Bashers/VaGABfS/wiki#manual --preview-title "MY GITHUB REPOSITORY WIKI‼" --preview-description "All of my commands" --preview-image github-6980894_1280.png --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # explain wat VaGABfS is
         else

            # Execute "whatRoleIs" if "whatRoleIs" should get executed
            Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # Gett target user
            # check if target iser is not message author and if it is, correct target user
            if [[ "$Data" = "" ]]; then
               signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
               signal-cli send $replyAdress -m" Your role is: $authorRole. If you want to see the role of another user, execute whatRoleIs -u or --user <telephoneNumberOfUser>." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # explain what VaGABfS is
            # correct role
            else
               if [[ " ${Admins[@]} " =~ "$Data" ]]; then # check if target account role is admin
                  authorRole="Admin" # set role to admin
               elif [[ " ${Moderators[@]} " =~ "$Data" ]]; then # check if targe account role is moderator
                  authorRole="Moderator" # set role to moderator
               else # role is member
                  authorRole="Member" # set role to member
               fi
               signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
               signal-cli send $replyAdress -m" The role of $Data is: $authorRole." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # output target account role
            fi
         fi

      # Checking whether a command that requires moderator rights should be executed and if it does so execute it
      elif [[ "${newMessages[cycle]}" =~ "newVoting" || "${newMessages[cycle]}" =~ "takeControl" ]]; then
         # execute command if role of message author is admin
         if [[ "${Moderators[@]}" =~ "$messageAuthor" ]]; then

            # execute "takeControl" if "takeControl" should get executed
            if [[ "${newMessages[cycle]}" =~ "takeControl" ]]; then
               signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
               signal-cli updateGroup $replyAdress --link=disabled --set-permission-add-member=only-admins --set-permission-edit-details=only-admins --set-permission-send-messages=every-member -e=0 # disable join-link, set add members oermition to ownly admins, set permition to edit group details to ownly admins, set permission to send messages to everyone and disable disaperaring messages
               # remoove all group admins exept the bot itself
               Data2=($(echo "$(signal-cli listGroups $replyAdress -d)" | grep -oP 'Admins: \[\K.*?(?=\])' | sed 's/[,[:space:]]//g' | grep -o '+[0-9]\+')) # get every group amin in array
               for element in "${Data2[@]}"; do
                  # remoove admin if it doe snot equal VaGABfS
                  if ! [[ "$element" == "$botNumber" ]]; then
                     signal-cli updateGroup $replyAdress --remove-admin "$element" # remoove admin from group
                  fi
               done
            fi

#
#            else
#               # Execute newVoting
#               votingName=$(echo "${newMessages[cycle]}" | grep -oP '(?<=--name ")[^"]*') # Getting new name#
#               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-n ")[^"]*') # Getting new name
#               if [[ "$Data" = "" && "$votingName" = "" ]]; then
#                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
#                  signal-cli send $replyAdress -m" No voting name provided. Execute newVoting -n or --name \"<new group name>\" in order to set the voting name."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
#               else
#                  if [[ "$votingName" = "" ]]; then
#                     votingName=$Data
#                  fi
#                  if [[ echo "$replyAdress" | grep -q -P "^-g" && "${newMessages[cycle]}" =~ " -g" ]]; then
#                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
#                     signal-cli send $replyAdress -m" you can not create a new voting in a group for another group ever execute newVoting without -g<group code> in a group or execute NewVoting -g<group Code> in you rprivate chat with me."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
#                  elif [[ ! echo "$replyAdress" | grep -q -P "^-g" && ! "${newMessages[cycle]}" =~ " -g" ]]; then
#                     signal-cli send $replyAdress -m" you can not create a new voting in a private chat without useing the -g<group code> attribute."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
#                  else
#                     if ! echo "$replyAdress" | grep -q -P "^-g"; then
#                        replyAdress=$(echo "${newMessages[cycle]}" | grep -q -P "^-g")
#                     fi
#
#                     # determinating when the voting should end
#                     if [[ "${newMessages[cycle]}" =~ "-t m" || "${newMessages[cycle]}" =~ "-t h" || "${newMessages[cycle]}" =~ "-t d" ]]; then
#                        if [[ "${newMessages[cycle]}" =~ "-t m" ]]; then
#                           endOfVoting="$(( $(date +%s%N | cut -b1-13)+$(echo "${newMessages[cycle]}" | grep -oP '(?<=-t m)\d+')*60000))"
#                        elif [[ "${newMessages[cycle]}" =~ "-t h" ]]; then
#                           endOfVoting="$(( $(date +%s%N | cut -b1-13)+$(echo "${newMessages[cycle]}" | grep -oP '(?<=-t h)\d+')*3600000))"
#                        else
#                           endOfVoting="$(( $(date +%s%N | cut -b1-13)+$(echo "${newMessages[cycle]}" | grep -oP '(?<=-t d)\d+')*86400000))"
#                        fi
#                     elif [[ "${newMessages[cycle]}" =~ "--time m" || "${newMessages[cycle]}" =~ "--time h" || "${newMessages[cycle]}" =~ "--time d" ]]; then
#                        if [[ "${newMessages[cycle]}" =~ "--time m" ]]; then
#                           endOfVoting="$(( $(date +%s%N | cut -b1-13)+$(echo "${newMessages[cycle]}" | grep -oP '(?<=--time m)\d+')*60000))"
#                        elif [[ "${newMessages[cycle]}" =~ "--time h" ]]; then
#                           endOfVoting="$(( $(date +%s%N | cut -b1-13)+$(echo "${newMessages[cycle]}" | grep -oP '(?<=--time h)\d+')*3600000))"
#                        else
#                           endOfVoting="$(( $(date +%s%N | cut -b1-13)+$(echo "${newMessages[cycle]}" | grep -oP '(?<=--time d)\d+')*86400000))"
#                        fi
#                     else
#                        endOfVoting="$(( $(date +%s%N | cut -b1-13)+172800000))"
#                     fi
#                  fi
#               fi
#            fi
#

#        tell user, that he needs to be an moderator or admin in order to execute the command
         else
            signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor # indicate that user does not have permisssion to proceed
            signal-cli send $replyAdress -m" You are a $authorRole, you need to be a moderator or admin in order to execute this command." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # tell user, that he needs to ben an moderator od admin in order to proceed
         fi

      # Check whether a command that requires administrator rights should be executed and execute it if it does sow
      elif [[ "${newMessages[cycle]}" =~ "stopBot" || "${newMessages[cycle]}" =~ "logNewMessages" || "${newMessages[cycle]}" =~ "logUpcomingActions" || "${newMessages[cycle]}" =~ "addUpcomingAction" || "${newMessages[cycle]}" =~ "deleteUpcomingAction" || "${newMessages[cycle]}" =~ "addMember" || "${newMessages[cycle]}" =~ "removeMember" || "${newMessages[cycle]}" =~ "makeAdmin" || "${newMessages[cycle]}" =~ "revokeAdmin" || "${newMessages[cycle]}" =~ "changeGroupName" || "${newMessages[cycle]}" =~ "changeGroupDescription" || "${newMessages[cycle]}" =~ "changeRole"  || "${newMessages[cycle]}" =~ "execute" ]]; then
         # Execute command if message author is an admin
         if [[ "${Admins[@]}" =~ "$messageAuthor" ]]; then

            # Execute "execute" if execute should get "executed"
            if [[ "${newMessages[cycle]}" =~ "execute" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=execute ")[^"]*') # Gett command to execute
                  # execute command if there is one
                  if [[ "$Data" = "" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor # indicate that somthing is wrong
                     signal-cli send $replyAdress -m" No command provided. Execute execute -c or --command \"<command wich should get executed>\" in in order to execute a command in the CLI of the server i am running on and get the output returned." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # tell user, how to execute commands
                  # execute command
                  else
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
                     signal-cli send $replyAdress -m"`echo -e " Output:\n$($Data)"`" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # execute command and return output
                  fi

            # Execute "changeRole" if "changeRole" should get executed
            elif [[ "${newMessages[cycle]}" =~ "changeRole" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # Gett target user
               # check if target user got specifyed and output error message if it did not
               if [[ "$Data" = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor # indicate that somting is wrong
                  signal-cli send $replyAdress -m" No user provided. Execute changeRole -u or --user <telephone number of user> --member, --moderator or --admin in order to change the role of an user." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # explain how to change the role of user
               else
                  # check if target user is in group and output error message if he does not
                  if ! [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Members: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor # inicate that an error occured
                     signal-cli send $replyAdress -m" This user is not a member of this group." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # output error message
                  else
                     # check if target role got specifyed and change role if it did
                     if [[ "${newMessages[cycle]}" =~ "--member" || "${newMessages[cycle]}" =~ "--moderator" || "${newMessages[cycle]}" =~ "--admin" ]]; then
                        # change role of target user to member if target role is member
                        if [[ "${newMessages[cycle]}" =~ "--member" ]]; then
                           # change role of target user to member if he currently is an admin
                           if [[ "${Admins[@]}" =~ "$Data" ]]; then
                              unset Admins[$(getIndex "${Admins[@]}" "$Data")] # delete target user from admins array
                              echo "${Admins[@]}" > admins.txt # cyncronyse admins file with admins array
                              read -a Moderators < moderators.txt # get moderators into array
                              Moderators+=("${Admins[@]}") # add admins to moderators array
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
                           # change role of target user to member if he currently is an moderator
                           elif [[ "${Moderators[@]}" =~ "$Data" ]]; then
                              read -a Moderators < moderators.txt # syncronyse moderators array with moderators file (get rid of admins)
                              unset Moderators[$(getIndex "${Moderators[@]}" "$Data")] # delete target user
                              echo "${Moderators[@]}" > moderators.txt # syncronise moderators file with moderators array
                              Moderators+=("${Admins[@]}") # add admins to moderators array
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
                           # output error message sinse target user already is member
                           else
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor # indicate that an error occured
                              signal-cli send $replyAdress -m" This user already is a member." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # output error message
                           fi
                        # change target user role to moderator
                        elif [[ "${newMessages[cycle]}" =~ "--moderator" ]]; then
                           # change role of target user to moderator if he currently is an admin
                           if [[ "${Admins[@]}" =~ "$Data" ]]; then
                              unset Admins[$(getIndex "${Admins[@]}" "$Data")] # delete target user from admins array
                              echo "${Admins[@]}" > admins.txt # syncronise admins file with admins array
                              read -a Moderators < moderators.txt # syncronise modertors array with moderators array (get rid of admins)
                              Moderators+=("$Data") # add target user
                              echo "${Moderators[@]}" > moderators.txt # syncronise moderators file with moderators array
                              Moderators+=("${Admins[@]}") # add admins to moderators array
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
                           # change role of target user to moderator if he currently is an member
                           elif ! [[ "${Moderators[@]}" =~ "$Data" ]]; then
                              read -a Moderators < moderators.txt # syncronise moderators array with moderators file (get rid of admins)
                              Moderators+=("$Data") # add target user
                              echo "${Moderators[@]}" > moderators.txt # syncronise moderators array with moderators file
                              Moderators+=("${Admins[@]}") # add admins to moderators array
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got recieved succesfully
                           # output error message sinse target user already is moderator
                           else
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor # indicate that an error uccured
                              signal-cli send $replyAdress -m" This user already is a moderator." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # output error message
                           fi
                        # change role of target user to admin
                        else
                           # change role of target user to admin if current role of target user is moderator
                           if [[ "${Moderators[@]}" =~ "$Data" ]]; then
                              read -a Moderators < moderators.txt # syncronise moderators array with moderators file (get rid of admins)
                              unset Moderators[$(getIndex "${Moderators[@]}" "$Data")] # delete target user from moderators array
                              echo "${Moderators[@]}" > moderators.txt # syncronise moderators array with moderators file
                              Admins+=("$Data") # add target user to admins array
                              echo "${Admins[@]}" > admins.txt # syncronise admins array with admins file
                              Moderators+=("${Admins[@]}") # add admins to moderators array
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
                           # change role of target user to admin if current role of target user is member
                           elif ! [[ "${Admins[@]}" =~ "$Data" ]]; then
                              Admins+=("$Data") # add target user to admins array
                              echo "${Admins[@]}" > admins.txt # syncronise admins file with admins array
                              read -a Moderators < moderators.txt # syncronise moderatirs array with moderators file (get rid of admins)
                              Moderators+=("${Admins[@]}") # add admins to moderators array
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
                           # output error message sinse target user already is admin
                           else
                              signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor # indicate thath an error uccured
                              signal-cli send $replyAdress -m" This user already is an Admin." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # output error message
                           fi
                        fi
                     # output error message sinse no role got provided
                     else
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor # indicate that somthing went wrong
                        signal-cli send $replyAdress -m" No role provided. Execute changeRole -u or --user <telephone number of member> --member, --moderator or --admin in order to change the role of an user." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # explain hoe to change role of user
                     fi
                  fi
               fi

            # Execute "addMember" if "addMember" should be executed
            elif [[ "${newMessages[cycle]}" =~ "addMember" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # gett target user
               # add member if user got provided and target user is not member of target group
               if [[ "$Data" = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor # indicate that somthing went wrong
                  signal-cli send $replyAdress -m" No user provided. Execute addMember -u or --user <telephone number of member> in order to add a member to the group."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # explain how to add members to group
               else
                  # add target user if target user is not part of target group
                  if [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Members: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor # indicate that error accured
                     signal-cli send $replyAdress -m" This user already is a member of this group."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # output error message
                  # add target user to target group
                  else
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got recieved cuccesfully
                     signal-cli updateGroup $replyAdress -m"$Data" # add target user to target group
                  fi
               fi

            # Execute "removeMember" if "removeMember" should get executed
            elif [[ "${newMessages[cycle]}" =~ "removeMember" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # Gett target user
               # remoove target user if user got provided, target user is not VaGABfS and target user is not member of target group
               if [[ "$Data" = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor # indicate that sonthing went wrong
                  signal-cli send $replyAdress -m" No user provided. Execute removeMember -u or --user <telephone number of member> in order to remove a member from the group." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # explain how to remoove menbers
               else
                  # remoove target user if target user is not VaGABfS and target user is not member of target group
                  if ! [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Members: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor # indicate that an error occured
                     signal-cli send $replyAdress -m" This user is not a member of this group." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # output error message
                  else
                     # remoove target user if target user is not VaGABfS
                     if [[ "$Data" =~ "$botNumber" ]]; then
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor # indicate that user does not have permission to proceed
                        signal-cli send $replyAdress -m" It is my task to manage votings in this group. If I leave it, I will not be able to complete this task. If you really wish for me to leave this group, execute: signal-cli -a $botNumber quitGroup $replyAdress in the terminal of the server I am running on." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # tell user how to make VaGABfS leave the group
                     else
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor # indicate that command got received succesfully
                        signal-cli updateGroup $replyAdress -r"$Data" # remoove target user from target group
                     fi
                  fi
               fi

            # execute "makeAdmin" if "makeAdmin" should be executed
            elif [[ "${newMessages[cycle]}" =~ "makeAdmin" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # Gett target user
               # make target user admin if target user got provided, target user is a member of the target group, and target user is no admin in target group
               if [[ "$Data" = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor # indicate that somthing is wrong
                  signal-cli send $replyAdress -m" No user provided. Execute makeAdmin -u or --user <telephone number of admin> in order to grand a member administrator rights." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor # output error message
               else
                  # make target user admin if target user is a member of the target group, and target user is no admin in target group
                  if ! [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Members: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                     signal-cli send $replyAdress -m" This user is not a member of this group." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  else
                     if [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Admins: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                        signal-cli send $replyAdress -m" This user already has administrator rights."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                     else
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                        signal-cli updateGroup $replyAdress --admin "$Data" # make target user admin
                     fi
                  fi
               fi

            # Checking if revokeAdmin should be executed
            elif [[ "${newMessages[cycle]}" =~ "revokeAdmin" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # Getting target user
               if [[ "$Data" = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                  signal-cli send $replyAdress -m" No user provided. Execute revokeAdmin -u or --user <telephone number of admin> in order to remove administrator rights from an admin." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               else
                  if ! [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Members: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                     signal-cli send $replyAdress -m" This user is not a member of this group." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  else
                     if [[ ! "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Admins: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                        signal-cli send $replyAdress -m" This user has no administrator rights."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                     else
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                        signal-cli updateGroup $replyAdress --remove-admin "$Data"
                     fi
                  fi
               fi

            # Checking if changeGroupName should be executed
            elif [[ "${newMessages[cycle]}" =~ "changeGroupName" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=changeGroupName ")[^"]*') # Getting new name
               if [[ "$Data" = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                  signal-cli send $replyAdress -m" No new group name provided. Execute changeGroupName \"<new group name>\" in order to change the group name."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               else
                  if [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Name: ).*?(?= Description:)')" = "$Data" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                     signal-cli send $replyAdress -m" The new group name can't be the same as the old group name."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  else
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                     signal-cli updateGroup $replyAdress -n"$Data"
                  fi
               fi

            # Checking if changeGroupDescription should be executed
            elif [[ "${newMessages[cycle]}" =~ "changeGroupDescription" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=changeGroupDescription ")[^"]*') # Getting new description
               if [[ "$Data" = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                  signal-cli send $replyAdress -m" No new group description provided. Execute changeGroupDescription \"<new group description>\" in order to change the group name." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               else
                  if [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Description: ).*?(?= Active:)')" = "$Data" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                     signal-cli send $replyAdress -m" The new group description can't be the same as the old group description."  --mention "0:0:$messageAuthor" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  else
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                     signal-cli updateGroup $replyAdress -d"$Data"
                  fi
               fi

            # Checking if logUpcomingActions should be executed
            elif [[ "${newMessages[cycle]}" =~ "logUpcomingActions" ]]; then
               Data=""
               for ((k = 0; k < ${#upcomingActions1[@]}; k++)); do
                  Data+="UpcomingAction $k: \n $(logUpcomingAction $k) \n\n"
               done
               signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
               signal-cli send $replyAdress -m"`echo -e " $Data"`" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor

            # Checking if addUpcomingAction should be executed
            elif [[ "${newMessages[cycle]}" =~ "addUpcomingAction" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=addUpcomingAction ")[^"]*')
               if [[ $Data = "" ]];
               then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                  signal-cli send $replyAdress -m" No upcoming action to add found. To add an upcoming action, execute addUpcomingAction \"<the upcoming action that should be added>\"." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               else
                  addUpcomingAction $Data
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
               fi

            # Checking if deleteUpcomingAction should be executed
            elif [[ "${newMessages[cycle]}" =~ "deleteUpcomingAction" ]]; then
               Data=$(echo "${newMessages[cycle]}" | grep -oP 'deleteUpcomingAction \K\d+')
               if [[ $Data = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                  signal-cli send $replyAdress -m" No upcoming action to delete found. To delete an upcoming action, execute deleteUpcomingAction <the number of the upcoming action that should be deleted>."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               else
                  deleteUpcomingAction $Data
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
               fi

            # Checking if stopBot should be executed
            elif [[ "${newMessages[cycle]}" =~ "stopBot" ]]; then
               if [[ "${upcomingActions1[@]}" =~ "stopBot" ]]; then
                  if [[ "${newMessages[cycle]}" =~ "yes" ]]; then
                     stopBot=1
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                     signal-cli send $replyAdress -m" Stopping VaGABfS." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  elif [[ "${newMessages[cycle]}" =~ "no" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                     signal-cli send $replyAdress -m" Successfully cancelled stopBot." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                     deleteUpcomingAction $(getIndex "${upcomingActions1[@]}" "stopBot")
                  else
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                     signal-cli send $replyAdress -m" Command not found. To stop VaGABfS execute: stopBot yes, to cancel the stopping of VaGABfS execute: stopBot no." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  fi
               else
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e⏩ -a $messageAuthor
                  signal-cli send $replyAdress -m" Are you sure you want to stop VaGABfS (yes/no)? If you do not respond within the next two minutes, stopBot will be cancelled." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  addUpcomingAction stopBot $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+120000))"
               fi

            else
               # Executing logNewMessages
               signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
               signal-cli send $replyAdress -m" $(printf "Message:\n%s\n\n" "${newMessages[@]}")" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
            fi
         else
            signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor
            signal-cli send $replyAdress -m" You are a $authorRole, you need to be an admin in order to execute this command." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
         fi
      else
         signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
         signal-cli send $replyAdress -m" Command not found, execute help to get help about how to use VaGABfS." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
      fi
   fi
   ((cycle++))
done

newMessages=()
done