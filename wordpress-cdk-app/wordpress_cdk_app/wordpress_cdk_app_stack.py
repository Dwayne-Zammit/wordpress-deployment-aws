from aws_cdk import (
    Stack,
    aws_ec2 as ec2,
)
from constructs import Construct
from aws_cdk import CfnOutput
import aws_cdk as cdk
from wordpress_cdk_app.helpers.helpers import test_keypair_exists

class WordpressCdkAppStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Define the VPC
        vpc = ec2.Vpc(self, "MyVpc", max_azs=1)  # Max 1 Availability Zone for free tier

        # Define the security group
        security_group = ec2.SecurityGroup(
            self, "Wordpress App Security Groups",
            vpc=vpc,
            description="Allow SSH and HTTP traffic",
            allow_all_outbound=True
        )
        security_group.add_ingress_rule(
            ec2.Peer.any_ipv4(), 
            ec2.Port.tcp(22), 
            "Allow SSH access"
        )
        security_group.add_ingress_rule(
            ec2.Peer.any_ipv4(), 
            ec2.Port.tcp(80), 
            "Allow HTTP access"
        )

        key_name = "wordpress-app-keypair"
        key_exists = test_keypair_exists(name=key_name)

        if key_exists:
            # if key exists, the function returns the key id as the second object
            ssh_key_id = key_exists[1]
            ec2_ssh_key_pair: ec2.KeyPair = ec2.KeyPair.from_key_pair_name(self, id=ssh_key_id, key_pair_name=key_name)
        else:
            ec2_ssh_key_pair: ec2.KeyPair = ec2.KeyPair(self, 
                f"{key_name}",
                key_pair_name=key_name,
                physical_name=key_name,
                format=ec2.KeyPairFormat.PEM
                )
            ec2_ssh_key_pair.apply_removal_policy(cdk.RemovalPolicy.RETAIN)            


        # Define the EC2 instance
        instance = ec2.Instance(
            self, "wordpress-ec2-instance",
            instance_type=ec2.InstanceType("t2.micro"),  # Free tier eligible
            machine_image=ec2.MachineImage.generic_linux({
                "eu-west-1": "ami-03cc8375791cb8bcf"
            }),            
            vpc=vpc,
            security_group=security_group,
            key_pair=ec2_ssh_key_pair
        )

        # Output the public IP
        output = CfnOutput(
            self, "InstancePublicIp",
            value=instance.instance_public_ip,
            description="The public IP address of the EC2 instance"
        )
