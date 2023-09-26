#!/bin/bash
NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

#if mongodb or mysql instanec type should be t3.micro ,for all others t2.micro
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-076d950dcb72cc617
DOMINE_NAME=devops.store
for i in "${NAMES[@]}"
do
  if [[ $i == "mongodb" || $i == "mysql" ]]
  then 
     INSTANCE_TYPE="t3.medium"
  else
     INSTANCE_TYPE="t2.micro"
  fi  
  echo "creating $i instance"

  IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE  --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
  echo "created $i instance: $IP_ADDRESS"

   aws route53 change-resource-record-sets --hosted-zone-id Z08310291HO6SKKR1U225 --change-batch '
   {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMINE_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{"Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done

#improvement
#check instance alredy created or not
#update route53 record   