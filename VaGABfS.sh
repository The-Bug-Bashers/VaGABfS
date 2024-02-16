#!/bin/bash

get_index() {
   local array=("$@")
   local element=$1
   for i in "${!array[@]}";
   do
      if [[ "${array[$i]}" == "$element" ]];
      then
         echo "$i"
         return
      fi
   done
   echo "Element not found"
# Example usage: index=$(get_index "${my_array[@]}" "$element")
}

# Multidimensional arrays functions
# Delete upcoming Action
deleteUpcomingAction() {
   local index=$1
   # Check if index is valid
   if [ $index -ge 0 ] && [ $index -lt ${#upcomingActions1[@]} ];
   then
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
   for item in "${input[@]}";
   do
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


# declaring variables and Arrays
Admins=("+4915784191434")
Moderatores=("${Admins[@]}" "+491774730644" "+491706186697")
currentGroup="eVKi/98VxZfkqRHSt83zbEHJbn/eq3H0a/pIrpV7myA="
stopBot=0
upcomingActions1=() # Asosiated command
upcomingActions2=() # Timestamp of original message
upcomingActions3=() # Author of original message
upcomingActions4=() # replyAdress for further messages
upcomingActions5=() # spetial Parameters 1
upcomingActions6=() # spetial Parameters 2
upcomingActions7=() # spetial Parameters 3
upcomingActions8=() # spetial Parameters 4

# main loop that runs until bot is stopped
#while [ $stopBot -ne 1 ];
#do

# getting new messages
RawData="$(signal-cli receive --ignore-stories --ignore-attachments)Envelope"
Data="$(echo $RawData)"

# converting newMessages for grep command
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
      # (?=Envelope) means that the match must occur behind the text "Envelope" but "Evelope" itself is not included in the match.
# | is a pipe operator that uses the output of the previous command as input for the next command.
# grep 'Body: ' filters the output of the previous grep command to only include lines containing the string "Body:".
newConvertetMessages=($(echo "$ConvertetData" | grep -oP '(?<=Envelope).*?(?=Envelope)' | grep 'Body:'))
newMessages=("${newConvertetMessages[@]//_/ }") # Converting the strings back to their original form

# analysing new messages
cycle=0
for element in "${newMessages[@]}";
do
   echo $cycle
   echo "$cycle: "
   echo "$element"

   # checking if VaGABfS was mentioned and there is no quotet message
   if [[ "${newMessages[cycle]}" =~ " Mentions: - “VaGABfS " || "$replyAdress" != *g* || "${newMessages[cycle],,}" =~ " nein " || "${newMessages[cycle],,}" =~ " nö " || "${newMessages[cycle],,}" =~ " ne " || "${newMessages[cycle],,}" =~ "gute nacht" || "${newMessages[cycle],,}" =~ "guten morgen" || "${newMessages[cycle],,}" =~ "🦦" ]];
   then
      if ! [[ "${newMessages[cycle]}" =~ " Quote: Id: " ]];
      then

         # getting memessag author, message timestamp, author role and reply adress.
         messageAuthor=$(echo "${newMessages[cycle]}" | grep -oP '\+\d+' | head -n 1)
         messageTimestamp=$(echo "${newMessages[cycle]}" | grep -oP 'Timestamp: \K\d+')
         replyAdress=$(echo "${newMessages[cycle]}" | grep -oP ' Group info: Id: \K\S+')
         if [[ "$replyAdress" = "" ]]
         then
            replyAdress=$messageAuthor
         else
            replyAdress="-g$replyAdress"
         fi
         if [[ " ${Admins[@]} " =~ "$messageAuthor" ]];
         then
            authorRole="Admin"
         elif [[ " ${Moderatores[@]} " =~ "$messageAuthor" ]];
         then
            authorRole="Moderator"
         else
            authorRole="Member"
         fi

         # checking if an auto-reply-trigger-word got received and replying
         if [[ "${newMessages[cycle],,}" =~ " nein " || "${newMessages[cycle],,}" =~ " nö " || "${newMessages[cycle],,}" =~ " ne " ]];
         then
            signal-cli send $replyAdress -m"Doch‼" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
         elif [[  "${newMessages[cycle],,}" =~ "guten morgen" ]];
         then
            signal-cli send $replyAdress -m"Guten Morgen‼👋" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
         elif [[  "${newMessages[cycle],,}" =~ "🦦" ]];
         then
            signal-cli send $replyAdress -m"Süßer Otter 🦦 😍" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
         elif [[  "${newMessages[cycle],,}" =~ "gute nacht" ]];
         then
            if [[ "$messageAuthor" =~ "+4915255665313" ]];
            then
               signal-cli send $replyAdress -m"Sleep well in your Bettgestell" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
            else
               signal-cli send $replyAdress -m"Gute Nacht💤" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
            fi
         fi

         # checking if a command yhould be executet that doesent require moderrator or admin rights
         if [[ "${newMessages[cycle]}" =~ "whoAreYou" || "${newMessages[cycle]}" =~ "whatRoleIs" || "${newMessages[cycle]}" =~ "help" ]];
         then

            #checking if help should be executed
            if [[ "${newMessages[cycle]}" =~ "help" ]];
            then
               signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
               signal-cli send $replyAdress -m"`echo -e " To find more information about me, visit: https://github.com/The-Bug-Bashers/VaGABfS If you got further questions, feel free to contact my programmer @Flottegurke. To contact @Flottegurke, open a new issue here: https://github.com/The-Bug-Bashers/VaGABfS/issues/new and add the label „question“."`" --preview-url  https://github.com/The-Bug-Bashers/VaGABfS --preview-title "My GitHub repository" --preview-description "Here you can find information about me and get help if you have any questions."  --quote-timestamp $messageTimestamp --quote-author $messageAuthor --preview-image github-6980894_1280.png --mention "0:0:$messageAuthor"

            # checking if whoAreYou should be executed
            elif [[ "${newMessages[cycle]}" =~ "whoAreYou" ]];
            then
               # checking if someone else then the message author should be mentioned
               if [[ "${newMessages[cycle]}" =~ "-m" || "${newMessages[cycle]}" =~ "--mention" ]];
               then
                  # checking if the author has Moderrator rights
                  if [[ "${Moderatores[@]}" =~ "$messageAuthor" ]];
                  then
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                     messageAuthor=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-m|--mention)\s*\+\d+')
                  else
                     signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor
                     signal-cli send $replyAdress -m"You are a member, you need to be an moderator or admin in order to add the -m / --mention attribute. You can execute whoAreYou without -m / --mention. You are also allowed to add the -p switch." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  fi
               fi
               # checking if the whoAreYou message should be send via a personal chat
               if [[ "${newMessages[cycle]}" =~ "-p" || "${newMessages[cycle]}" =~ "--private" ]];
               then
                  replyAdress="$messageAuthor"
               fi
            signal-cli send $replyAdress -m"`echo -e " Hello! I am VaGABfS, the Voting and Group Administration Bot for Signal! It's my job to manage votings in our Signal group and tell you the results. Go to the Wiki-page of my GitHub-Repository (https://github.com/The-Bug-Bashers/VaGABfS/wiki#manual (YES, I HAVE A GITHUB REPO AND I'M VERY PROUD OF THAT‼ (REALLY‼))) to see the commands you can use while chatting with me. If you're too lazy to click on that link, here are some basic commands:\n- vote [voting-number] [answer]: Give your opinion to one of the currently running votings\n- voteInfo [voting-number]: Have a summary of all running votings and see the current state of the results"`" --text-style "449:29:ITALIC" "449:29:MONOSPACE" "449:29:BOLD" "540:24:ITALIC" "540:24:BOLD" "540:24:MONOSPACE" --preview-url https://github.com/The-Bug-Bashers/VaGABfS/wiki#manual --preview-title "MY GITHUB REPOSITORY WIKI‼" --preview-description "All of my commands" --preview-image github-6980894_1280.png --mention "0:0:$messageAuthor"
            else

               #executing whatRoleIs command
               Data=$(echo "${newMessages[cycle]}" | grep -oP '(?<=-u|--user)\s*\+\d+') # getting target user
               if [[ "$Data" = "" ]];
               then
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                  signal-cli send $replyAdress -m"Your role is: $authorRole. If you want to see the role of another user, execute whatRoleIs -u telephonenumberOfUser or whatRoleIs --user." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               else
                  # checking role of target user
                  if [[ " ${Admins[@]} " =~ "$Data" ]];
                  then
                     authorRole="Admin"
                  elif [[ " ${Moderatores[@]} " =~ "$Data" ]];
                  then
                     authorRole="Moderator"
                  else
                     authorRole="Member"
                  fi
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                  signal-cli send $replyAdress -m"The role of $Data is: $authorRole." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               fi
            fi

         # Checking whether a command that requires administrator rights should be executed
         elif [[ "${newMessages[cycle]}" =~ "stopBot" || "${newMessages[cycle]}" =~ "logNewMessages" ]];
         then
            # Checking if The message author is an Admin
            if [[ "${Admins[@]}" =~ "$messageAuthor" ]];
            then

               if [[ "${newMessages[cycle]}" =~ "stopBot" ]];
               then
                  if [[ "${upcomingActions1[@]}" =~ "stopBot" ]];
                  then
                     if [[ "${newMessages[cycle]}" =~ "yes" ]];
                     then
                        stopBot=1
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                        signal-cli send -g $currentGroup -m" Stopping VaGABfS" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                     elif [[ "${newMessages[cycle]}" =~ "no" ]];
                     then
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                        signal-cli send -g $currentGroup -m" succesfully canceled stopBot" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                        deleteUpcomingAction $(get_index "${my_array[@]}" "$element")
                     else
                        signal-cli sendReaction $replyAdress -t $messageTimestamp -e🫤 -a $messageAuthor
                        signal-cli send -g $currentGroup -m" Command not found. To stop VaGABfS execute: stopBot yes, to cancel the stopping of VaGABfS execute: stopBot no." --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                     fi
                  else
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                  signal-cli send -g $currentGroup -m" Are you sure you want to stop VaGABfS? (yes/no)" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
                  addUpcomingAction stopBot $messageTimestamp $messageAuthor $replyAdress 1
                  fi

               else
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                  signal-cli send $replyAdress -m" $(printf "Message:\n%s\n\n" "${newMessages[@]}")" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               fi
            else
            signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor
            signal-cli send $replyAdress -m" You are a $authorRole, you need to be an Admin in order to execute this command" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
            fi
         fi
      fi
   fi
   ((cycle++))
done

newMessages=()
#done

# this is the location for unused things just ignore it

#🚫 ✅ 🫤