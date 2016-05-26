#!/bin/bash

# run the script with argument -h  for usage

# Define usage
usage () {
	echo -e "\n#### service monitoring script\n\tUsage: ./`basename $0` \n\tfor running on remote machine\n\t./`basename $0` <remotehostip> <loginuser>"
        exit
}

if [ "$1" == "-h" ] 
then
  usage
fi

#define paramters for service1
remote_host11=1.2.3.4
remote_host12=1.4.5.6
remote_port11=40
#define parameter for service2
remote_host21=2.3.4.5
remote_port21=60


# ----------------------------------
# Service 1 function
# ----------------------------------
service1() {
service_1=false
sudo timeout 2 /bin/bash -c "cat < /dev/null > /dev/tcp/$1/$3" 2>&1 /dev/null
if [ "$?" -eq 0 ]; then
sudo timeout 2 /bin/bash -c "cat < /dev/null > /dev/tcp/$2/$3" 2>&1 /dev/null
  if [ "$?" -eq 0 ]; then
    service_1=true
  fi
fi
echo $service_1
}

# ----------------------------------
# service 2  function
# ----------------------------------
service2() {
service_2=false
sudo timeout 2 /bin/bash -c "cat < /dev/null > /dev/tcp/$1/$2" 2>&1 /dev/null
if [ "$?" -eq 0 ]; then
  service_2=true
fi
echo $service_2
}

# ----------------------------------
# main function
# ----------------------------------
main() {
 result1="service_a is not_running"
 result2="service_o is not_running"
  
 if [ "$(service1 $1 $2 $3)" == "true" ]; then
   result2="service_o is running"
   if [ "$(service2 $4 $5)" == "true" ]; then
   result1="service_a is running"
   fi 
 elif [ "$(service2 $4 $5)" == "true" ]; then
   result2="service_o is running"
 fi

 echo $result1,$result2 | sed s/,/\\n/g
}

# ----------------------------------
# run the main function either on local or remote machine
# ----------------------------------
if [ $1 ]; then
   if [ -z $2 ]; then
    echo -e "enter the login user"
    usage 
    exit 1
   fi
   
   sudo /usr/bin/ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $2@$1 "
   $(typeset -f); 
   main $remote_host11 $remote_host12 $remote_port11 $remote_host21 $remote_port21
   "
else
   main $remote_host11 $remote_host12 $remote_port11 $remote_host21 $remote_port21
fi 

