pipeline {
    agent { label "master" }
    stages {
        stage("Run app on Docker"){
            agent{
                docker{
                    image 'nginx:1.20.1'
                }
            }
            steps {
                echo 'Keep going to Reinvent Yourself'
                sh 'echo Integrating Jenkins Pipeline with GitHub Webhook using Jenkinsfile'
                }   
            }
        }
    }
