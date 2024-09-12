from enum import Enum
from typing import List, Dict
from aws_cdk import (
    Stack,
    aws_ec2 as ec2,
)
from constructs import Construct
import aws_cdk as cdk
import boto3

def test_keypair_exists(name: str):
    ec2 = boto3.client("ec2")
    response = ec2.describe_key_pairs()
    key_pairs = response["KeyPairs"]
    for key_pair in key_pairs:
        if key_pair["KeyName"] == name:
            print(f"Key pair '{name}' already exists")
            key_pair_id = key_pair['KeyPairId']
            return True, key_pair_id
    print(f"Key pair '{name}' does not exist")
    return False