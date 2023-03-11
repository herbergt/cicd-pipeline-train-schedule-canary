pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "herbergt/train-schedule"
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh 'export JAVA_HOME=`/usr/libexec/java_home -v 11.0.17` && ./gradlew build --no-daemon'
                archiveArtifacts artifacts: 'dist/trainSchedule.zip'
            }
        }
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    app = docker.build(DOCKER_IMAGE_NAME)
                    app.inside {
                        sh 'echo Hello, World!'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
        stage('CanaryDeploy') {
            when {
                branch 'master'
            }
            environment {
                CANARY_REPLICAS = 1
            }
            steps {
                 withKubeConfig([credentialsId: 'kubeconfig']) {
                     sh 'kubectl apply -f train-schedule-kube-canary.yml'
                 }
            }
        }
        stage('DeployToProduction') {
            when {
                branch 'master'
            }
            environment {
                CANARY_REPLICAS = 0
            }
            steps {
                input 'Deploy to Production?'
                milestone(1)
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh 'kubectl apply -f train-schedule-kube-canary.yml'
                }
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh 'kubectl apply -f train-schedule-kube.yml'
                }
            }
        }
    }
}