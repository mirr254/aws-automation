# A script for autodeploying a python-flask web API

## Prerequistes
- User/Developer has a domain name
- User/Developer has set up database and has the database url ready

## Instructions
- Once an instance is created and user has `SSH` to it create a `.env` file and include the following content.


 `export APP_MAIL_PASSWORD='<mail password>' `   
 `export APP_MAIL_USERNAME='< mail username e.g sam@gmail.com >'`     
 `export APP_SETTINGS='production'`     
 `export SECRET_KEY='this is suoer scret key'`  
 `export SECURITY_PASSWORD_RESET_SALT='securiyt password r3set'`  
 `export SECURITY_PASSWORD_SALT='securiyt password s2lt'`    
 `export RDS_USERNAME='<db username>'`  
 `export RDS_PASSWORD='<db password>'`  
 `export RDS_HOSTNAME='<db hostname url> '`  
 `export RDS_DB_NAME='dbname'`  
 `export RDS_PORT=<db port number>`  

 - Activate the enviroment variables by running `source .env` in the same directory the `.env` file is.

- Clone this repo and.  
 `sudo git clone https://github.com/mirr254/aws-automation.git`  
 `cd aws-automation`
- open the file `initial-cp3-deploy.sh` with your favourite editor.   
`sudo vim initial-cp3-deploy.sh `

- on line  `49` of the script where we have `server_name deploytut.tk www.deploytut.tk` replace these 2 with your domain names. and save the file.
- make the script executable by ruuning the following command  
`sudo chmod +x initial-cp3-deploy.sh`

- Enjoy :)

