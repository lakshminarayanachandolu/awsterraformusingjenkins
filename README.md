Creating a Jenkins Pipeline to provision the Infrastructure in AWS using Terraform

First, set the source in git and check mine in the above for reference.
Next, we need to create a EC2 instance with minimal configuration such as amazon linux ami, instance type as t2.micro and a security group of allowing inbound ports ssh and 8080.
Create an AWS IAM role with an admin permissions for EC2 Service and attach to the above created EC2 instance. Because it allows the pipeline to run using the aws crednetials of the iam role attached to the EC2 instance.
After launching the instance, navigate to root user by command "sudo -i".
Install jenkins by using the following commands :
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  amazon-linux-extras install java-openjdk11 -y
  yum install jenkins -y && systemctl restart jenkins

After Installing the Jenkins, Install terraform and git by following commands :
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo yum -y install terraform
  sudo yum install git -y

After completion of Installation, Open web browser and enter the <public ip of ec2>:8080. You can see the jenkins configuration page.
Now, copy the path on the screen and enter the command in the ec2 instance by cat <path>.
Now, copy the password and paste it on the jenkins page.
Now, Complete the builtin plugins installation and create a profile by filling all the details such as username, password, mail, name etc..
After navigating to Dashboard in Jenkins, Create a Job by clicking on New Item and filling the name, selecting the pipeline and click on "Ok".
Now, Go to the pipeline you have created and click on "Configure" and write the pipeline as given below :

  pipeline {
    agent any
    stages {
        stage("Checkout from GIT") {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/lakshminarayanachandolu/awsterraformusingjenkins.git'
            }
        }
        stage("Terraform INIT") {
            steps {
                sh 'terraform init'
            }
        }
        stage("Terraform APPLY") {
            steps{
                sh 'terraform apply --auto-approve'
            }
        }
    }
}
After that, click on save and click on "Build now" and check the status on that page.
After checking that it become successful, once navigate to AWS and check whether the resources are created or not.
