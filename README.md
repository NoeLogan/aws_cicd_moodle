# cicd-docker-wordpress-pipeline
Within this project we will be building and deploying a [Wordpress](https://wordpress.org/) application using a [Jenkins](https://www.jenkins.io/) CICD Pipeline and [Docker](https://www.docker.com/) acting as the application container. 


## Architecture
This architecture displays the Pipeline Checkout, Build, Test, Push, and Deployment process.

![image](https://user-images.githubusercontent.com/83971386/201048278-cd83be08-7417-4aa4-94c5-1c62daf20724.png)

## Prerequisites
* Docker installation - [steps](https://docs.docker.com/engine/install/)
* Docker-Compose setup - [steps](https://docs.docker.com/compose/)
* Virtualbox installation - [steps](https://www.virtualbox.org/wiki/Downloads) 
* Trivy installation - [steps](https://aquasecurity.github.io/trivy/v0.34/getting-started/installation/) or follow the instructions below.

## Build Process
This section details the steps required to Build, Test, Push and Deploy the Wordpress application via Docker using a Jenkins CI/CD Pipeline.

## Install Trivy
### 1. Clone the Git Repository
      sudo yum install git -y 
      cd /home
      git clone https://github.com/BJWRD/CI-CD/cicd-docker-wordpress-pipeline.git
      cd cicd-docker-wordpress-pipeline
      
### 2. Change file permissions
      chmod 700 trivy.sh
      
### 3. Execute the Trivy Script (This will install the trivy software)
      ./trivy.sh
      trivy -v

## Install Jenkins
###   1. Change directory to Jenkins 
      cd jenkins
      
###   2. Run Jenkins Container
Before we begin the Jenkins Installation, we need to ensure that Docker and Docker-Compose has been installed on the VM you are using. Please follow the steps within the 'Prerequisites' section to get started.

Once Docker and Docker-Compose has been installed, execute the following Docker-Compose command to start out Jenkins container in detatched mode. This will host our Jenkins Pipeline.

      docker-compose up -d
      
###   3. Unlocking Jenkins
After running the container you should be able to access the Jenkins application via web browser using ```http://localhost:8080``` or ```http://<host_ip>:8080```.

Initially you will notice that you are presented with a 'Unlock Jenkins' screen. To retrieve the requested 'Administrator password' you will need to enter the following docker command below to view the container logs and locate the password -
      
      docker logs <containerID>

Example:

<img width="656" alt="image" src="https://user-images.githubusercontent.com/83971386/195887709-16190167-11f1-405a-adf5-6e2537b0d7ae.png">

Once retrieved, copy and paste the password into the 'Administrator password' field -

<img width="848" alt="image" src="https://user-images.githubusercontent.com/83971386/195887952-7930b373-175c-4d99-81d6-31187fc86807.png">

###   4. Customize Jenkins
Select 'Install suggested plugins' and wait for the completed installation -

<img width="871" alt="image" src="https://user-images.githubusercontent.com/83971386/195888092-df15273c-bb37-4534-8af5-05bea6a46e3e.png">

Note: In the instance all of the plugins fail, you may need to enter the following commands to ensure a HTTP connection is established rather than HTTPS when pulling the Jenkins plugins -

      docker exec -it <containerID> bash
      sed -i 's/https/http/g' /var/jenkins_home/hudson.model.UpdateCenter.xml 
 
 Example:
 
<img width="704" alt="image" src="https://user-images.githubusercontent.com/83971386/195888177-aad8e0a2-8aa5-41ed-b440-6a039e70244f.png">

###   5. Creating Jenkins Admin User
You will then be presented with the following 'Create First Admin User' screen, enter details relevant to yourself and select 'Continue'.

<img width="781" alt="image" src="https://user-images.githubusercontent.com/83971386/195888296-ab95b2c2-dfce-4dc2-b50d-69b861c9bffe.png">

## Install Docker Pipeline Plugin 
From the Jenkins Dashboard, select the 'Manage Jenkins' option on the left-hand side, followed by 'Manage Plugins' and then the 'Available Plugins' widget.

Within the Search field, enter 'Docker Pipeline' and select the 'Install without restart'button -

<img width="731" alt="image" src="https://user-images.githubusercontent.com/83971386/195888404-2d7a605d-8bec-4e0b-9c3c-819ddcbf55b1.png">

<img width="371" alt="image" src="https://user-images.githubusercontent.com/83971386/195888471-8d6fcb01-742b-46cd-8bdb-f3549ee1b3d9.png">

## Adding Credentials
###   1. Adding Docker Hub Credentials
Before we begin with the Pipeline creation, we will need to add our Docker Hub and Git credentials to our Jenkins profile.

Select 'Manage Jenkins' -

<img width="199" alt="image" src="https://user-images.githubusercontent.com/83971386/195980344-fe6f3028-c6b8-4cb1-860e-ab23c5c40356.png">

Followed by 'Manage Credentials' - 

<img width="636" alt="image" src="https://user-images.githubusercontent.com/83971386/195980368-bb7bb47c-8cd3-4206-a55e-cd642a133372.png">

Select the 'Global' hyperlink -

<img width="460" alt="image" src="https://user-images.githubusercontent.com/83971386/195980385-58b72a3f-ef3a-41cc-b18d-4b3786f5d5ce.png">

And then click on 'Add Credentials', from here you can populate the following screen with your Docker Hub login credentials and save -

<img width="1213" alt="image" src="https://user-images.githubusercontent.com/83971386/195980417-df538493-b935-4331-9533-cdac898a1be7.png">

Example:
<img width="1218" alt="image" src="https://user-images.githubusercontent.com/83971386/195980445-ae882dca-9f39-4c1f-8149-87f4194be0fb.png">

## Create a Jenkins pipeline
Within the Jenkins Dashboard select the 'New Item' option on the left-hand side, followed by 'Create a Job' -

<img width="223" alt="1 - New Item" src="https://user-images.githubusercontent.com/83971386/197384409-4d65faf6-31fb-4bfe-bb75-00ed80b97454.png">

You will then be presented with multiple items which can be created. We will need to enter an item name, followed by the Pipeline selection -

<img width="1147" alt="2 - pipeline" src="https://user-images.githubusercontent.com/83971386/197384404-194b3c1d-7942-4451-b797-1b0462e678f7.png">

Scroll down to the 'Pipeline' section and select the following Pipeline definition and copy and paste the Jenkinsfile contents within the Script field -

    pipeline {
     agent any

     environment {
      DOCKER_HUB_REPO_WORDPRESS = "bjwrd/wordpress"
      DOCKER_HUB_REPO_MYSQL = "bjwrd/mysql"
      CONTAINER_NAME_WORDPRESS = "wordpress"
      CONTAINER_NAME_MYSQL = "mysql"
     }
  
     stages {
      stage('Checkout') {
           steps {
               checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url:   'https://github.com/BJWRD/cicd-docker-wordpress-pipeline']]])
            }
      }

      stage('Test Container') {
         steps {
           script {
            echo 'Testing Container...'
            withDockerRegistry([ credentialsId: "dockerhublogin", url: "" ]) {
            sh 'docker pull $DOCKER_HUB_REPO_WORDPRESS:latest'
            sh 'docker pull $DOCKER_HUB_REPO_MYSQL:latest'
            sh 'docker run -d --name $CONTAINER_NAME_WORDPRESS $DOCKER_HUB_REPO_WORDPRESS'
            sh 'docker run -d --name $CONTAINER_NAME_MYSQL $DOCKER_HUB_REPO_MYSQL'
            sh 'docker stop $CONTAINER_NAME_WORDPRESS || true'
            sh 'docker stop $CONTAINER_NAME_MYSQL || true'
            sh 'docker rm $CONTAINER_NAME_WORDPRESS || true'
            sh 'docker rm $CONTAINER_NAME_MYSQL || true'
            }
          }
        }
    }

      stage('Scan Image') {
        steps {
            echo 'Scanning Image...'
            sh 'trivy image $DOCKER_HUB_REPO_WORDPRESS:latest --severity MEDIUM,HIGH,CRITICAL > wordpress_vulnerability_output'
            sh 'trivy image $DOCKER_HUB_REPO_MYSQL:latest --severity MEDIUM,HIGH,CRITICAL > mysql_vulnerability_output'
        }
      }

      stage('Push') {
        steps {
          script {
            echo 'Pushing Image...'
            withDockerRegistry([ credentialsId: "dockerhublogin", url: "" ]) {
            sh 'docker push $DOCKER_HUB_REPO_WORDPRESS:latest'
            sh 'docker push $DOCKER_HUB_REPO_MYSQL:latest'
          }
        }
      }
    }


      stage('Deploy') {
        steps {
          script {
            echo 'Testing Image...'
            withDockerRegistry([ credentialsId: "dockerhublogin", url: "" ]) {
            sh 'docker pull $DOCKER_HUB_REPO_WORDPRESS:latest'
            sh 'docker run -d bjwrd/wordpress'
            sh 'docker pull $DOCKER_HUB_REPO_MYSQL:latest'
            sh 'docker run -d bjwrd/mysql' #include the SQL DB root password
          }
        }
      }
    }

<img width="767" alt="image" src="https://user-images.githubusercontent.com/83971386/201526272-c06bcba9-7f06-49fb-a6ea-71e044e79b53.png">

Click 'Save' with the 'Groovy Sandbox' tickbox selected.

NOTE: if your Jenkinsfile exists within your GitHub repo, you can also select the following SCM definition which saves you from copying and pasting the contents within the 'Pipeline Script' field -

<img width="951" alt="image" src="https://user-images.githubusercontent.com/83971386/201526254-74b3ee0c-9e12-495b-a724-f32cec320c64.png">

## Deploy Wordpress using Jenkins Pipeline
Now we have a created Pipeline, we can finally select 'Build Now' to set the Pipeline build process in motion -

<img width="693" alt="image" src="https://user-images.githubusercontent.com/83971386/201526225-e94f960c-de7d-4365-ae8d-eaadbfef7b44.png">

<img width="817" alt="image" src="https://user-images.githubusercontent.com/83971386/201526196-8abc613b-baeb-4dfd-bf87-f4c7e0dc87bc.png">

The Pipeline has successfully gone through the test, scan, push and deployment phases and the Wordpress web application should now be accessible -

      curl http://<VM IP Address>:80
      
OR search via your web browser -

<img width="412" alt="image" src="https://user-images.githubusercontent.com/83971386/201526642-3e4658ca-e8c5-4fea-a514-88722a480bc3.png">


Note: Depending on your environment setup you may need to stop the Jenkins Container for the Wordpress Application to be accessible.

## List of tools/services used
* [Trivy](https://aquasecurity.github.io/trivy/v0.34/getting-started/installation/)
* [Jenkins](https://www.jenkins.io/)
* [Docker](https://www.docker.com/)
* [Dockerfile](https://docs.docker.com/engine/reference/builder/)
* [Docker Hub](https://hub.docker.com/)
* [Wordpress](https://wordpress.org/)
* [MySQL](https://www.mysql.com/)
* [Draw.io](https://www.draw.io/index.html)
