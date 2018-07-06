#!/bin/bash

#####################################################################################
#This script is run on the remote server. It performs all the steps that one would  #
#do manually on the server.                                                         #
#e.g git pull, installing dependancies, restarting gunicorn server                  #
#####################################################################################

####################################################################################
# Kindly read the instructions before using the script.                            #
# Set  your enviroment  variables with your own keys.                               #    
# follow these examples or  template                                            
# export APP_MAIL_PASSWORD='rqwg'
# export APP_MAIL_USERNAME='samer@gmail.com'
# export APP_SETTINGS='production' -> can be development
# export SECRET_KEY='this is suoer scret key'
# export SECURITY_PASSWORD_RESET_SALT='securiyt password r3set'
# export SECURITY_PASSWORD_SALT='securiyt password s2lt'
# export DATABASE_URL='postgress url for development'
# export RDS_USERNAME='shgg'
# export RDS_PASSWORD='shadff'
# export RDS_HOSTNAME='db hostname url '
# export RDS_DB_NAME='dbname'
# export RDS_PORT=5432
#################################################################################

set -e  #exit immediately if a command  exits with non-zero status

### configurations###

APP_DIR=/var/www/brighteventsapi
API_DIR=/var/www/brighteventsapi/Bright-Events
GIT_URL=https://github.com/mirr254/Bright-Events.git

###Automation steps ###

set -x #print commands and their args as they are  executed

#set up nginx
function setUpNginx {

    echo "Setting up nginx server ..."

    sudo apt-get update #update server packages
    sudo apt-get install nginx

    #the following language configs are when the error unsupported locale setting appears
    echo "++++setting up locale languages...++++"
    export LANGUAGE=en_US.UTF-8 
    export LANG=en_US.UTF-8 export LC_ALL=en_US.UTF-8 
    sudo locale-gen en_US.UTF-8

    #remove the nginx default pages
    sudo rm /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

    #create a proxy config file and a symlink to it in sites enabled
    sudo touch /etc/nginx/sites-available/brightevents.com
    sudo chown -R $USER:$USER /etc/nginx/sites-available/brightevents.com  #assign ownership to the account that we are currently signed in. easily edit content
    
    sudo cat > /etc/nginx/sites-available/brightevents.com << ENDOFFILE
        server {
            listen 80;
            server_name deploytut.tk www.deploytut.tk;
            location / {
                proxy_pass http://127.0.0.1:8000/;
            }
        }
ENDOFFILE

  #create a symlink from sites-enabled to point to point to the  brightevents.com file created above

   sudo ln -f -s /etc/nginx/sites-available/brightevents.com /etc/nginx/sites-enabled/brightevents.com #-f to remove other symlink files created

    #restart the webserver
    sudo service nginx restart

    echo "Done setting up nginx server :)"
     
}

#set up ssl from letscrypt
function setUpSSl {
    echo "+++++++++ Setting up SSL for the server +++++++++++++ "
    #add certbot's team PPA to list of repos
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install python-certbot-nginx

    #use certbot nginx plugin for certificate installation
    sudo certbot --nginx #-> will get cert and certbot will edit nginx conf automatically

}

#flask API configurations
function setUpApi {

    echo " ++++ Setting up app..... +++++"

    #install pip3
    sudo apt-get install python3-pip

    #install virtualenv on the system
    sudo pip3 install virtualenv

    #cd to app directory
    if [ -d $APP_DIR ] ; then
        cd $APP_DIR
    else
        sudo mkdir $APP_DIR
        cd $APP_DIR
    fi
    

    #create virtue env
    sudo virtualenv venv-api

    #activate the venv
    source venv-api/bin/activate

    #check if  Bright-Events dir exist and remove it
    if [[ -d $API_DIR ]] ; then
        sudo rm -rf $API_DIR
    fi

    #clone the repo 
    sudo git clone $GIT_URL

    #cd to the newly created directory
    cd Bright-Events

    # install dependancies/requirements
    sudo pip3 install -r requirements.txt

    echo "Running the application..."
    
    #run the app using gunicorn
    gunicorn run:app

}


setUpNginx

setUpSSl

setUpApi