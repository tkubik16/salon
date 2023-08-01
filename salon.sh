#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  # get list of services
  SERVICES_RESULT=$($PSQL "SELECT * FROM services")
  # Display list of services
  echo "$SERVICES_RESULT" | while read SERVICE_ID BAR NAME
  do
    echo $SERVICE_ID\) $NAME
  done
  # read in chosen service
  read SERVICE_ID_SELECTED
  # check if said service is a number and a valid number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get the service with that id
    SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if service doesnt exist send to main menu
    if [[ -z $SERVICE_RESULT ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # if service exists send to ask for phone number
      GET_CUSTOMER_INFO $SERVICE_ID_SELECTED
    fi
    
    
  fi


}

GET_CUSTOMER_INFO( ) {
  SERVICE_ID_SELECTED=$1
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nWhat's your phone number?"

  # read in phone number
  read CUSTOMER_PHONE
  # get databse results for customers with that phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then
    # if customer doesnt exist
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # add customer to database with name and number
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  # ask a time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # schedule the appoitment
  
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  SCHEDULE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


MAIN_MENU