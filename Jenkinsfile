pipeline {
    agent {
        label "Jenkins_agent"
    }
    
    tools {
        jdk 'java17'
        maven 'Maven3'
    }
    
    environment {
        APP_NAME = "e2e"
        RELEASE = "1.0.0"
        DOCKER_CREDS = credentials('docker-credentials')
        IMAGE_NAME = "${DOCKER_CREDS_USR}/${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    }
    
    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Check our from SCM') {
            steps {
                git branch: 'main', credentialsId: '752e10b2-9627-4e75-b976-2b4b90bc8d4e', url: 'https://github.com/Zzz-HEFANG/complete-prodcution-e2e-pipeline'
            }
        }

        stage('Build Application') {
            steps {
                sh "mvn clean package"
            }
        }

        stage('Test Application') {
            steps {
                sh "mvn test"
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-token')
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "mvn clean verify sonar:sonar"
                }
            }
        }

        stage("Build and Push Docker Image") {
            steps {
                script {
                    echo "IMAGE_NAME value: ${IMAGE_NAME}"
                    echo "IMAGE_TAG value: ${IMAGE_TAG}"


                    docker.withRegistry('https://index.docker.io/v1/', 'docker-credentials') {
                    def fullImageName = "${IMAGE_NAME}:${IMAGE_TAG}"
                    echo "Full image name: ${fullImageName}"
                
                    def docker_image = docker.build(fullImageName)
                    docker_image.push()
                    docker_image.push('latest')
                    
                }
                }
            }
        }
    }
}