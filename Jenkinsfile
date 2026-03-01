pipeline {
    agent any

    tools {
        jdk 'jdk11'
        maven 'maven3.6.3'
    }

    parameters {
        string(name: 'ImageTag', defaultValue: "${BUILD_NUMBER}", description: 'Docker Image Tag')
        string(name: 'EmailRecipients', defaultValue: '', description: 'Comma-separated list of email recipients for build notifications')
    }

    environment {
        SONAR_HOME = tool 'sonar-scanner'
        DOCKER_CREDS = credentials('dockerhub-cred')
        DOCKER_USER = "${DOCKER_CREDS_USR}"
        APP_IMAGE = "${DOCKER_USER}/todo-springboot"
        GIT_BRANCH = "main"
    }

    stages {

        stage("Clean Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Checkout") {
            steps {
                git branch: "${GIT_BRANCH}",
                    url: "https://github.com/Madhan152004/todo-app-springboot-mysql.git",
                    credentialsId: "github-cred" // it is the id of the credential we created in Jenkins for GitHub access
            } 
        }

        stage("Build & Test") {
            steps {
                sh "mvn clean verify"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv("sonar-server") {
                    sh """
                    ${SONAR_HOME}/bin/sonar-scanner \
                    -Dsonar.projectKey=todo-springboot \
                    -Dsonar.projectName=todo-springboot \
                    -Dsonar.sources=src/main/java \
                    -Dsonar.java.binaries=target/classes \
                    -Dsonar.exclusions=**/test/**,**/target/**,**/pom.xml,**/Jenkinsfile,**/k8s/**
                    """
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage("OWASP Dependency Check") {
            steps {
                dependencyCheck additionalArguments: '''
                    --scan . \
                    --failOnCVSS 7 \
                    --format XML
                ''',
                odcInstallation: 'dependency-check'

                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage("Build JAR") {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage("Docker Build") {
            steps {
                sh "docker build -t ${APP_IMAGE}:${params.ImageTag} ."
            }
        }

        stage("Trivy Image Scan") {
            steps {
                sh """
                trivy image \
                --severity HIGH,CRITICAL \
                --exit-code 1 \
                ${APP_IMAGE}:${params.ImageTag}
                """
            }
        }

        stage("Push Docker Image") {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-cred', url: '']) {
                    sh "docker push ${APP_IMAGE}:${params.ImageTag}"
                }
            }
        }

         stage("Update K8s Manifest (GitOps)") {
            steps {
                sh """
                yq -i '.spec.template.spec.containers[0].image = "${APP_IMAGE}:${params.ImageTag}"' \
                k8s/spring/deployment.yml
                """

                withCredentials([usernamePassword(
                    credentialsId: 'github-cred',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_TOKEN'
                )]) {

                    sh """
                    git config user.email "jenkins@ci.com"
                    git config user.name "jenkins"

                    git add k8s/spring/deployment.yml
                    git commit -m "Updated image to ${params.ImageTag}"

                    git push https://${GIT_USER}:${GIT_TOKEN}@github.com/Madhan152004/todo-app-springboot-mysql.git ${GIT_BRANCH}
                    """
                }
            }
        }
    }

    post {

        success {
            emailext(
                subject: "SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}",
                to: "${params.EmailRecipients}",
                body: """
                <h2 style="color:green;">Build SUCCESS</h2>
                <p>Project: ${JOB_NAME}</p>
                <p>Build Number: ${BUILD_NUMBER}</p>
                <p>Duration: ${currentBuild.durationString}</p>
                <p><a href="${BUILD_URL}">View Console Output</a></p>
                """
            )
        }

        failure {
            emailext(
                subject: "FAILED: ${JOB_NAME} #${BUILD_NUMBER}",
                to: "${params.EmailRecipients}",
                body: """
                <h2 style="color:red;">Build FAILED</h2>
                <p>Project: ${JOB_NAME}</p>
                <p>Build Number: ${BUILD_NUMBER}</p>
                <p><a href="${BUILD_URL}">Check Logs</a></p>
                """
            )
        }

        always {
            cleanWs()
        }
    }
}