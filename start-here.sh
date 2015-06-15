###
#
# ansible-ec2-hadoop-cluster
# Written by: Jeffrey Aven
#             Aven Solutions Pty Ltd
#             http://avensolutions.com
#
# Prerequisities:
#    PEM File needs to be present in the Ansible control node users home directory
#    Permissions need to be set to 400
#
###

# read command line options
TEMP=`getopt -o a::s::n::k:: --long awsaccesskey::,awsecretkey::,clustername::,pemkey:: -n start-here.sh -- "$@"`
eval set -- "$TEMP"

while true ; do
case "$1" in
-a|--awsaccesskey)
case "$2" in
"") AWS_ACCESS_KEY_ID='enter aws access key' ;  shift 2 ;;
*) AWS_ACCESS_KEY_ID=$2 ; shift 2 ;;
esac ;;
-s|--awsecretkey)
case "$2" in
"") AWS_SECRET_ACCESS_KEY='enter aws secret key' ;  shift 2 ;;
*) AWS_SECRET_ACCESS_KEY=$2 ; shift 2 ;;
esac ;;
-n|--clustername)
case "$2" in
"") HDPCLUSTERNAME='enter clustername' ;  shift 2 ;;
*) HDPCLUSTERNAME=$2 ; shift 2 ;;
esac ;;
-k|--pemkey)
case "$2" in
"") PEMKEY='enter pem key' ;  shift 2 ;;
*) PEMKEY=$2 ; shift 2 ;;
esac ;;
--) shift ; break ;;
*) echo "internal error" ; exit 1 ;;
esac
done

# clean up inventory directories
rm -rf ~/.ansible/local_inventory

# enter AWS_ACCESS_KEY_ID
rm -f dialogtmp
dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--title "Menu" \
--ok-label "Select" \
--clear \
--cancel-label "Exit" \
--inputbox "Enter AWS_ACCESS_KEY" 13 49 $AWS_ACCESS_KEY_ID 2>dialogtmp
if [ "$?" != "0" ]
then
exit
else
AWS_ACCESS_KEY_ID=$(cat dialogtmp)
fi

# enter AWS_SECRET_ACCESS_KEY
rm -f dialogtmp
dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--title "Menu" \
--ok-label "Select" \
--clear \
--cancel-label "Exit" \
--inputbox "Enter AWS_SECRET_KEY" 13 49 $AWS_SECRET_ACCESS_KEY 2>dialogtmp
if [ "$?" != "0" ]
then
exit
else
AWS_SECRET_ACCESS_KEY=$(cat dialogtmp)
fi

# enter HDPCLUSTERNAME
rm -f dialogtmp
dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--title "Menu" \
--ok-label "Select" \
--clear \
--cancel-label "Exit" \
--inputbox "Enter CLUSTER NAME" 13 49 $HDPCLUSTERNAME 2>dialogtmp
if [ "$?" != "0" ]
then
exit
else
HDPCLUSTERNAME=$(cat dialogtmp)
fi

# enter PEMKEY

# check if PEMKEY exists in home directory

PEMFILE=$(dialog --stdout --no-lines --title "Select PEM File, Press [SPACE] and then [OK]" --fselect $HOME/$PEMKEY.pem 14 48)
if [ -z "$PEMFILE" ]
then
echo "no file selected"
fi

# get Edge node instance type
rm -f dialogtmp
dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--title "Menu" \
--ok-label "Select" \
--clear \
--cancel-label "Exit" \
--radiolist "Select Edge Node Instance Type:" 13 49 5 \
 1 "t1.micro" off \
 2 "m3.medium" off \
 3 "m3.large" on \
 4 "m3.xlarge" off \
 5 "m3.2xlarge" off 2>dialogtmp
if [ "$?" != "0" ]
then
exit
else
SEL=$(cat dialogtmp)
fi

case $SEL in
"1")
EDGENODEINSTTYPE="t1.micro"
;;
"2")
EDGENODEINSTTYPE="m3.medium"
;;
"3")
EDGENODEINSTTYPE="m3.large"
;;
"4")
EDGENODEINSTTYPE="m3.xlarge"
;;
"5")
EDGENODEINSTTYPE="m3.2xlarge"
;;
esac

# get Master node instance type 
rm -f dialogtmp
dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--title "Menu" \
--ok-label "Select" \
--clear \
--cancel-label "Exit" \
--radiolist "Select Master Node Instance Type:" 13 49 5 \
 1 "t1.micro" off \
 2 "m3.medium" off \
 3 "m3.large" on \
 4 "m3.xlarge" off \
 5 "m3.2xlarge" off 2>dialogtmp
if [ "$?" != "0" ]
then
exit
else
SEL=$(cat dialogtmp)
fi

case $SEL in
"1")
MASTERNODEINSTTYPE="t1.micro"
;;
"2")
MASTERNODEINSTTYPE="m3.medium"
;;
"3")
MASTERNODEINSTTYPE="m3.large"
;;
"4")
MASTERNODEINSTTYPE="m3.xlarge"
;;
"5")
MASTERNODEINSTTYPE="m3.2xlarge"
;;
esac

# get Slave node instance type
rm -f dialogtmp
dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--title "Menu" \
--ok-label "Select" \
--clear \
--cancel-label "Exit" \
--radiolist "Select Slave Node Instance Type:" 13 49 5 \
 1 "t1.micro" off \
 2 "m3.medium" off \
 3 "m3.large" on \
 4 "m3.xlarge" off \
 5 "m3.2xlarge" off 2>dialogtmp
if [ "$?" != "0" ]
then
exit
else
SEL=$(cat dialogtmp)
fi

case $SEL in
"1")
SLAVENODEINSTTYPE="t1.micro"
;;
"2")
SLAVENODEINSTTYPE="m3.medium"
;;
"3")
SLAVENODEINSTTYPE="m3.large"
;;
"4")
SLAVENODEINSTTYPE="m3.xlarge"
;;
"5")
SLAVENODEINSTTYPE="m3.2xlarge"
;;
esac

# get Slave node volume size
rm -f dialogtmp
dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--title "Menu" \
--ok-label "Select" \
--clear \
--cancel-label "Exit" \
--inputbox "Enter Slave Node Volume Size (GB)" 13 49 "300" 2>dialogtmp
if [ "$?" != "0" ]
then
exit
else
SLAVENODEVOLSIZE=$(cat dialogtmp)
fi

# get Number of Nodes
rm -f dialogtmp
dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--title "Menu" \
--ok-label "Select" \
--clear \
--cancel-label "Exit" \
--inputbox "Enter Number of Task Nodes" 13 49 "3" 2>dialogtmp
if [ "$?" != "0" ]
then
exit
else
NONODES=$(cat dialogtmp)
fi

# confirm
CONFTEXT="You are about to deploy a new cluster with the following properties:"
CONFTEXT="$CONFTEXT\n\nCLUSTERNAME=$HDPCLUSTERNAME"
CONFTEXT="$CONFTEXT\nPEMFILE=$PEMFILE"
CONFTEXT="$CONFTEXT\nEDGENODEINSTTYPE=$EDGENODEINSTTYPE"
CONFTEXT="$CONFTEXT\nMASTERNODEINSTTYPE=$MASTERNODEINSTTYPE"
CONFTEXT="$CONFTEXT\nSLAVENODEINSTTYPE=$SLAVENODEINSTTYPE"
CONFTEXT="$CONFTEXT\nSLAVENODEVOLSIZE=$SLAVENODEVOLSIZE"
CONFTEXT="$CONFTEXT\nNUMBER OF NODES=$NONODES"
CONFTEXT="$CONFTEXT\n\nPress [OK] to continue or [ESC] to cancel"

dialog \
--backtitle "Deploy HDP Cluster in AWS EC2" --no-lines \
--msgbox "$CONFTEXT" 18 49
if [ "$?" != "0" ]
then
clear
echo "Operation cancelled"
exit
else
clear
# create instances
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID  \
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
HDPCLUSTERNAME=$HDPCLUSTERNAME \
PEMKEY=$PEMKEY \
EDGENODETYPE=$EDGENODEINSTTYPE \
MASTERNODETYPE=$MASTERNODEINSTTYPE \
SLAVENODETYPE=$SLAVENODEINSTTYPE \
NUMNODES=$NONODES \
EBSVOLSIZE=$SLAVENODEVOLSIZE \
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -v  ./ansible/create-instances.yml
# configure common
HDPCLUSTERNAME=$HDPCLUSTERNAME \
PEMKEY=$PEMKEY \
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -v -i ~/.ansible/local_inventory/all_instances  ./ansible/configure-instances-common.yml
# configure edge node
HDPCLUSTERNAME=$HDPCLUSTERNAME \
PEMKEY=$PEMKEY \
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -v -i ~/.ansible/local_inventory/edgenode_instance  ./ansible/configure-edge-node.yml
fi 
