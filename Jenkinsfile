pipeline {
    agent { label "master" }
    stages {
        stage("Run app on Docker"){
            agent{
                docker{
                    image 'nginx:latest'
                }
            }
        steps{
                echo 'Hi! You are here to Reinvent Yourself'
                sh 'echo Integrating Jenkins Pipeline with GitHub Webhook using Jenkinsfile'  
        }
    }
}
}