#!/bin/bash

function print_line()
{
    echo "---------------------------------"
}

function install_packages()
{
    sudo yum install -y jq  > ${TERM} 2>&1
    print_line
    echo "Installing aws cli v2"
    print_line
    aws --version | grep aws-cli\/2 > /dev/null 2>&1
    if [ $? -eq 0 ] ; then
        cd $current_dir
	return
    fi
    current_dir=`pwd`
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > ${TERM} 2>&1
    unzip -o awscliv2.zip > ${TERM} 2>&1
    sudo ./aws/install --update > ${TERM} 2>&1
    cd $current_dir
}

function install_postgresql()
{
    print_line
    echo "Installing Postgresql client"
    print_line
    #sudo amazon-linux-extras install -y postgresql14 > ${TERM} 2>&1
    #sudo yum install -y postgresql-contrib sysbench > ${TERM} 2>&1
    sudo sh -c "echo \"[pgdg15]
name=PostgreSQL 15 for Redhat Linux – x86_64
baseurl=https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-7.10-x86_64
enabled=1
gpgcheck=0\" > /etc/yum.repos.d/pgdg.repo"

    sudo yum makecache
    sudo yum repolist 
    sudo yum install libzstd
    sudo yum  install postgresql15
    export PATH=${PATH}:/usr/pgsql-15/bin

}

function configure_pg()
{
    #AWSREGION=`aws configure get region`

    PGHOST=`aws rds describe-db-cluster-endpoints \
        --db-cluster-identifier apg-pgtle \
        --region $AWS_REGION \
        --query 'DBClusterEndpoints[0].Endpoint' \
        --output text`

    # Retrieve credentials from Secrets Manager - Secret: apg-pgtle-secret
    CREDS=`aws secretsmanager get-secret-value \
        --secret-id apg-pgtle-secret \
        --region $AWS_REGION | jq -r '.SecretString'`

    export PGUSER="`echo $CREDS | jq -r '.username'`"
    export PGPASSWORD="`echo $CREDS | jq -r '.password'`"
    export PGHOST

    # Persist values in future terminals
    echo "export PGUSER=$PGUSER" >> /home/ec2-user/.bashrc
    echo "export PGPASSWORD='$PGPASSWORD'" >> /home/ec2-user/.bashrc
    echo "export PGHOST=$PGHOST" >> /home/ec2-user/.bashrc
    echo "export PATH=\${PATH}:/usr/pgsql-15/bin" >> /home/ec2-user/.bashrc

}

function install_c9()
{
    print_line
    echo "Installing c9 executable"
    npm install -g c9
    print_line
}

# Main program starts here

if [ ${1}X == "-xX" ] ; then
    TERM="/dev/tty"
else
    TERM="/dev/null"
fi

echo "Process started at `date`"
install_packages

export AWS_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r`
echo "Current region is ${AWS_REGION}"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text) 
 
install_postgresql
configure_pg
print_line
install_c9
print_line
print_line

echo "Process completed at `date`"
