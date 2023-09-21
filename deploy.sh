#!/bin/bash
set -x

# Deploy CDK Stack
cd ./cdk-ec2
npm install .
cdk deploy --require-approval never
