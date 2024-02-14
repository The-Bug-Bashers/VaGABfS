#!/bin/bash

#the goupcode of the goup
currentGroup="eVKi/98VxZfkqRHSt83zbEHJbn/eq3H0a/pIrpV7myA="
#users with permissions to execute commands
whitelist=("from: “Ich” +4915784191434 (device: ")
actions=()
stopBot=0

#while [ $stopBot -ne 1 ];
#do




#getting new messages
   newRawMessages="$(signal-cli receive --ignore-stories --ignore-attachments)Envelope"
newMessages="$(echo $newRawMessages)"

#converting newMessages for grep command
result="${newMessages// /_}"

# $() The expression within the brackets is executed as a command and the result is returned.
# echo "$result" returns the value of string
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
preResult=($(echo "$result" | grep -oP '(?<=Envelope).*?(?=Envelope)'))

#Converting the strings back to their original form
result=("${preResult[@]//_/ }")

#printf "Message:\n%s\n\n" "${result[@]}"
#signal-cli send -geVKi/98VxZfkqRHSt83zbEHJbn/eq3H0a/pIrpV7myA= -m"$(printf "Message:\n%s\n\n" "${result[@]}")"


#analysing new messages
cycle=0
for element in "${result[@]}"; do
   echo "$cycle: "
   echo "$element"

#getting the message author
messageAuthor=$(echo "${result[cycle]}" | grep -oP '\+\d+' | head -n 1)
messageTimestamp=$(echo "${result[cycle]}" | grep -oP 'Timestamp: \K\d+')
echo "$timestamp"

   if ! [[ "${result[$cycle]}" =~ " Quote: Id: " ]]
   then
      if [[ "${result[$cycle]}" =~ " Mentions: - “SBbFlottegurke " ]]
      then
      if [[ "${result[$cycle]}" =~ "${whitelist[@]}" ]]
         then
         echo "this person is allowed to execute commands"

         if [[ "${result[$cycle]}" =~ "stopBot" ]]
         then
            stopBot=1
            signal-cli send -g $currentGroup -m" bot Stopped" --mention "0:0:$messageAuthor"
         fi

         else
            signal-cli sendReaction -g $currentGroup -t $messageTimestamp -e🚫 -a $messageAuthor
            signal-cli send -g $currentGroup -m" You do not have the permission to execute commands" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
            echo "this person doesen't have the permission to execute comands"
         fi
      fi
   fi
   ((cycle++))
done


result=()


#done




#while [[ $messages != *"stopBot"* ]];
#do
#   messages="$(signal-cli receive)"
#   echo $messages
#   if [[ $messages == *"logNewMessages"* ]];
#   then
#      echo "Logging new messgages"
#      signal-cli send -geVKi/98VxZfkqRHSt83zbEHJbn/eq3H0a/pIrpV7myA= -m"$messages"
#   else
#      date
#   fi
#done


#cycle=0
#for element in "${result[@]}"; do
#   echo "$cycle: $element"
#   ((cycle++))
#done


































