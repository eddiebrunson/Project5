pipeline {
	agent any
	stages {

		stage('Lint Blue/Green HTML') {
			steps {
				sh 'tidy -q -e ./blue/app_blue/*.html'
				sh 'tidy -q -e ./green/app_green/*.html'
			}
		}
		
		stage('Build Docker  Blue/Green Images') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker_hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){
					dir("blue") {
						sh '''
							docker login -u ${USERNAME} -p ${PASSWORD}
							docker build --tag=bluedeploymentimage .
						'''
          }

        }

        withCredentials(bindings: [[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker_hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
          dir(path: 'green') {
            sh '''
							docker login -u ${USERNAME} -p ${PASSWORD}
							docker build --tag greendeploymentimage .
						'''
          }

        }

      }
    }

    stage('Push Docker Blue/Green Images To Docker Hub') {
      steps {
        withCredentials(bindings: [[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker_hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
          dir(path: 'blue') {
            sh '''
							docker login -u ${USERNAME} -p ${PASSWORD}
							docker image tag bluedeploymentimage webdeveddie/bluedeploymentimage
							docker image push webdeveddie/bluedeploymentimage
						'''
          }

        }

        withCredentials(bindings: [[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker_hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
          dir(path: 'green') {
            sh '''
							docker login -u ${USERNAME} -p ${PASSWORD}
							docker image tag greendeploymentimage webdeveddie/greendeploymentimage
							docker image push webdeveddie/greendeploymentimage
						'''
          }

        }

      }
    }

    stage('Set the cluster as current context') {
      steps {
        withAWS(region: 'us-east-1', credentials: 'aws_devops') {
          sh '''
						kubectl config use-context arn:aws:eks:us-east-1:269387989609:cluster/devOps-Capstone1
					'''
        }

      }
    }

    stage('Deploy the blue container') {
      steps {
        dir(path: 'blue') {
          withAWS(region: 'us-east-1', credentials: 'aws_devops') {
            sh '''
							kubectl apply -f ./blue-controller.json
						'''
          }

        }

      }
    }

    stage('Deploy the green container') {
      steps {
        dir(path: 'green') {
          withAWS(region: 'us-east-1', credentials: 'aws_devops') {
            sh '''
							kubectl apply -f ./green-controller.json
						'''
          }

        }

      }
    }

    stage('Create service that redirects to the blue deployment') {
      steps {
        dir(path: 'blue') {
          withAWS(region: 'us-east-1', credentials: 'aws_devops') {
            sh '''
							kubectl apply -f ./blue-service.json
						'''
          }

        }

      }
    }

    stage('Redirect prompt') {
      steps {
        input 'Would you now like to redirect to the green deployment?'
      }
    }

    stage('Create the service that redirects to the green deployment') {
      steps {
        dir(path: 'green') {
          withAWS(region: 'us-east-1', credentials: 'aws_devops') {
            sh '''
							kubectl apply -f ./green-service.json
						'''
          }

        }

      }
    }

  }
}