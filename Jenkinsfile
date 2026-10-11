pipeline{
    agent any
    options{
        timestamps()
        
    }

    triggers{
        githubPush()
    }

    stages{
        stage("Clone Repository"){
            steps{
                git branch: 'main', url: 'https://github.com/Madhan152004/todo-app-springboot-mysql.git'
            }

        }
        stage("build the docker compose file"){
            steps{
                sh 'docker compose build'
            }
        }

        stage("Run the docker compose file"){
            steps{
                sh 'docker compose up -d'
            }
        }

    }
}
