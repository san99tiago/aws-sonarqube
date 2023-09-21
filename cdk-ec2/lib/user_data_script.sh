#!/bin/bash

# Enable extra logging
set -x

# Refresh environment variables
source /etc/profile

# Update OS and install Java
echo "----- Updating OS -----"
sudo yum update -y

# Install and Initialize SSM Agent
echo "----- Initializing SSM Agent -----"
sudo yum install -y https://s3.region.amazonaws.com/amazon-ssm-region/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Install Instance Connect
echo "----- Initializing EC2 Instance Connect Agent -----"
sudo yum install -y ec2-instance-connect

# Install Amazon CloudWatch Agent
echo "----- Initializing CloudWatch Agent -----"
sudo yum install -y amazon-cloudwatch-agent

# Create the necessary folders and permissions
mkdir /home/config
sudo chmod 775 /home/config

# Copy the necessary S3 files for OpenAI Chatbot execution
echo "----- Downloading source code from S3 bucket -----"
aws s3 cp "s3://${BUCKET_NAME}/config/" /home/config/ --recursive

# Show the downloaded files
echo "----- Source code files are -----"
ls -lrt /home/config/

# Configure CW agent with downloaded config file (note: the file was previously created with the CW Agent Wizard)
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/home/config/cw-agent-config.json

# Install dependencies
echo "----- Installing dependencies -----"
sudo yum install -y java-17-amazon-corretto-devel
java -version

# Installing SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.2.1.78527.zip
unzip sonarqube-10.2.1.78527.zip

# Move SonarQube to expected /opt/sonarqube path
sudo mv sonarqube-10.2.1.78527 /opt/sonarqube

# TODO: Add SonarQube config for the DB endpoint in a secure fashion
# echo -e "sonar.jdbc.username=sonar \n sonar.jdbc.password=sonar \n sonar.jdbc.url=jdbc:postgresql://localhost/sonar" >> /opt/sonarqube/conf/sonar.properties

# Configure new user for SonarQube
groupadd sonar
sudo usermod -a -G sonar ec2-user
chown -R ec2-user:sonar /opt/sonarqube
chown ec2-user:sonar /opt/sonarqube/bin/linux-x86-64/sonar.sh

# Start SonarQube server as the "ec2-user" (Important: not possible to run as root due to ES limitations)
su ec2-user -c '/opt/sonarqube/bin/linux-x86-64/sonar.sh start'
