#!/bin/bash

LOGS_DIR="/var/logs/roboshop"

sudo mkdir -p $LOGS_DIR
sudo chown -R ec2-user:ec2-user $LOGS_DIR
sudo chmod -R 755 $LOGS_DIR
LOGS_FILE="$LOGS_DIR/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST="mysql.daws90.shop"

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %h:%M:%S")

if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R Please run this script with root access $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing Python"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

rm -rf /app 
VALIDATE $? "Removing existing folder"

rm -rf /tmp/payment.zip
VALIDATE $? "Remove payment zip"

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOGS_FILE
cd /app 
unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded and extracted payment code"

pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOGS_FILE
VALIDATE $? "Created systemctl service"

systemctl daemon-reload &>>$LOGS_FILE
systemctl enable payment &>>$LOGS_FILE
systemctl restart payment &>>$LOGS_FILE
VALIDATE $? "Enable and restarted payment"