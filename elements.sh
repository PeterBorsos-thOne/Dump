#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align -t -c"


if [[ ! $1 ]]
then
  #no arg1
  echo -e "Please provide an element as an argument."
else
  
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1 OR symbol = '$1' OR name = '$1'")

  if [[ $ATOMIC_NUMBER =~ ^[0-9]+$ ]]
  then
  #data writeout
  echo thinking
  #element is not found in data base
  else
    echo "I could not find that element in the database."
  fi
fi

