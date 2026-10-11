
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Madhan152004/todo-app-springboot-mysql.git'
            }
        }

        stage('Build Spring Boot JAR') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([
                    string(credentialsId: 'mysql-db',
                           variable: 'MYSQL_DB'),
                    string(credentialsId: 'mysql-user',
                           variable: 'MYSQL_USER'),
                    string(credentialsId: 'mysql-password',
                           variable: 'MYSQL_PASSWORD'),
                    string(credentialsId: 'mysql-root-password',
                           variable: 'MYSQL_ROOT_PASSWORD')
                ]) {
                    sh 'docker compose config -q'
                    sh 'docker compose build'
                }
            }
        }

        stage('Run Docker Compose') {
            steps {
                withCredentials([
                    string(credentialsId: 'mysql-db',
                           variable: 'MYSQL_DB'),
                    string(credentialsId: 'mysql-user',
                           variable: 'MYSQL_USER'),
                    string(credentialsId: 'mysql-password',
                           variable: 'MYSQL_PASSWORD'),
                    string(credentialsId: 'mysql-root-password',
                           variable: 'MYSQL_ROOT_PASSWORD')
                ]) {
                    sh 'docker compose up -d'
                    sh 'docker compose ps'
                }
            }
        }
    }

    post {
        success {
            echo 'Application deployment completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check Console Output for the failing stage.'
        }
    }
}
