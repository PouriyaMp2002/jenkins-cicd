pipeline {
    agent any
    tools {
        maven "maven" //Maven variable in Jenkins
        jdk "JDK17" // Same
    }
    
    environment {
        // Repo names in Nexus (provide all repositories that you want to create)
        SNAP_REPO = 'vprofile-hosted-snap'
		RELEASE_REPO = 'vprofile-release-hosted'
		CENTRAL_REPO = 'vprofile-proxy'
        NEXUS_GRP_REPO = 'vprofile-group'

        NEXUS_CRED = 'nexus' // Credential Nexus variable in Jenkins 
		NEXUSURL = '172.31.36.145:8081' // PrivateIP with its port
        NEXUS_LOGIN = 'nexuslogin'
        NEXUS_VERSION = 'nexus3'
        
        SONARQUBE_SERVER = 'sonarqube' //SonarQube server name in Jenkins

        // URI and its link to push it to ECR
        registryCredentials = 'ecr:us-east-1:aws-creds'
        appRegistry = '390402543916.dkr.ecr.us-east-1.amazonaws.com/vproappimg'
        vprofileRegistry = 'https://390402543916.dkr.ecr.us-east-1.amazonaws.com'

        // Cluster and Service name in ECS 
        cluster = 'vprofile'
        service = 'vprofile-service-5tivlr0n'
    }

    stages {
        stage('Build'){
            steps {
                sh 'mvn clean compile -DskipTests'
            }
        }

        stage('Unit Test'){
            steps{
                sh 'mvn test'
            }
        }

        stage('Integration Test'){
            steps{
                sh 'mvn verify -DskipUnitTests'
            }
        }

        stage('Code Analysis'){
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage('Code analysis with SonarQube'){
            steps{
                script{
                    def scannerHome = tool 'sonarqube'
                    def jdk11Home = tool 'JDK11' //SonarQube needs older java in order to execute, so that's why we use java 11

                    withSonarQubeEnv("${SONARQUBE_SERVER}"){
                        sh """
                            export JAVA_HOME='${jdk11Home}'
                            export PATH="\$JAVA_HOME/bin:\$PATH"

                            java -version
                            mvn -version
                            ls -ld target target/classes
                            ${scannerHome}/bin/sonar-scanner \
                              -Dsonar.projectKey=vprofile \
                              -Dsonar.projectName=vprofile-repo \
                              -Dsonar.projectVersion=1.0 \
                              -Dsonar.sources=src/main/java \
                              -Dsonar.java.binaries=target/classes \
                              -Dsonar.junit.reportPaths=target/surefire-reports \
                              -Dsonar.jacoco.reportPaths=target/jacoco.exec \
                              -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
                        """
                    }
                }
            }
        }

        stage('Push to Nexus'){
            steps{
                script{
                    nexusArtifactUploader(
                        nexusVersion: "${NEXUS_VERSION}",
                        protocol: 'http',
                        repository: "${RELEASE_REPO}",
                        nexusUrl: "${NEXUSURL}",
                        groupId: 'Build Stage',
                        version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                        credentialsId: "${NEXUS_CRED}",
                        artifacts:[
                            [artifactId: 'vproapp',
                            classifier: '',
                            file: 'target/devops-demo-1.0.jar', // filename with its directory after building
                            type: 'jar'
                            ]
                        ]
                    )
                }
            }
        }
        
        // you can get these commands from AWS
        stage('ECR Login'){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]){
                    sh '''
                        aws ecr get-login-password --region us-east-1 \
                        | docker login --username AWS --password-stdin 390402543916.dkr.ecr.us-east-1.amazonaws.com
                    '''
                } 
            }
        }

        stage ('Docker build'){
            steps{
                sh '''
                    docker build -t ${appRegistry}:${BUILD_ID} ./Docker-files/app/multistage/
                    docker tag ${appRegistry}:${BUILD_ID} ${appRegistry}:latest
                '''
            } 
        }

        stage('Docker push'){
            steps{
                sh '''                
                    docker push ${appRegistry}:${BUILD_ID}
                    docker push ${appRegistry}:latest
                '''
            } 
        }

        stage('Push to ECS'){
            steps{
                withAWS(credentials: 'aws-creds', region: 'us-east-1'){
                    sh "aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment"
                }
            }
        }
    }
}