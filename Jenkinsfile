#!*groovy*

pipeline {
    agent {
        ecs {
            inheritFrom 'ecs-fargate-agent-nihil-jenkins'
        }
    }

    stages {
        stage('init') {
            steps {
                echo 'hello world'
            }
        }
    }
}