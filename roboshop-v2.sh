#!/bin/bahs

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z04294741VQNEFJ1F5FHE"
DOMAIN_NAME="daws90.shop"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $# -lt 2 ]; then
    echo -e "$R ERROR:: Atleast 2 argument required $N"
    echo "USAGE: $0 [create/delete] [Instance1] [Instance2] ..."
    exit 1
fi

ACTION=$1
shift # first argument will be removed, Now $@ doesnt have create/delete

if [ ${ACTION,,} != "create" ] && [ ${ACTION,,} != "delete" ]; then
    echo -e "$R ERROR:: First arugment must be either create or delete $N"
    echo "USAGE: $0 [create/delete] [Instance1] [Instance2] ..."
    exit 1
fi
