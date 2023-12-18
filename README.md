Hi there!
Before we start, you need to have the above installed : 
- Python
- Terraform
- Packer
- awscli with credentials configured (or alternative way for AWS authentication) 
- Docker in case you want to build the Docker image by yourself.
  
To create the infrastructure please run CreateInfra.py .  
The script will first create with Terraform the VPC and Security Group with SSH to allow Packer to run, then it will change the a few values in the files and run Packer code and after that, it will run the whole Terraform code.  
  
The Packer code will create AMI image with Docker, kubectl and Minikube installed, in addition to few more things that needed to run minikube.  
It will also copy the file "nginx.yaml" to /home/ubuntu in the instance.  
  
The Terraform will create the EC2 instance in a private subnet with the AMI that created and will start the minikube cluster and run the nginx application.  
It will also create an Application Load Balancer for application.  
  
To get the ALB DNS name, you can check the Terraform output simply by running this command : terraform output alb_dns  
The ALB listenes at HTTP port 80.  
Please wait a few minutes before, for the instance will initialize completely.  
  
In the nginx directory you can see the nginx.yaml file used by minikube and the Dockerfile, index.html that has been used to build the docker image. I've pushed it to my user at DockerHub : omerba1000/yo-nginx  
  
Also, there is DestroyInfra.py for destroying Terraform infrastructure and change back the values in the files.
