#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=guessing --tuples-only -c"

LOGIN() {
  echo "Enter your username:"
  read NAME
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$NAME'")
  if [[ -z $USER_ID ]]
  then
    RESULT=$($PSQL "INSERT INTO users(user_name) VALUES('$NAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$NAME'")
    RESULT=$($PSQL "INSERT INTO games(user_id,n_games,best_guesses) VALUES($USER_ID,0,NULL)")
  fi
  return $USER_ID
}

WELCOME() {
  DATA=$($PSQL "SELECT * FROM users LEFT JOIN games USING(user_id) WHERE user_id=$1")
  read ID BAR NAME BAR N_GAMES BAR BEST_GUESSES < <(echo $DATA)
  if [[ $N_GAMES=0 ]]
  then
    echo "Welcome, $NAME! It looks like this is your first time here."
  else
    echo "Welcome back, $NAME! You have played $N_GAMES, and your best game took $BEST_GUESSES guesses."
  fi
}

PLAY() {
  RN=$(( 1+RANDOM%1000 ))
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  N=1
  while [ $GUESS -ne $RN ]
  do
    if [ $GUESS -lt $RN ]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
    read GUESS
    ((N++))
  done
  # update statistics 
  ((N_GAMES++))
  RESULT=$($PSQL "UPDATE games SET n_games=$N_GAMES WHERE user_id=$USER_ID")
  if [ $N -lt $BEST_GUESSES ]
  then
    RESULT=$($PSQL "UPDATE games SET best_guesses=$N WHERE user_id=$USER_ID")
  fi
  echo "You guessed it in $N tries. The secret number was $RN. Nice job!"
}

LOGIN
WELCOME $?
PLAY
