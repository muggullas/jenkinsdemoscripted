node {
    // Define environment variables
    def DOCKER_IMAGE = "muggulla6/jenkinstestdemo"
    def DOCKER_CREDENTIALS_ID = "dockerhub-credentials"

    try {
        stage('Checkout') {
            checkout([$class: 'GitSCM', 
                branches: [[name: '*/main']], 
                userRemoteConfigs: [[url: 'https://github.com/muggullas/jenkinstestdemo.git']]
            ])
        }

        stage('Install Dependencies') {
            sh '''
                python3 -m venv venv
                . venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt
            '''
        }

        stage('Run Tests') {
            sh '''
                . venv/bin/activate && pytest tests/ --maxfail=1 --disable-warnings -q
            '''
        }

        stage('Build Docker Image') {
            sh "docker build -t ${DOCKER_IMAGE}:latest ."
        }

        stage('Push Docker Image') {
            withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, 
                                              usernameVariable: 'DOCKER_USER', 
                                              passwordVariable: 'DOCKER_PASS')]) {
                sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Deploy') {
            withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, 
                                              usernameVariable: 'DOCKER_USER', 
                                              passwordVariable: 'DOCKER_PASS')]) {
                sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker pull ${DOCKER_IMAGE}:latest
                    docker stop jenkinstestdemo || true
                    docker rm jenkinstestdemo || true
                    docker run -d --name jenkinstestdemo -p 8081:8080 ${DOCKER_IMAGE}:latest
                """
            }
        }

        echo "✅ Pipeline completed successfully!"
    } catch (err) {
        echo "❌ Pipeline failed: ${err}"
        currentBuild.result = "FAILURE"
        throw err
    }
}
