#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

# starts with INISIATAE at the bottom

INISIATAE() {
  echo -e "Enter your username:"
  read NAME

  # checking the name in data base
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")
  
  if [[ ! $USER_ID =~ ^[0-9]+$ ]]
  # user does not exist
  then
    echo -e "Welcome, $NAME! It looks like this is your first time here."
  
    # put them into data base
    INPUT_USER=$($PSQL "INSERT INTO users(name) VALUES('$NAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")

    # to the game
    THE_GAME

  # if user is already in data base
  else
    # get and print info about user
    GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID")
    
    echo -e "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

    # to the game
    THE_GAME $USER_ID
  
  fi
}


THE_GAME() {
  # inisiate the number that will be guessed
  SEC_NUM=$(( $RANDOM % 1000 + 1 ))
  GUESS=
  NUM_GUESS=0

  while [ true ]
  do
    # get num from user
    if [[ -z $GUESS ]]
    # have not guessed yet
    then
      echo -e "Guess the secret number between 1 and 1000:"
      read GUESS

    # have guessed
    else
      #is it a number
      if [[ $GUESS =~ ^[0-9]+$ ]]
      #it is a number
      then
        if [[ $GUESS -eq $SEC_NUM ]]
        #correct guess
        then
          #NUM_GUESS=$(( $NUM_GUESS + 1 )) # to incremnet NUM_GUESS
          break

        # guess is lower than secret number
        elif [[ $GUESS -gt $SEC_NUM ]]
        then
          echo -e "It's lower than that, guess again:"
          read GUESS
          
        # guess is higher than secret number
        else
          echo -e "It's higher than that, guess again:"
         read GUESS
        fi        

      #not a number
      else
      echo -e "That is not an integer, guess again:"
      read GUESS
      fi
    fi
    
    #increment number off guesses
    NUM_GUESS=$(( $NUM_GUESS + 1 ))
  done
  
  #win
  echo -e "You guessed it in $NUM_GUESS tries. The secret number was $SEC_NUM. Nice job!"
  
  #input game detailes into databae
  INPUT_RUN_DATA=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($1, $NUM_GUESS)")
}


INISIATAE
