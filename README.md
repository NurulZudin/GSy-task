 Launching a Jenkins Server Configured ( server-cfn-template.yml )

- Launch a pre-configured from the AMI of (ami-08857fc3e51ff205e) running on Amazon Linux 2, allowing SSH (port 22) and HTTP (ports 80, 8080) connections using the Cloudformation Template.

Dockerfile are ready.

 Run the `nginx` container at the detached mod, name the container as `nginx-default`, and open <public-ip> on browser and show the nginx default page.

```bash
docker buil
docker run -d --name nginx-default -p 80:80  nginx
```
check on browser to see nginx page.

```text
http://<public-ip>:80
```

- Get the initial administrative password for Jenkins page.

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
- Open your browser, get your ec2 instance Public IPv4 DNS and paste it at address bar with 8080. 
"http://[ec2-public-dns-name]:8080"

 Jenkins Server is configured with admin user `admin` and password `Admin12345`.

- Open your Jenkins dashboard and navigate to `Manage Jenkins` >> `Manage Plugins` >> `Available` tab

- Search and select `GitHub Integration, Pipeline:GitHub, Docker, Docker Pipeline` plugins, then click to `Install without restart`. Note: No need to install the other `Git plugin` which is already installed can be seen under `Installed` tab.


Prepare the Image Repository on ECR and Project Repository on GitHub with Webhook

Prepare the Image Repository on ECR

- Create a docker image repository `/task-dr-gsy` on AWS ECR from Management Console.

- Create a public project repository `GSy-task` on your own GitHub account.


Create Token

- Add token to the github. So, go to your github Account Profile  on right of the top >>>> Settings>>>>Developer Settings>>>>>>>>Personal access tokens >>>>>> Generate new token

- Go to the >>>>>> GSy-task/.git and open Git config file. (USe your own token and repo)

```bash
cd .git
vi config

Example, 
Add "token" after "//" in the "url" part . And also paste "@" at the and of the token.
  "url = https://<yourtoken@>github.com/NurulZudin/GSy-task.git

```

Create Webhook 

- Go to the `GSy-task` repository page and click on `Settings`.

- Click on the `Webhooks` on the left hand menu, and then click on `Add webhook`.

- Copy the Jenkins URL from the AWS Management Console, paste it into `Payload URL` field, add `/github-webhook/` at the end of URL, and click on `Add webhook`.

```text
http://<ipadress>.compute-1.amazonaws.com:8080/github-webhook/
```

Creating Jenkins Pipeline for the Project with GitHub Webhook

Github process

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `todo-app-pipeline` then select `Pipeline` and click `OK`.

- Enter `To Do App pipeline configured with Jenkinsfile and GitHub Webhook` in the description field.

- Put a checkmark on `GitHub Project` under `General` section, enter URL of the project repository.

```text
https://github.com/xxxxxxxx/GSy-task.git
```

- Put a checkmark on `GitHub hook trigger for GITScm polling` under `Build Triggers` section.

- Go to the `Pipeline` section, and select `Pipeline script from SCM` in the `Definition` field.

- Select `Git` in the `SCM` field.

- Enter URL of the project repository, and let others be default.

```text
https://github.com/xxxxxxxxxxx/GSy-task.git
```

- Click `apply` and `save`. Note that the script `Jenkinsfile` should be placed under root folder of repo.

Jenkins instance Process


- Go to the Jenkins instance (GSy-task/ directory) to create `Jenkinsfile`

```bash
cd GSy-task/
ls
vi Jenkinsfile

Press "i" to edit 
```
- Create a `Jenkinsfile` within the `GSy-task` repo with following pipeline script. 
```groovy
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
```
 Jenkins Build Process

- Go to the Jenkins project page and click `Build Now`.The job has to be executed manually one time in order for the push trigger and the git repo to be registered.

- once we see the code is running, lets build its image. to do this, we should write Dockerfile based and configure the Jenkinsfile and see on ECR we have 

```groovy

pipeline {
    agent { label "master" }
    environment {
        ECR_REGISTRY = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com"
        APP_REPO_NAME= "task-dr-gsy"
        PATH="/usr/local/bin/:${env.PATH}"
    }
    stages {
    stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:latest" .'
                sh 'docker image ls'
            }
        }
        stage('Push Image to ECR Repo') {
            steps {
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }
    }
    post {
        success {
            echo 'success!'
        }
    }
}

```

- Commit and push the local changes to update the remote repo on GitHub.

```bash
git add .
git commit -m 'added Jenkinsfile'
git push
```


Add Deploy stage 


- Change a `Jenkinsfile` within the `GSy-task` repo and add Deploy stage like below. 

- First press "dG" to delete all if u are using terminal.

```groovy
  pipeline {
    agent { label "master" }
    environment {
        ECR_REGISTRY = "<aws_account_id>.ecr.us-east-1.amazonaws.com"
        APP_REPO_NAME= "task-dr-gsy""
    }
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:latest" .'
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
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker pull "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
                sh 'docker run --name todo -dp 80:3000"$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }

    }
    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
    }
}
```

- Press "ESC" and ":wq " to save.

- Commit and push the local changes to update the remote repo on GitHub.

- At the end, go to Jenkins Server instance with SSH. Add `sh 'docker ps -q --filter "name=todo" | grep -q . && docker stop todo && docker rm -fv todo'"` command  before "sh `docker run.......`" command  to the `Deploy` Stage of the the Jenkinsfile to clear.

```groovy
 
                sh 'docker ps -q --filter "name=todo" | grep -q . && docker stop todo && docker rm -fv todo'
 
``
or 

- Delete the container 

```bash
docker container stop todo
docker container rm todo
```

Cleaning up the Image Repository on AWS ECR

- If necessary, authenticate the Docker CLI to your default `ECR registry`.

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com
```

- Delete Docker image from `task-dr-gsy` ECR repository from AWS CLI.

```bash
aws ecr batch-delete-image \
      --repository-name task-dr-gsy \
      --image-ids imageTag=latest \
      --region us-east-1
```

- Delete the ECR repository `task-dr-gsy` from AWS CLI.

```bash
aws ecr delete-repository \
      --repository-name task-dr-gsy \
      --force \
      --region us-east-1
```



<!-- Whole Jenkinsfile -->
<!-- pipeline {
    agent { label "master" }
    environment {
        ECR_REGISTRY = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com"
        APP_REPO_NAME= "clarusway/to-do-app"
        PATH="/usr/local/bin/:${env.PATH}"
    }
    stages {
        stage("Run app on Docker"){
            agent{
                docker{
                    image 'nginx:latest'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:latest" .'
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
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker pull "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
                sh 'docker ps -q --filter "name=todo" | grep -q . && docker stop todo && docker rm -fv todo'
                sh 'docker run --name todo -dp 80:3000 "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }
    }
    post {
        success {
            echo 'I did it. I'm are gonna be a good Devops'
        }
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
    }
} -->
