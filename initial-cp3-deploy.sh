#!/bin/bash

#####################################################################################
#This script is run on the remote server. It performs all the steps that one would  #
#do manually on the server.                                                         #
#e.g git pull, installing dependancies, restarting gunicorn                         #
#####################################################################################

set -e

### configurations###

APP_DIR=/var/www/brighteventsapi
GIT_URL=https://github.com/mirr254/Bright-Events.git

###Automation steps ###

set -x

#set up nginx
function setUpNginx {

    echo "Setting up nginx server ..."

    sudo apt-get update #update server libraries
    sudo apt-get install nginx

    #the following language configs are when the erro unsupported locale setting appears
    export LANGUAGE=en_US.UTF-8 
    export LANG=en_US.UTF-8 export LC_ALL=en_US.UTF-8 
    sudo locale-gen en_US.UTF-8

    #remove the nginx default pages
    sudo rm /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

    #create a proxy config file and a symlink to it in sites enabled
    cat > /etc/nginx/sites-available/brightevents.com << ENDOFFILE
server {
    listen 80;
    location / {
        proxy_pass http:127.0.0.1:8000/;
    }
}
ENDOFFILE

#create a symlink from sites-enabled to point to point to the  brightevents.com file created above
   sudo ln -s /etc/nginx/sites-available/brightevents.com /etc/nginx/sites-enabled/brightevents.com

    #restart the webserver
    sudo service nginx restart

    echo "Done setting up nginx server :)"
     
}

#flask API configurations
function setUpApi {

    echo " Setting up app....."

    #install pip3
    sudo apt-get install python3-pip

    #install virtualenv on the system
    sudo pip3 install virtualenv

    #cd to app directory
    sudo mkdir $APP_DIR
    cd $APP_DIR

    #create virtue env
    sudo virtualenv venv-api

    #activate the venv
    source venv-api/bin/activate

    #clone the repo 
    sudo git clone $GIT_URL

    #cd to the newly created directory
    cd Bright-Events

    # install dependancies/requirements
    sudo pip3 install -r requirements.txt

    #activate the enviroment variables
    source .env

    echo "Running the application..."
    
    #run the app using gunicorn
    gunicorn run:app

}

setUpNginx

setUpApi