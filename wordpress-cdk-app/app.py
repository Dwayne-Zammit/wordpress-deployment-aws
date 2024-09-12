#!/usr/bin/env python3
import os

import aws_cdk as cdk

from wordpress_cdk_app.wordpress_cdk_app_stack import WordpressCdkAppStack


app = cdk.App()
WordpressCdkAppStack(app, "WordpressCdkAppStack",
    env=cdk.Environment(account=os.getenv('CDK_DEFAULT_ACCOUNT'), region='eu-west-1'),
    )

app.synth()
