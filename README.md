1.Cloning the repo:
git clone https://github.com/subbasri17/devops-build.git

2.installl docker engine
apt-get install docker.io -y
docker version

3.install docker compose 
Search official document and installed the docker compose plugin manually:
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

apt install docker-compose -y
docker-compose version
-------------------------------------------------------------------------------------------------------------------------------------------------
5.create docker file and docker compose file.
This is react application and need to mention 80
-------------------------------------------------------------------------------------------------------------------------------------------------
	Docker file:

FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY build/ /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]


-------------------------------------------------------------------------------------------------------------------------------------------------

Docker compose file: 

version: '3'

services:
  webapp:
    image: ${IMAGE}
    
    ports:
      - "80:80"
-------------------------------------------------------------------------------------------------------------------------------------------------

6.  docker-compose up -d (background it is running)
docker-compose ps


-------------------------------------------------------------------------------------------------------------------------------------------------

Build bash script:

1. Setting environment
2. env = dev, prod
3  if env = dev 
   docker build -t ecommerce
   docker hub login
   docker push public
   
   if env = prod 
     docker build -t ecommerce
   docker hub login
   docker push private 
   

-------------------------------------------------------------------------------------------------------------------------------------------------
build: 

#!/bin/bash
set -e

BRANCH=${1:-dev}   # default to dev
IMAGE_NAME="webapp"
DOCKER_USER=${DOCKER_USER:-aarushisuba}

DEV_IMAGE="$DOCKER_USER/dev:$BRANCH"
PROD_IMAGE="$DOCKER_USER/prod:$BRANCH"

echo "Building Docker image..."
docker build -t $IMAGE_NAME:latest .

# Check if Docker credentials exist
#if [ -z "$DOCKER_USER" ] || [ -z "$DOCKER_PASS" ]; then
#   echo "Error: DOCKER_USER or DOCKER_PASS is not set!"
#    exit 1
#i

#echo "Logging in to DockerHub..."
#echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

if [ "$BRANCH" == "dev" ]; then
    echo "Tagging image for dev repo..."
    docker tag $IMAGE_NAME:latest $DEV_IMAGE
elif [ "$BRANCH" == "main" ]; then
     echo "Tagging image for prod repo..."
     docker tag $IMAGE_NAME:latest $PROD_IMAGE
else
    echo "Unknown branch '$BRANCH'. Only dev or master allowed."
    exit 1
fi

echo "Build complete."
	
-------------------------------------------------------------------------------------------------------------------------------------------------
deploy
	
#!/bin/bash
set -e

BRANCH=${1:-dev}
TAG=${2:-latest}

DOCKER_USER="aarushisuba"

if [ "$BRANCH" == "dev" ]; then
    IMAGE="$DOCKER_USER/dev:$TAG"
elif [ "$BRANCH" == "main" ]; then
    IMAGE="$DOCKER_USER/prod:$TAG"
else
    echo "Invalid branch. Use dev or main"
    exit 1
fi

echo "Stopping old containers..."
docker-compose down || true

echo "Deploying image: $IMAGE"

export IMAGE=$IMAGE

docker-compose pull
docker-compose up -d

docker-compose ps

echo "Deployment completed successfully!"



http://3.110.76.193:8080/

project
│
├── Dockerfile
├── docker-compose.yml
├── build.sh
├── deploy.sh
└── build/   (React build output)


-------------------------------------------------------------------------------------------------------------------------------------------------

We need to pass the parameters like dev and prod and then

Jenkins file:
pipeline {
    agent any

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'dev', description: 'Branch to build and deploy')
    }

    environment {
        DEV_REGISTRY = "aarushisuba/dev"
        PROD_REGISTRY = "aarushisuba/prod"
        IMAGE_NAME = "webapp"
        IMAGE_TAG = "latest"
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/subbasri17/devops-build.git',
                branch: "${params.BRANCH_NAME}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'chmod +x build.sh'
                sh "./build.sh ${params.BRANCH_NAME}"
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"

                    script {
                        if (params.BRANCH_NAME == 'dev') {

                            sh "docker tag webapp:latest $DEV_REGISTRY:$IMAGE_TAG"
                            sh "docker push $DEV_REGISTRY:$IMAGE_TAG"

                        } else if (params.BRANCH_NAME == 'main') {

                            sh "docker tag webapp:latest $PROD_REGISTRY:$IMAGE_TAG"
                            sh "docker push $PROD_REGISTRY:$IMAGE_TAG"

                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
           
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                
                sh 'chmod +x deploy.sh'
                sh "./deploy.sh ${params.BRANCH_NAME}"
            }
        }
    }

    }

    post {
        success {
            echo "✅ Deployment completed successfully for branch ${params.BRANCH_NAME}!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}



-------------------------------------------------------------------------------------------------------------------------------------------------





New branch creation:
git branch dev
git switch dev
my files are alreday in main branch, i am just merging from main to branch.


git fetch origin
git merge origin/main
git push origin dev

-------------------------------------------------------------------------------------------------------------------------------------------------

All files in dev branch, now i am going to merge it into main branch.

First switch into main branch
git fetch origin
I am getting some error:so i just do below commanda
git checkout main
git reset --hard dev
git push origin main --force

-------------------------------------------------------------------------------------------------------------------------------------------------
Monitoring set up:


EC2 -Prometheus agent install, config file - scrap - add application server host/9100 (port) then install grapana. open url with 3000 port. while connecting the test prometesus should open.
EC2 - APP -Node exporter install 

Steps:
1.wget https://github.com/prometheus/prometheus/releases/download/v3.5.1/prometheus-3.5.1.linux-amd64.tar.gz
2.tar -xvzf prometheus-3.5.1.linux-amd64.tar.gz
3.cp prometheus /usr/local/bin
4.cp promtool /usr/local/bin
5.
 ./prometheus --config.file=prometheus.yml &
6.install node exporter in application server 
7.edit config file in promethesus.yaml


		  
  - job_name: "node"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["3.110.76.193:9100"]
       # The label name is added as a label `label_name=<label_value>` to any timeseries scraped from this config.
        labels:
          app: "prometheus"

8. restart promethesus. first kill it and then restart it.
root@ip-172-31-32-130:~/prometheus-3.5.1.linux-amd64# ps -ef | grep prometheus
root        1268       1  0 12:32 ?        00:00:01 ./prometheus --config.file=prometheus.yml
root        1403    1376  0 12:46 pts/2    00:00:00 grep --color=auto prometheus
root@ip-172-31-32-130:~/prometheus-3.5.1.linux-amd64# kill -9 1268
root@ip-172-31-32-130:~/prometheus-3.5.1.linux-amd64# pkill -9 prometheus
root@ip-172-31-32-130:~/prometheus-3.5.1.linux-amd64# ps -ef | grep prometheus
root        1406    1376  0 12:46 pts/2    00:00:00 grep --color=auto prometheus
root@ip-172-31-32-130:~/prometheus-3.5.1.linux-amd64# kill -9 1406
-bash: kill: (1406) - No such process
root@ip-172-31-32-130:~/prometheus-3.5.1.linux-amd64# kill -9 1376
Killed


9. install grafana:
https://grafana.com/grafana/download?platform=linux
wget https://dl.grafana.com/grafana-enterprise/release/12.4.0/grafana-enterprise_12.4.0_22325204712_linux_amd64.tar.gz

10. Need to start graphana in bin .
before that make sure promethesus running.
11. Just run the promethesus run in background.  ./prometheus --config.file=prometheus.yml &
and enter not control c.

12.then connections ->data resources-->save and test with update ip address 
13. Nodeexporter search -copy the id and paste it in import new dashoard under dashboard.

14. Grafana installed and setup the moitoring:

















-------------------------------------------------------------------------------------------------------------------------------------------------

