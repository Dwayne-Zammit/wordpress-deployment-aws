import boto3
import os


def get_cloudformation_output(export_name):
    """
    Retrieves the value of a CloudFormation output given the export name.

    Args:
        export_name (str): The name of the CloudFormation export.

    Returns:
        The value of the CloudFormation output.
    """
    # Create CloudFormation client
    cloudformation = session.client("cloudformation")

    # Retrieve the export information
    try:
        response = cloudformation.list_exports()
        exports = response["Exports"]
    except cloudformation.exceptions.InvalidClientTokenId:
        print("Invalid AWS credentials.")
        return None

    # Get the value of the export
    for export in exports:
        print(export["Name"])
        if export["Name"] == export_name:
            return export["Value"]

    # Export name not found
    return None


##############
### config ###
##############

profile_name = "default"

################
### do stuff ###
################

# init boto3 session (assumes you have AWS profile in ~/.aws/credentials named 'default')
session = boto3.Session(profile_name=profile_name)


# get logstash ssh key id
ssh_key_id = get_cloudformation_output("wordpress-app-keypair")

if ssh_key_id is None:
    print("Could not find wordpress app ssh key id. Are you using the correct profile?")
    exit(1)

# get ssh key param name
ssh_ssm_param_name = f"/ec2/keypair/{ssh_key_id}"

# get ssh key param value
ssm = session.client("ssm")

response = ssm.get_parameter(Name=ssh_ssm_param_name, WithDecryption=True)

# save ssm value to file
ssh_key_file_path = "C:\\temp\\burn-after-reading\\wordpress-app-keypair.pem"

# test if path exists and create if not
if not os.path.exists(os.path.dirname(ssh_key_file_path)):
    os.makedirs(os.path.dirname(ssh_key_file_path))

# save response to file
with open(ssh_key_file_path, "w") as ssh_key_file:
    ssh_key_file.write(response["Parameter"]["Value"])
    print(f"Wrote to file: \n{ssh_key_file_path}")
