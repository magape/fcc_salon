#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

# get list of services
SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
# display list of services
echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done
# get service_id
read SERVICE_ID_SELECTED
SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

# while service_id is not valid display services and request a service.
while [[ -z $SERVICE_ID ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  # display list of services
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # get service_id
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
done

# get customer phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
DB_CUSTOMER_PHONE=$($PSQL "SELECT phone FROM  customers WHERE phone = '$CUSTOMER_PHONE';")
# if customer doesn't exist
if [[ -z $DB_CUSTOMER_PHONE ]]
then
  # get new customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # insert new customer (name, phone_number)
  INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
fi

# get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID;")

# get service time
echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
read SERVICE_TIME

# get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# make appointment
MAKE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")
echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME.\n"
