from subprocess import run

# Run commands to get terraform output into variables
env_subnet = run("terraform output public_subnet", capture_output=True, shell=True, text=True).stdout.strip()
env_sg = run("terraform output sg_ssh_id", capture_output=True, shell=True, text=True).stdout.strip()
minikube_ami = run("terraform output minikube_ami", capture_output=True, shell=True, text=True).stdout.strip()

# Destroy terraform
run("terraform destroy", shell=True)

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
ReplaceString("minikube-ami.json", env_subnet, "<env_subnet>")
ReplaceString("minikube-ami.json", env_sg, "<env_sg>")
ReplaceString("ec2.tf", minikube_ami, '"<env_ami>"')