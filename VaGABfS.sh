#!/bin/bash

# Function to get the index an element by its content
getIndex() {
   local arr=("$@")  # Get all arguments into an array
   local array=("${arr[@]:0:$((${#arr[@]} - 1))}")  # Extract the array from arguments
   local element="${arr[-1]}"

   for (( i=0; i<${#array[@]}; i++ )); do
      if [[ "${array[i]}" == "$element" ]]; then
         echo "$i"
         return
      fi
   done
   echo "Element not found"
}

# Multidimensional arrays functions
# Output upcoming action
logUpcomingAction() {
    local i="$1"
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
   local index=$1
   # Check if index is valid
   if [ $index -ge 0 ] && [ $index -lt ${#upcomingActions1[@]} ]; then
      # Delete the element at the specified index
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
   local input=("$@")
   local i=1
   for item in "${input[@]}"; do
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

   # Check if less than 8 elements were provided
   if ((i <= 8)); then
      for ((j=i; j<=8; j++)); do
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

changeUpcomingAction() {
   local inputArray=("$@") # Store all arguments in an array
   local position=${inputArray[@]: -1} # Extract the last argument as the number
   local inputArray=("${inputArray[@]::${#inputArray[@]}-1}") # Extract the array without the last element
   deleteUpcomingAction $position
   addUpcomingAction ${inputArray[@]}
}

# Declaring variables and arrays
Admins=("+4915784191434")
Moderatores=("${Admins[@]}" "+491774730644" "+491706186697")
stopBot=0
upcomingActions1=() # Associated command
upcomingActions2=() # Timestamp of original message
upcomingActions3=() # Author of original message
upcomingActions4=() # replyAddress for further messages
upcomingActions5=() # Expiration time in UNIX (date +%s%N | cut -b1-13)
upcomingActions6=() # Special Parameters 1
upcomingActions7=() # Special Parameters 2
upcomingActions8=() # Special Parameters 3


# Function to check if an upcoming action should be performed
upcomingActionShouldBePerformed() {
   local Time="$(date +%s%N | cut -b1-13)"
   for l in "${!upcomingActions5[@]}"; do
      local expirationTime="${upcomingActions5[$l]}"
      if [[ "${upcomingActions5[$l]}" == "$Time" ]] || (( expirationTime < Time )); then
         action=$l
         return 0
      fi
   done
   return 1
}



# Executing upcoming actions
executeUpcomingActions() {
   # Checking if an upcoming action should be performed
   while upcomingActionShouldBePerformed; do

      # Checking if stopBot is expired
      if [[ "${upcomingActions1[$action]}" =~ "stopBot" ]] then
         signal-cli sendReaction ${upcomingActions4[$action]} -t ${upcomingActions2[$action]} -e⏰ -a ${upcomingActions3[$action]}
         signal-cli send ${upcomingActions4[$action]} -m" You took too long to respond. stopBot will be cancelled" --mention "0:0:${upcomingActions3[$action]}" --quote-timestamp ${upcomingActions2[$action]} --quote-author ${upcomingActions3[$action]}
      fi
   deleteUpcomingAction $action
   done
}

# Main loop that runs until bot is stopped
while [ $stopBot -ne 1 ]; do

# Getting new messages
RawData="$(signal-cli receive --ignore-stories --ignore-attachments)Envelope"
Data="$(echo $RawData)"

# Converting newMessages for grep command
ConvertetData="${Data// /_}"

# $() The expression within the brackets is executed as a command and the result is returned.
# echo "$newMessages" returns the value of string
#  | is a pipe operator that uses the output of the previous command as input for the next command.
# grep is used to search and return lines in files that match a specified search pattern.
   # -o causes grep to display only the matching parts, not the entire line.
   # -p '' activates the Perl-compatible regular expression (PCRE) mode of grep. It supports commands like you where programing in Pearl.
   # (?<=Envelope) means that the match must occur before the text "Envelope", but "Envelope" itself is not included in the match.
   # .*? is used to search for the first occurrence of a pattern surrounded by other text without capturing the longest possible match range.
   # .*? means that the regular expression tries to match as little as possible by accepting zero or more occurrences of any character (except a newline)
      # . Match any character except a line break
      # * Match with zero or more occurrences of the preceding element (here .)
      # ? Makes the preceding quantifier (here *) ungreedy, meaning that it tries to match as little as possible-
      # (?=Envelope) means that the match must occur behind the text "Envelope" but "Envelope" itself is not included in the match.
# | is a pipe operator that uses the output of the previous command as input for the next command.
# grep 'Body: ' filters the output of the previous grep command to only include lines containing the string "Body:".
newConvertetMessages=($(echo "$ConvertetData" | grep -oP '(?<=Envelope).*?(?=Envelope)' | grep 'Body:'))
newMessages=("${newConvertetMessages[@]//_/ }") # Converting the strings back to their original form

# Executing upcoming actions
executeUpcomingActions

# Analysing new messages
cycle=0
for element in "${newMessages[@]}"; do

   # Executing upcoming actions
   executeUpcomingActions

   echo "$cycle: "
   echo "$element"

   # Getting message author, message timestamp, author role and reply address.
   messageAuthor=$(echo "${newMessages[cycle]}" | grep -oP '\+\d+' | head -n 1)
   messageTimestamp=$(echo "${newMessages[cycle]}" | grep -oP 'Timestamp: \K\d+')
   if [[ " ${Admins[@]} " =~ "$messageAuthor" ]]; then
      authorRole="Admin"
   elif [[ " ${Moderatores[@]} " =~ "$messageAuthor" ]]; then
      authorRole="Moderator"
   else
      authorRole="Member"
   fi
   replyAdress=$(echo "${newMessages[cycle]}" | grep -oP ' Group info: Id: \K\S+')
   if [[ "$replyAdress" = "" ]] then
      replyAdress=$messageAuthor
   else
      replyAdress="-g$replyAdress"
   fi

   # Checking if VaGABfS was mentioned and there is no quoted message
   if [[ "${newMessages[cycle]}" =~ " Mentions: - “VaGABfS " || ! "$replyAdress" =~ "-g" || "${newMessages[cycle],,}" =~ " nein " || "${newMessages[cycle],,}" =~ " nö " || "${newMessages[cycle],,}" =~ " ne " || "${newMessages[cycle],,}" =~ "gute nacht" || "${newMessages[cycle],,}" =~ "guten morgen" || "${newMessages[cycle],,}" =~ "🦦" || "${newMessages[cycle],,}" =~ "allo" ]]; then
      if ! [[ "${newMessages[cycle]}" =~ " Quote: Id: " ]]; then

         # Checking if an auto-reply-trigger-word got received and replying
         if [[ "${newMessages[cycle],,}" =~ " nein " || "${newMessages[cycle],,}" =~ " nö " || "${newMessages[cycle],,}" =~ " ne " ]]; then
            signal-cli send $replyAdress -m"Doch‼" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
         elif [[  "${newMessages[cycle],,}" =~ "guten morgen" ]]; then
            if ! [[ "${upcomingActions6[@]}" =~ "gutenMorgen" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "gutenMorgen")]}" =~ "$replyAdress" ]]; then
               signal-cli send $replyAdress -m"Guten Morgen‼👋"
               addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+1200000))" "gutenMorgen"
            fi
         elif [[  "${newMessages[cycle],,}" =~ "🦦" ]]; then
            signal-cli send $replyAdress -m"Süßer Otter 🦦 😍" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
         elif [[  "${newMessages[cycle],,}" =~ "allo" ]]; then
            if ! [[ "${upcomingActions6[@]}" =~ "hallo" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "hallo")]}" =~ "$replyAdress" ]]; then
               signal-cli send $replyAdress -m" Hallo! 👋"
               addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+1200000))" "hallo"
            fi
         elif [[  "${newMessages[cycle],,}" =~ "gute nacht" ]];
         then
            if [[ "$messageAuthor" =~ "+4915255665313" ]]; then
               if ! [[ "${upcomingActions6[@]}" =~ "sleepWellInYourBetgestell" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "sleepWellInYourBetgestell")]}" =~ "$replyAdress" ]]; then
                  signal-cli send $replyAdress -m"Sleep well in your Bettgestell" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+1200000))" "sleepWellInYourBetgestell"
               fi
            else
               if ! [[ "${upcomingActions6[@]}" =~ "guteNacht" && "${upcomingActions4[$(getIndex "${upcomingActions6[@]}" "guteNacht")]}" =~ "$replyAdress" ]]; then
                  signal-cli send $replyAdress -m"Gute Nacht💤"
                  addUpcomingAction "timeout" $messageTimestamp $messageAuthor $replyAdress "$(( $(date +%s%N | cut -b1-13)+1200000))" "guteNacht"
               fi
            fi
         # Checking if a command should be executed that doesn't require moderator or admin rights
         elif [[ "${newMessages[cycle]}" =~ "whoAreYou" || "${newMessages[cycle]}" =~ "whatRoleIs" || "${newMessages[cycle]}" =~ "help" ]]; then

            # Checking if help should be executed
            if [[ "${newMessages[cycle]}" =~ "help" ]]; then
               signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
               signal-cli send $replyAdress -m"`echo -e " To find more information about me, visit: https://github.com/The-Bug-Bashers/VaGABfS If you got further questions, feel free to contact my programmer @Flottegurke. To contact @Flottegurke, open a new issue here: https://github.com/The-Bug-Bashers/VaGABfS/issues/new and add the label „question“."`" --preview-url  https://github.com/The-Bug-Bashers/VaGABfS --preview-title "My GitHub repository" --preview-description "Here you can find information about me and get help if you have any questions."  --quote-timestamp $messageTimestamp --quote-author $messageAuthor --preview-image github-6980894_1280.png --mention "0:0:$messageAuthor"

            # Checking if whoAreYou should be executed
            elif [[ "${newMessages[cycle]}" =~ "whoAreYou" ]]; then
               # Checking if someone else then the message author should be mentioned
               if [[ "${newMessages[cycle]}" =~ "-m" || "${newMessages[cycle]}" =~ "--mention" ]]; then
                  # Checking if the author has moderator rights
                  if [[ "${Moderatores[@]}" =~ "$messageAuthor" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                     messageAuthor=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-m|--mention)\s*\+\d+')
                  else
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor
                     signal-cli send $replyAdress -m"You are a member, you need to be a moderator or admin in order to add the -m / --mention attribute. You can execute whoAreYou without -m / --mention. You are also allowed to add the -p switch." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  fi
               fi
               # Checking if the whoAreYou message should be sent via a personal chat
               if [[ "${newMessages[cycle]}" =~ "-p" || "${newMessages[cycle]}" =~ "--private" ]]; then
                  replyAdress="$messageAuthor"
               fi
               signal-cli send $replyAdress -m"`echo -e " Hello! I am VaGABfS, a Voting and Group Administration Bot for Signal! It's Wsmy job to manage votings in our Signal group and tell you the results. Go to the Wiki-page of my GitHub-Repository (https://github.com/The-Bug-Bashers/VaGABfS/wiki#manual (YES, I HAVE A GITHUB REPO AND I'M VERY PROUD OF THAT‼ (REALLY‼))) to see the commands you can use while chatting with me. If you're too lazy to click on that link, here are some basic commands:\n- vote [voting-number] [answer]: Give your opinion to one of the currently running votings\n- voteInfo [voting-number]: Have a summary of all running votings and see the current state of the results"`" --text-style "449:29:ITALIC" "449:29:MONOSPACE" "449:29:BOLD" "540:24:ITALIC" "540:24:BOLD" "540:24:MONOSPACE" --preview-url https://github.com/The-Bug-Bashers/VaGABfS/wiki#manual --preview-title "MY GITHUB REPOSITORY WIKI‼" --preview-description "All of my commands" --preview-image github-6980894_1280.png --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
            else

               # Executing whatRoleIs command
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # Getting target user
               if [[ "$Data" = "" ]]; then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                  signal-cli send $replyAdress -m"Your role is: $authorRole. If you want to see the role of another user, execute whatRoleIs -u or --user <telephoneNumberOfUser>." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               else
                  # Checking role of target user
                  if [[ " ${Admins[@]} " =~ "$Data" ]]; then
                     authorRole="Admin"
                  elif [[ " ${Moderatores[@]} " =~ "$Data" ]]; then
                     authorRole="Moderator"
                  else
                     authorRole="Member"
                  fi
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                  signal-cli send $replyAdress -m"The role of $Data is: $authorRole." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               fi
            fi

         # Checking whether a command that requires administrator rights should be executed
         elif [[ "${newMessages[cycle]}" =~ "stopBot" || "${newMessages[cycle]}" =~ "logNewMessages" || "${newMessages[cycle]}" =~ "logUpcomingActions" || "${newMessages[cycle]}" =~ "addUpcomingAction" || "${newMessages[cycle]}" =~ "deleteUpcomingAction" || "${newMessages[cycle]}" =~ "addMember" || "${newMessages[cycle]}" =~ "removeMember" || "${newMessages[cycle]}" =~ "makeAdmin" || "${newMessages[cycle]}" =~ "revokeAdmin" || "${newMessages[cycle]}" =~ "changeGroupName" || "${newMessages[cycle]}" =~ "changeGroupDescription" ]]; then
            # Checking if the message author is an admin
            if [[ "${Admins[@]}" =~ "$messageAuthor" ]]; then

               # Checking if addMember should be executed
               if [[ "${newMessages[cycle]}" =~ "addMember" ]]; then
                  Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # getting target user
                  if [[ "$Data" = "" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                     signal-cli send $replyAdress -m" No user provided. Execute addMember -u or --user <telephone number of member> in order to add a member to the group."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  else
                     if [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Members: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                        signal-cli send $replyAdress -m" This user already is a member of this group."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                     else
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                        signal-cli updateGroup $replyAdress -m"$Data"
                     fi
                  fi

               # Checking if removeMember should be executed
               elif [[ "${newMessages[cycle]}" =~ "removeMember" ]]; then
                  Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # Getting target user
                  if [[ "$Data" = "" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                     signal-cli send $replyAdress -m" No user provided. Execute removeMember -u or --user <telephone number of member> in order to remove a member from the group." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  else
                     if ! [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Members: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                        signal-cli send $replyAdress -m" This user is not a member of this group." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                     else
                        if [[ "$Data" =~ "+497243924647" ]]; then
                           signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor
                           signal-cli send $replyAdress -m" It is my task to manage votings in this group. If I leave it, I will not be able to complete this task. If you really wish for me to leave this group, execute: signal-cli -a +497243924647 quitGroup $replyAdress in the terminal of the server I am running on." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                        else
                           signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                           signal-cli updateGroup $replyAdress -r"$Data"
                        fi
                     fi
                  fi

               # Checking if makeAdmin should be executed
               elif [[ "${newMessages[cycle]}" =~ "makeAdmin" ]]; then
                  Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # Getting target user
                  if [[ "$Data" = "" ]]; then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                     signal-cli send $replyAdress -m" No user provided. Execute makeAdmin -u or --user <telephone number of admin> in order to grand a member administrator rights." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  else
                     if ! [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Members: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                        signal-cli send $replyAdress -m" This user is not a member of this group." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                     else
                        if [[ "$(echo "$(signal-cli listGroups -d $replyAdress)" | grep -oP '(?<=Admins: \[)[^]]*(?=])')" =~ "$Data" ]]; then
                           signal-cli sendReaction $replyAdress -t $messageTimestamp -e❌ -a $messageAuthor
                           signal-cli send $replyAdress -m" This user already has administrator rights."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                        else
                           signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                           signal-cli updateGroup $replyAdress --admin "$Data"
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
                     signal-cli send $replyAdress -m" No new group name provided. Execute changeGroupName \"<new group name>\" in order change the group name."  --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
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
   fi
   ((cycle++))
done

newMessages=()
done

# This is the location for unused things. Just ignore it.

#🚫 ✅ 🫤