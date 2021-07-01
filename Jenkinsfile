pipeline {
    agent { label "master" }
    stages {
        stage("Run app on Docker"){
            agent{
                docker{
                    image 'nginx:1.20.1'
                }
            }
            steps{
                withEnv(["HOME=${env.WORKSPACE}"]) {
                    sh 'yarn install --production'
                    sh 'npm install'
                }   
            }
        }
    }
}