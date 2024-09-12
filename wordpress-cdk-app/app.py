#!/usr/bin/env python3
import os
import aws_cdk as cdk
from wordpress_cdk_app.wordpress_cdk_app_stack import WordpressCdkAppStack

account = os.getenv('CDK_DEFAULT_ACCOUNT')
region = 'eu-west-1'

if not account:
    raise ValueError("Environment variable 'CDK_DEFAULT_ACCOUNT' is not set.")

app = cdk.App()
print(f"Deploying app to region {region}")
WordpressCdkAppStack(app, "WordpressCdkAppStack",
    env=cdk.Environment(account=account, region=region),
)

app.synth()
