pipeline{
    agent{
        label "jenkins-agent"
    }
    tools{
        jdk 'Java17'
        maven 'Maven3'
    }
    stages{
        stage{"Cleanup Workspace"}{
            steps{
                cleanWs()
            }
        }
    }

    stages{
        stage{"Check our from SCM"}{
            steps{
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/Zzz-HEFANG/complete-prodcution-e2e-pipeline'
            }
        }
    }

}