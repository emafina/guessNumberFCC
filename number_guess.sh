#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=bikes --tuples-only -c"

SEARCH() {
  
}

LOGIN() {
  echo "Enter your username:"
  read NAME
}
RN=$(( 1+RANDOM%1000 ))
echo $RN

