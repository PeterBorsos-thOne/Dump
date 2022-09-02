#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

#for testing
#Q=$($PSQL "TRUNCATE TABLE appointments")

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN() {
    if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to My Salon, how can I help you?"
  fi
  
  #write out options
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id ASC")" | while IFS="|" read SER_ID SERVICE_NAME
  do
    if [[ $SER_ID =~ [1-9]+$ ]]
    then
      echo "$SER_ID) $SERVICE_NAME"
    fi
  done

  read SERVICE_ID_SELECTED
  NUM_SER="$($PSQL "SELECT COUNT(service_id) FROM services")"

  #is SERVICE_ID_SELECTED a number
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #is SERVICE_ID_SELECTED's num in the list
    if [[ $SERVICE_ID_SELECTED -le $NUM_SER ]]
    then
    SERVICE_HANDELER $SERVICE_ID_SELECTED
    else
      # return to main menu
      MAIN "I could not find that service. What would you like today?"
    fi
  else
    # return to main menu
    MAIN "I could not find that service. What would you like today?"
  fi

}

SERVICE_HANDELER() {
  #prompt for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  #is that phone exist?
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #does customer exist
  if [[ $CUSTOMER_NAME ]]
  then
  
    #make appointment
    MAKE_APPOINTMENT $CUSTOMER_NAME $1
  else

    # write in new customer
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    NAME_INPUT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

    #make appointment
    MAKE_APPOINTMENT $CUSTOMER_NAME $1
  fi
}

MAKE_APPOINTMENT() {
  #arg1 name of CUSTOMER_NAME, arg2 SERVICE_ID_SELECTED
  
  #get customer_id
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$1'")
  echo -e "\nWhat time would you like your cut, $1?"
  read SERVICE_TIME
  
  #input appointment into db
  MAKE_APP=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUST_ID, $2, '$SERVICE_TIME')")
 
  echo -e "\nI have put you down for a $($PSQL "SELECT name FROM services WHERE service_id = $2") at $SERVICE_TIME, $1.\n"

}
MAIN
