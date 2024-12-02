#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#generate random number
RANDOM_NUMBER=$(( 1 + RANDOM % 1000 ))
#echo "$RANDOM_NUMBER"

#get username input
echo "Enter your username:"
read USERNAME_INPUT

#get user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT';")
#if user id not exist
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME_INPUT', 0);")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT';")

else
  #if user id exist
  USERNAME=$($PSQL "SELECT username FROM users WHERE user_id=$USER_ID;")  
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID;")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_GUESSES=0
echo "Guess the secret number between 1 and 1000:"


#read number input until secret number found
while [[ $NUMBER_INPUT != $RANDOM_NUMBER ]]
do
  read NUMBER_INPUT
  #if a number
  if [[ $NUMBER_INPUT =~ ^[0-9]+$ ]]
  then
    #increment number of guesses
    NUMBER_GUESSES=$((NUMBER_GUESSES+1))

    #if secret number found
    if [[ $NUMBER_INPUT == $RANDOM_NUMBER ]]
    then
      echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      break
    else
      #if greater than secret number
      if [[ $NUMBER_INPUT -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        #if lower than secret number
        echo "It's higher than that, guess again:"
      fi
    fi
  else
    #if not a number
    echo "That is not an integer, guess again:"
  fi
done

#increment and update games played
GAMES_PLAYED=$((GAMES_PLAYED+1))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID;")
#if best game not exist
if [[ -z $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_GUESSES WHERE user_id=$USER_ID;")
else
  #if best game exist, check if it is better
  if [[ $NUMBER_GUESSES -lt $BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_GUESSES WHERE user_id=$USER_ID;")
  fi
fi
