pipeline{
    agent{
        label "Jenkins_agent"
    }
    tools{
        jdk 'java17'
        maven 'Maven3'
    }
    stages{
        stage('Cleanup Workspace'){
            steps{
                cleanWs()
            }
        }

        stage('Check our from SCM'){
            steps{
                git branch: 'main', credentialsId: '752e10b2-9627-4e75-b976-2b4b90bc8d4e', url: 'https://github.com/Zzz-HEFANG/complete-prodcution-e2e-pipeline'
            }
        }

        stage('Build Application'){
            steps{
                sh "mvn clean package"
            }
        }

        stage('Test Application'){
            steps{
                sh "mvn test"
            }
        }

        stage('SonarQube Analysis'){
            steps{
                withSonarQubeEnv(installationName: 'SonarQube') {
                    sh """
                        mvn clean verify sonar:sonar \
                        -Dsonar.projectKey=my-project \
                        -Dsonar.projectName=my-project \
                        -Dsonar.host.url=http://sonarqube:9000 \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                    //asd
                }
            }
        }
    }

}