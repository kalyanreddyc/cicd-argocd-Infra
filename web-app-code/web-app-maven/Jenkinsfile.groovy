pipeline {
    agent any
    stages {
        stage('Build and Test') {
            steps {
                //build and create a package
                sh 'mvn clean package'
            }
        }
        stage('Code Coverage with Sonarqube') {
             steps {
                 // sonar 
                 sh 'mvn sonar:sonar'
                 }
        }
        pipeline {
    agent any
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    def dockerImage = docker.build('my-docker-image:latest', '.')
                }
            }
        }
        
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                        credentialsId: 'kalyancisco'
                    ]]) {
                        def ecrRepo = 'my-ecr-repo'
                        def region = 'us-west-2'
                        
                        docker.withRegistry("https://${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}@${region}.dkr.ecr.${region}.amazonaws.com") {
                            dockerImage.push("${ecrRepo}:latest")
                        }
                    }
                }
            }
        }
    }
}






        stage('Push Docker Image to ECR') {
            steps {
                script {
                    def awsRegion = 'us-east-1'
                    def ecrRepository = 'javaapp'
                    def dockerImageTag = '1.0'
                    def awsAccountId = '969921119504'
            
                    def ecrCredentials = amazonECR(credentialsId: 'kalyancisco', region: awsRegion)
                    def dockerImage = docker.build("${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/${ecrRepository}:${dockerImageTag}")
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'kalyancisco', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        docker.withRegistry("https://${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com", 'ecr') {
                            dockerImage.push()
                        }

                    }
                }
            }
        }

    }

}