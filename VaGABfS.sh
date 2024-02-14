#!/bin/bash


#declaring variables and Arrays
Admins=("+4915784191434")
Moderatores=("${Admins[@]}" "+491774730644" "+491706186697")
actions=()
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

#main loop runs until bot is stopped
#while [ $stopBot -ne 1 ];
#do

#getting new messages
RawData="$(signal-cli receive --ignore-stories --ignore-attachments)Envelope"
Data="$(echo $RawData)"

#converting newMessages for grep command
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

newMessages=("${newConvertetMessages[@]//_/ }") #Converting the strings back to their original form

#analysing new messages
cycle=0
for element in "${newMessages[@]}";
do
   echo "$cycle: "
   echo "$element"

   #getting memessag author, message timestamp, author role and reply adress.
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

   #checking if VaGABfS was mentioned and there is no quotet message
   if [[ "${newMessages[$cycle]}" =~ " Mentions: - “VaGABfS " || "$replyAdress" != *g* ]];
   then
      if ! [[ "${newMessages[$cycle]}" =~ " Quote: Id: " ]]
      then

         #Checking whether a command that requires administrator rights should be executed
         if [[ "${newMessages[$cycle]}" =~ "stopBot" || "${newMessages[$cycle]}" =~ "logNewMessages" ]];
         then

            # Checking if The message author is an Admin
            if [[ "${Admins[@]}" =~ "$messageAuthor" ]];
            then

               if [[ "${newMessages[$cycle]}" =~ "stopBot" ]];
               then
                  stopBot=1
                  signal-cli sendReaction -g $currentGroup -t $messageTimestamp -e✅ -a $messageAuthor
                  signal-cli send -g $currentGroup -m" Succesfully Stopped VaGABfS" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               else
                  signal-cli sendReaction $replyAdress -t $messageTimestamp -e✅ -a $messageAuthor
                  signal-cli send $replyAdress -m"$(printf "Message:\n%s\n\n" "${newMessages[@]}")" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
               fi
            else
            signal-cli sendReaction $replyAdress -t $messageTimestamp -e🚫 -a $messageAuthor
            signal-cli send $replyAdress -m"you are a $authorRole you need to be an Admin in order to execute this command" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
            fi
         fi
      fi
   fi

   ((cycle++))
done

newMessages=()
#done




#this is the location for unused scripts just ignore it

#signal-cli sendReaction -g $currentGroup -t $messageTimestamp -e🚫 -a $messageAuthor
#signal-cli send -g $currentGroup -m" You do not have the permission to execute commands" --mention "0:0:$messageAuthor" --quote-timestamp $messageTimestamp --quote-author $messageAuthor
#echo "this person doesen't have the permission to execute comands"

#signal-cli send -geVKi/98VxZfkqRHSt83zbEHJbn/eq3H0a/pIrpV7myA= -m"$(printf "Message:\n%s\n\n" "${newMessages[@]}")"


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
#for element in "${newMessages[@]}"; do
#   echo "$cycle: $element"
#   ((cycle++))
#done



