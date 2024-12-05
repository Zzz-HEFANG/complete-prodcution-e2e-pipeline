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
        DOCKER_USERNAME="oliver0313"
        IMAGE_NAME = "${DOCKER_USERNAME}/${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        GIT_CONFIG_REPO = "https://github.com/Zzz-HEFANG/e2e-k8s-configs.git"
        GIT_CREDS = credentials('752e10b2-9627-4e75-b976-2b4b90bc8d4e')
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

        // stage('SonarQube Analysis') {
        //     environment {
        //         SONAR_TOKEN = credentials('sonar-token')
        //     }
        //     steps {
        //         withSonarQubeEnv('SonarQube') {
        //             sh "mvn clean verify sonar:sonar"
        //         }
        //     }
        // }

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
        stage("Update Deployment Configuration") {
            steps {
                script {
                    sh """
                        # 克隆配置仓库到临时目录
                        TEMP_DIR=\$(mktemp -d)
                        cd \$TEMP_DIR
                        git clone ${GIT_CONFIG_REPO} .
                        
                        # 更新镜像标签并检查是否有变化
                        sed -i 's|image: oliver0313/e2e:.*|image: oliver0313/e2e:${IMAGE_TAG}|' base/deployment.yaml
                        
                        # 如果有变化，提交并推送
                        if git status --porcelain | grep -q '^'; then
                            git config user.email "zezhengzhao@gmail.com"
                            git config user.name "Oliver"
                            git add .
                            git commit -m "Update image tag to ${IMAGE_TAG} [skip ci]"
                            git push origin main
                        fi
                        
                        # 清理
                        cd ..
                        rm -rf \$TEMP_DIR
                    """
                }
            }
}
    
    }

    post{
        always{
            cleanWs()
        }
    }
}