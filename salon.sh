#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~Nana's 24hr Beauty Palace~~~~~\n"

SERVICE_MENU() {
  if [[ -n "$1" ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to Nana's Beauty Palace, please choose one of the options below to get started:"
  #get services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id") 
  #display available services
 
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  #check if selected service is legit
  if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]
  then
    SERVICE_MENU "Sorry, that service does not exist."
  else 
    SERVICE_ID_CHOSEN=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  fi

    if [[ -z "$SERVICE_ID_CHOSEN" ]]
    then
      SERVICE_MENU "Please choose a valid service number:"
    else 
      SERVICE_NAME=$(echo $SERVICE_ID_CHOSEN)
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z "$CUSTOMER_NAME" ]]
      then 
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        #insert customer name into customers
        INSERT_CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      #get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nHello $CUSTOMER_NAME, what time would you like to book your appointment?"
      read SERVICE_TIME
      #insert info into appointments table
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

      exit       
  fi
}

SERVICE_MENU