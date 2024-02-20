#!/bin/bash
PSQL="psql --quiet --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))
NUM_CHECK="^[0-9]+"
QUANTITY=1

echo Enter your username:
read USERNAME

#check username in database
CURRENT_USER=$($PSQL "SELECT username FROM game_register WHERE username='$USERNAME'")
#if not, insert in database
if [[ -z $CURRENT_USER ]]
then
  #if not, insert in database
  $PSQL "INSERT INTO game_register(username, games_played, best_game) VALUES('$USERNAME', 0, 50000)"
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM game_register WHERE username='$CURRENT_USER'")
  BEST_GAME=$($PSQL "SELECT best_game FROM game_register WHERE username='$CURRENT_USER'")
  echo "Welcome back, $CURRENT_USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
$PSQL "UPDATE game_register SET games_played = games_played + 1 WHERE username='$USERNAME'"
echo Guess the secret number between 1 and 1000:
read NUMBER_GUESS

while ! [[ $NUMBER_GUESS =~ $NUM_CHECK ]]
do
  echo That is not an integer, guess again:
  read NUMBER_GUESS
done

if [[ $NUMBER_GUESS = $SECRET_NUMBER ]]
then
  $PSQL "UPDATE game_register SET best_game=1 WHERE username='$USERNAME'"
  QUANTITY=$($PSQL "SELECT best_game FROM game_register WHERE username='$USERNAME'")
else
  while [[ $NUMBER_GUESS != $SECRET_NUMBER ]]
  do
    ((QUANTITY++))
    if [[ $NUMBER_GUESS > $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read NUMBER_GUESS
    else
      echo "It's higher than that, guess again:"
      read NUMBER_GUESS
    fi
  done
  STUTEST=$(( QUANTITY +1 - 1))
  BEST_GAME=$($PSQL "SELECT best_game FROM game_register WHERE username='$USERNAME'")
  if [ $STUTEST -lt $BEST_GAME ]
  then
  $PSQL "UPDATE game_register SET best_game=$STUTEST WHERE username='$USERNAME'"
  fi
fi

echo "You guessed it in $STUTEST tries. The secret number was $SECRET_NUMBER. Nice job!"