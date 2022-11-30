#!/usr/bin/bash

AWS="/usr/local/bin/aws"
JQ="/usr/bin/jq"
CUT="/usr/bin/cut"
WC="/usr/bin/wc"

if [[ "$AWS_EXECUTION_ENV" != "CloudShell" ]]; then
        echo "This script was designed to be executed from AWS CloudShell: https://aws.amazon.com/cloudshell/"
        exit 1
fi

LOGIN_DETAILS=$("$AWS" sts get-caller-identity --output json)
echo -n "Account: "
echo $LOGIN_DETAILS | "$JQ" -r '.Account'

echo -n "User: "
USER=$(echo $LOGIN_DETAILS | "$JQ" -r '.Arn' | "$CUT" -d: -f6)
echo "$USER"

if [[ "$USER" == "root" ]]; then
        echo -n "MFA: "
        MFA=$("$AWS" iam list-mfa-devices --output text | "$WC" -l)
        if [[ $MFA -ne 0 ]]; then
                echo "Enabled"
                echo
                echo "Please disable all MFA devices: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_disable.html"
        else
                echo "Disabled"
        fi
else
        echo
        echo "Please log in as the 'root' user and reexecute this script."
fi
