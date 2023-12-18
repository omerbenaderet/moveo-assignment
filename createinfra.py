from subprocess import run

# Run create VPC and SG for packer
run("terraform apply -target module.vpc -target aws_security_group.ssh", shell=True)

# Run commands to get terraform output into variables
env_subnet = run("terraform output public_subnet", capture_output=True, shell=True, text=True).stdout.strip()
env_sg = run("terraform output sg_ssh_id", capture_output=True, shell=True, text=True).stdout.strip()

# Function to replace string in a file
def ReplaceString(file, old, new):
    fin = open(file, "rt")
    data = fin.read()
    data = data.replace(old, new)
    fin.close()
    fin = open(file, "wt")
    fin.write(data)
    fin.close()

# Replace subnet and SG strings in packer code
ReplaceString("minikube-ami.json", "<env_subnet>", env_subnet)
ReplaceString("minikube-ami.json", "<env_sg>", env_sg)

# Run packer to create AMI with minikube
packer_ami = run("packer build -machine-readable minikube-ami.json | awk -F, '$0 ~/artifact,0,id/ {print $6}'", capture_output=True, shell=True, text=True).stdout.strip()
packer_ami = packer_ami.replace("us-east-1:", "")

# Replace the ami image in tf file
ReplaceString("ec2.tf", "<env_ami>", packer_ami)

# Run full terraform
run("terraform apply", shell=True)