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
                        # 创建临时目录并记录
                        TEMP_DIR=\$(mktemp -d)
                        echo "创建临时工作目录: \$TEMP_DIR"
                        cd \$TEMP_DIR
                        
                        # 克隆配置仓库
                        echo "正在克隆配置仓库..."
                        git clone ${GIT_CONFIG_REPO} .
                        
                        # 获取当前配置中的镜像标签
                        CURRENT_TAG=\$(grep -o 'image: oliver0313/e2e:.*' overlays/dev/deployment-patch.yaml | cut -d':' -f3)
                        echo "当前配置中的镜像标签: \$CURRENT_TAG"
                        echo "准备更新的新标签: ${IMAGE_TAG}"
                        
                        # 比较标签版本并决定是否需要更新
                        if [ "\$CURRENT_TAG" != "${IMAGE_TAG}" ]; then
                            echo "检测到新版本，开始更新配置..."
                            
                            # 更新镜像标签
                            sed -i 's|image: oliver0313/e2e:.*|image: oliver0313/e2e:${IMAGE_TAG}|' overlays/dev/deployment-patch.yaml
                            
                            # 配置 Git 身份
                            git config user.email "zezhengzhao@gmail.com"
                            git config user.name "Oliver"
                            
                            # 提交更改
                            git add .
                            git commit -m "将镜像标签从 \$CURRENT_TAG 更新到 ${IMAGE_TAG} [skip ci]"
                            git push origin main
                            
                            echo "配置更新成功，新镜像标签: ${IMAGE_TAG}"
                        else
                            echo "当前配置已经是最新版本（${IMAGE_TAG}），无需更新"
                        fi
                        
                        # 清理临时目录
                        cd ..
                        rm -rf \$TEMP_DIR
                        echo "清理完成，临时目录已删除"
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