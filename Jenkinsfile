pipeline {
    agent { label 'ahmedhakem' }
 
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-credentials-ahmed')
        DOCKER_HUB_REPO = 'ahmed10hakem/spring-mvnc'
        IMAGE_NAME = 'ahmed10hakem/spring-mvnc'
        TAG = 'latest'  // You can replace this with a version or commit hash
            }

     stages {
        stage('Checkout') {
            steps {
                // Checkout code from your source repository
                git branch: 'main', url: 'https://github.com/ahmedabdelhakim13/spring-mvc.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build the Docker image
                script {
                       sh "docker build -t ${IMAGE_NAME}:${TAG} ."
                }
            }
        }

        stage('Push Docker Image') {
	steps {
                script {
                    sh """
                    echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin
                    docker push ${DOCKER_HUB_REPO}:${TAG}
                    """
                }
            }
        }
        stage('Deploy') {
            steps {
     
                     sh """
                                docker run -d -p 8085:8080 --name spring-mvnc ahmed10hakem/spring-mvnc:latest
                            
                        """
            }
        }
    }

    post {
        always {
            // Clean up after the build
            cleanWs()
        }
    }
}      
