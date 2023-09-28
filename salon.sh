#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c" 

echo -e "\n~~~My Salon~~~\n"
echo -e "\nWelcome to my salon, how may I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then 
    echo $1
  fi
  #available Services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  #display availabile services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
  #select a service
  echo -e "\nEnter the number of the service you would like?\n" 
  SALON_SCHEDULE
}

SALON_SCHEDULE(){
  #Get Service Input
  read SERVICE_ID_SELECTED
  #Make sure input is valid
  SERVICE_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_SELECTED ]] 
  then
    MAIN_MENU "Please enter a valid option" 
  else
    #Continue with Appointment 
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_SELECTED'") 
    echo "What is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
    #if new customer
    if [[ -z $CUSTOMER_NAME ]] 
    then
      echo -e "\nI don't have a record for you, what's your name?"
      read CUSTOMER_NAME
      #Insert new customer
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE') ") 
    fi
    #Get appointment time
    SERVICE_NAME_FORMATED=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
    CUSTOMER_NAME_FORMATED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATED, $CUSTOMER_NAME_FORMATED?"
    read SERVICE_TIME
    SERVICE_TIME_FORMATED=$(echo $SERVICE_TIME | sed -r 's/^ *| *$//g')
    #get customer id 
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #Insert Appointment
    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES ($SERVICE_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')") 
    #Confirm appoitment
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."  
  fi
}

MAIN_MENU


