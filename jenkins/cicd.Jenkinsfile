pipeline {
    agent {
        label 'master'
    }
    triggers {
        githubPush()
    }
    environment {
        DOCKER_HUB_REGISTRY = "clovisbernard"
        DOCKERHUB_CREDS = credentials('Dockerhub-credentials') 
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '7'))
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
        timeout (time: 5, unit: 'MINUTES')
        timestamps()
    }
    parameters {
        string(name: 'SONAR_VERSION', defaultValue: '5.0.1.3006', description: '')
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: '')
        string (name: 'UI_IMAGE_TAG', defaultValue: 'latest', description: '')
        string (name: 'AUTH_IMAGE_TAG', defaultValue: 'latest', description: '')
        string (name: 'WEATHER_IMAGE_TAG', defaultValue: 'latest', description: '')
        string (name: 'REDIS_IMAGE_TAG', defaultValue: 'latest', description: '')
        string (name: 'DB_IMAGE_TAG', defaultValue: 'latest', description: '')
    }
    stages {
        // stage('Sanity Check') {
        //     steps {
        //         script{
        //            sanity_check() 
        //         }
        //     }
        // }
        stage ('Checkout') {
            steps {
                dir("${WORKSPACE}/application") {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${params.BRANCH_NAME}"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [[$class: 'LocalBranch']],
                        submoduleCfg: [],
                        userRemoteConfigs: [[
                        url: 'https://github.com/clovisbernard/jenkins-classes.git',
                        credentialsId: 'github-auth'
                        ]]
                    ])
                }
            }
        }
        stage ('Install SonarQube') {
            steps {
                script {
                    sh """
                        sudo apt update -y
                        sudo apt install nodejs npm wget unzip -y              
                        wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${params.SONAR_VERSION}-linux.zip
                        unzip -o sonar-scanner-cli-${params.SONAR_VERSION}-linux.zip
                        sudo mv sonar-scanner-${params.SONAR_VERSION}-linux sonar-scanner
                        sudo rm -rf  /var/opt/sonar-scanner || true
                        sudo mv sonar-scanner /var/opt/
                        sudo rm -rf /usr/local/bin/sonar-scanner || true
                        sudo ln -s /var/opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/ || true
                        sonar-scanner -v
                    """
                }
            }
        }  
        stage('Remove Existing sonar-project.properties') {
                    steps {
                        dir("${WORKSPACE}/application/weather-app/code") {
                            script {
                                // Check if sonar-project.properties exists and remove it if found
                                if (fileExists('sonar-project.properties')) {
                                    sh 'rm sonar-project.properties'
                                }
                            }
                        }
                    }
                }
        stage('Create sonar-project.properties') {
            steps {
                dir("${WORKSPACE}/application/weather-app/code") {
                    script {
                        // Define the content of sonar-project.properties
                        def sonarProjectPropertiesContent = """
                            sonar.host.url=https://sonarqube.ektechsoftwaresolution.com/
                            sonar.projectKey=clovis-weatherapp-project
                            sonar.projectName=clovis-weatherapp-project
                            sonar.projectVersion=1.0
                            sonar.sources=.
                            qualitygate.wait=true 
                        """

                        // Create the sonar-project.properties file
                        writeFile file: 'sonar-project.properties', text: sonarProjectPropertiesContent
                    }
                }
            }
        }
        stage('Open sonar-project.properties') {
            steps {
                dir("${WORKSPACE}/application/weather-app/code") {
                    script {
                        // Use 'cat' command to display the content of sonar-project.properties
                        sh 'cat sonar-project.properties'
                    }
                }
            }
        }
        // stage('SonarQube Analysis') {
        //     steps {
        //         dir("${WORKSPACE}/application/weather-app/code") {
        //             script {
        //                 withSonarQubeEnv('SonarScanner') {
        //                     sh "sonar-scanner"
        //                 }
        //             }
        //         }
        //     }
        // }
        stage('Building Auth') {
            steps {
                script {
                    dir("${WORKSPACE}/application/weather-app/code/auth") {
                        sh """
                            sudo docker build -t ${env.DOCKER_HUB_REGISTRY}/auth-a1:${params.AUTH_IMAGE_TAG} .
                            sudo docker tag ${env.DOCKER_HUB_REGISTRY}/auth-a1:${params.AUTH_IMAGE_TAG} ${env.DOCKER_HUB_REGISTRY_DEL}/auth-a1:${params.AUTH_IMAGE_TAG}
                            sudo docker images
                        """
                    }
                }
            }
        }
        stage('Building db') {
            steps {
                script {
                    dir("${WORKSPACE}/application/weather-app/code/db") {
                        sh """
                            sudo docker build -t ${env.DOCKER_HUB_REGISTRY}/db-a1:${params.DB_IMAGE_TAG} .
                            sudo docker tag ${env.DOCKER_HUB_REGISTRY}/db-a1:${params.DB_IMAGE_TAG} ${env.DOCKER_HUB_REGISTRY_DEL}/db-a1:${params.DB_IMAGE_TAG}
                            sudo docker images
                        """
                    }
                }
            }
        }
        stage('Building redis') {
            steps {
                script {
                    dir("${WORKSPACE}/application/weather-app/code/redis") {
                        sh """
                            sudo docker build -t ${env.DOCKER_HUB_REGISTRY}/redis-a1:${params.REDIS_IMAGE_TAG} .
                            sudo docker tag ${env.DOCKER_HUB_REGISTRY}/redis-a1:${params.REDIS_IMAGE_TAG} ${env.DOCKER_HUB_REGISTRY_DEL}/redis-a1:${params.REDIS_IMAGE_TAG}
                            sudo docker images
                        """
                    }
                }
            }
        }
        stage('Building ui') {
            steps {
                script {
                    dir("${WORKSPACE}/application/weather-app/code/ui") {
                        sh """
                            sudo docker build -t ${env.DOCKER_HUB_REGISTRY}/ui-a1:${params.UI_IMAGE_TAG} .
                            sudo docker tag ${env.DOCKER_HUB_REGISTRY}/ui-a1:${params.UI_IMAGE_TAG} ${env.DOCKER_HUB_REGISTRY_DEL}/ui-a1:${params.UI_IMAGE_TAG}
                            sudo docker images
                        """
                    }
                }
            }
        }
        stage('Building weather') {
            steps {
                script {
                    dir("${WORKSPACE}/application/weather-app/code/weather") {
                        sh """
                            sudo docker build -t ${env.DOCKER_HUB_REGISTRY}/weather-a1:${params.WEATHER_IMAGE_TAG} .
                            sudo docker tag ${env.DOCKER_HUB_REGISTRY}/weather-a1:${params.WEATHER_IMAGE_TAG} ${env.DOCKER_HUB_REGISTRY_DEL}/weather-a1:${params.WEATHER_IMAGE_TAG}
                            sudo docker images
                        """
                    }
                }
            }
        }
        stage('Docker Login') {
            steps {
                script {
                sh '''
                     echo "${DOCKERHUB_CREDS_PSW}" | docker login --username "${DOCKERHUB_CREDS_USR}" --password-stdin
                 '''
                }
            }
        }
        stage('Pushing Into DEL Docker Hub') {
            steps {
                script {
                    dir("${WORKSPACE}/application/weather-app/code/weather") {
                        sh """
                            sudo docker push ${env.DOCKER_HUB_REGISTRY}/auth-a1:${params.AUTH_IMAGE_TAG}
                            sudo docker push ${env.DOCKER_HUB_REGISTRY}/db-a1:${params.DB_IMAGE_TAG}
                            sudo docker push ${env.DOCKER_HUB_REGISTRY}/redis-a1:${params.REDIS_IMAGE_TAG}
                            sudo docker push ${env.DOCKER_HUB_REGISTRY}/ui-a1:${params.UI_IMAGE_TAG}
                            sudo docker push ${env.DOCKER_HUB_REGISTRY}/weather-a1:${params.WEATHER_IMAGE_TAG}
                        """
                    }
                }
            }
        }
   } 
   
    post {
        success {
            slackSend color: '#2EB67D',
            channel: 'test-job', 
            message: "*Alpha Project Build Status*" +
            "\n Project Name: Alpha" +
            "\n Job Name: ${env.JOB_NAME}" +
            "\n Build number: ${currentBuild.displayName}" +
            "\n Build Status : *SUCCESS*" +
            "\n Build url : ${env.BUILD_URL}"
        }
        failure {
            slackSend color: '#E01E5A',
            channel: 'test-job',  
            message: "*Alpha Project Build Status*" +
            "\n Project Name: Alpha" +
            "\n Job Name: ${env.JOB_NAME}" +
            "\n Build number: ${currentBuild.displayName}" +
            "\n Build Status : *FAILED*" +
            "\n Build User : *Tia*" +
            "\n Action : Please check the console output to fix this job IMMEDIATELY" +
            "\n Build url : ${env.BUILD_URL}"
        }
        unstable {
            slackSend color: '#ECB22E',
            channel: 'test-job', 
            message: "*Alpha Project Build Status*" +
            "\n Project Name: Alpha" +
            "\n Job Name: ${env.JOB_NAME}" +
            "\n Build number: ${currentBuild.displayName}" +
            "\n Build Status : *UNSTABLE*" +
            "\n Action : Please check the console output to fix this job IMMEDIATELY" +
            "\n Build url : ${env.BUILD_URL}"
        } 
    }
}
