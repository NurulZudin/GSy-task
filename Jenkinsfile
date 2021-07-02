pipeline {
    agent { label "master" }
    environment {
        ECR_REGISTRY = "073786940416.dkr.ecr.us-east-1.amazonaws.com"
        APP_REPO_NAME= "task-dr-gsy"
        PATH="/usr/local/bin/:${env.PATH}"
    }
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:latest" .'
                sh 'docker rmi $(docker images -f "dangling=true" -q) --force'
                sh 'docker image ls'
            }
        }
        stage('Push Image to ECR Repo') {
            steps {
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker ps -q --filter "name=$APP_REPO_NAME" | grep -q . && docker stop $APP_REPO_NAME && docker rm -fv $APP_REPO_NAME'
                sh 'docker run --name $APP_REPO_NAME -dp 80:80 "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }
    }
    post {
        success {
            echo 'success!'
        }
    }
}