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
               checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/BJWRD/cicd-docker-wordpress-pipeline']]])
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
          sh 'docker run -d bjwrd/mysql'
          }
        }
      }
    }
  }
}