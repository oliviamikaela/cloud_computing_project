# UNTESTED!!!

# For terraform  argument is number of workers , in format  -var="num_workers=2"
# Run this script without input argument, uses default number of workers
# > sh run_terraform.sh 

# Run this script with input number of workers, ex is 2. 
# > sh run_terraform.sh 2


terraform init
terraform plan
# check if input arg is empty  
if [ -z "$1" ]
  then terraform apply -auto-approve 
else 
  then terraform apply -var="num_workers=$1" -auto-approve

