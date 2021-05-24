#!*groovy*

pipeline {
    agent {
        ecs {
            inheritFrom 'ecs-fargate-agent'
            label 'ecs-fargate-agent-nihil-jenkins'
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