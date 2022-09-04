#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align -t -c"

# is there an arg1
if [[ ! $1 ]]
#no arg1
then
  echo -e "Please provide an element as an argument."

# ar1 exists, then:
else
  
  # can't "WHERE" int = str, workaround
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name = '$1'")
  fi

  # is arg1 in database?
  if [[ $ATOMIC_NUMBER =~ ^[0-9]+$ ]]
  
  # element found
  then
    # querying data
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    M_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    B_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    TYPE=$($PSQL "SELECT type from types INNER JOIN properties USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
    
    #data print on screen
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $M_POINT celsius and a boiling point of $B_POINT celsius."
    
  #element is not found in data base
  else
    echo "I could not find that element in the database."
  fi
fi

