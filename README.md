# Projeto de estudo para Entrega Contínua

## Configuração utilizada
- hospedeiro
  - Windows 11
- convidado:
  - WSL2 Ubuntu-22
  - podman: 3.4.4
  - podman-compose: 1.0.6

## Hosts no Windows
```text
127.0.0.1       db.localhost
127.0.0.1       ci.localhost
127.0.0.1       fontes.localhost
127.0.0.1       analise.localhost
127.0.0.1       binarios.localhost
127.0.0.1       web.localhost
```

## Baixar projeto

```shell
git clone https://github.com/rogerio-dasilva/pcieic.git
```

Estrutura de pastas e arquivos:

```text

```


## Preparar Imagem Jenkins com plugins

Criar imagem local do Jenkins com os plugins necessários, que estão no arquivo build/plugins.txt.

Faça a cosntrução com sudo para a imagem ficar disponível para o próximo passo.

> Nota: verifique se é necessário com docker/docker-compose

```shell
cd build
sudo podman-compose build
```

## Iniciar

Para o nginx fazer ligação com a porta 80 será necessário executar podman com sudo.

> Nota: verifique se é necessário com docker/docker-compose

```shell
sudo podman-compose up
```

## Endereços carregados
- <http://db.localhost:8000>
- <http://web.localhost:8000>
- <http://fontes.localhost:8000>
- <http://binarios.localhost:8000>
- <http://analise.localhost:8000>
- <http://ci.localhost:8000>

## Docker Compose Services: Container Name/Hostname
- jenkins: jenkins/ci.localhost
- gitlab: gitlab/fontes.localhost
- sonarqube: sonarqube/analise.localhost
- h2: h2/db.localhost
- artifactory: artifactory/binarios.localhost
- tomcat: tomcat/web.localhost
- nginx: nginx/vip.localhost

## Credenciais e Chaves de Acesso a serem criadas
- Administrador usuario/senha do Jenkins:
- Administrador usuário/senha do Sonar::
- Administrador usuário/senha do Artifactory:
- Administrador usuário/senha do Gitlab:
- Administrador usuário/senha do H2: sa/sa
- Administrador usuário/senha do tomcat: tomcat/tomcat
- Token do Gitlab para usar no Jenkins:
- Token do Jenkins para usar no Gitlab:
- Token do Sonar para usar no Jenkins:
- Token do Artifactoy para usar no Jenkins:

## Arquivos

Maven global settings.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" 
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

  <pluginGroups>
  </pluginGroups>

  <proxies>
  </proxies>

  <servers>
  </servers>

  <mirrors>
  </mirrors>
 
  <profiles>
    <profile>
      <repositories>
        <repository>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
          <id>central</id>
          <name>libs-release</name>
          <url>http://artifactory:8081/artifactory/libs-release</url>
        </repository>
        <repository>
          <snapshots />
          <id>snapshots</id>
          <name>libs-snapshot</name>
          <url>http://artifactory:8081/artifactory/libs-snapshot</url>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
          <id>central</id>
          <name>libs-release</name>
          <url>http://artifactory:8081/artifactory/libs-release</url>
        </pluginRepository>
        <pluginRepository>
          <snapshots />
          <id>snapshots</id>
          <name>libs-snapshot</name>
          <url>http://artifactory:8081/artifactory/libs-snapshot</url>
        </pluginRepository>
      </pluginRepositories>
      <id>artifactory</id>
      <properties>
        <altSnapshotDeploymentRepository>snapshots::default::http://artifactory:8081/artifactory/libs-snapshot/</altSnapshotDeploymentRepository>
        <altReleaseDeploymentRepository>central::default::http://artifactory:8081/artifactory/libs-release/</altReleaseDeploymentRepository>
      </properties>
    </profile>
    <profile>
      <repositories>
        <repository>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
          <id>central</id>
          <name>maven-release</name>
          <url>https://repo1.maven.org/maven2</url>
        </repository>
        <repository>
          <snapshots />
          <id>snapshots</id>
          <name>maven-snapshot</name>
          <url>https://repo1.maven.org/maven2</url>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
          <id>central</id>
          <name>maven-release</name>
          <url>https://repo1.maven.org/maven2</url>
        </pluginRepository>
        <pluginRepository>
          <snapshots />
          <id>snapshots</id>
          <name>maven-snapshot</name>
          <url>https://repo1.maven.org/maven2</url>
        </pluginRepository>
      </pluginRepositories>
      <id>maven</id>
    </profile>
  </profiles>

  <activeProfiles>
    <activeProfile>maven</activeProfile>
    <activeProfile>artifactory</activeProfile>
  </activeProfiles>
</settings>
```


Jenkinsfile

```groovy
pipeline {
    agent any
    
    environment {
        mvnHome =  tool name: 'maven-instalacao', type: 'maven'
    }
    
    stages {
//        stage('Preparar') {
//            steps {
//                echo 'Olá Mundo!'
////                sh "${mvnHome}/bin/mvn  -version"
//                withMaven(globalMavenSettingsConfig: '', jdk: 'openjdk-17', maven: 'maven-instalacao', mavenSettingsConfig: '', traceability: true) {
//                    sh "mvn -version" 
//                }
//            }
//        }
        stage('Conferir Fontes') {
            steps {
                git credentialsId: 'gitlab-username', url: 'http://gitlab/tst/tst-gitlab.git'
            }
        }
        stage('Construir') {
            steps {
//                sh "${mvnHome}/bin/mvn clean verify"
//                archiveArtifacts artifacts: '**/*.war', followSymlinks: false, onlyIfSuccessful: true
                withMaven(globalMavenSettingsConfig: '', jdk: 'openjdk-17', maven: 'maven-instalacao', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn -e -U clean install" 
                }
            }
        }
//        stage('Testar') {
//            steps {
//                echo 'Testaando...'
//            }
//        }
        stage('Arquivar') {
            steps {
//                archiveArtifacts artifacts: '**/*.war', followSymlinks: false
//                artifactoryUpload failNoOp: false
//                withMaven(globalMavenSettingsConfig: '', jdk: 'openjdk-17', maven: 'maven-instalacao', mavenSettingsConfig: '', traceability: true) {
//                    sh "mvn deploy -DaltSnapshotDeploymentRepository=snapshots::default::http://artifactory:8081/artifactory/libs-snapshot -DaltReleaseDeploymentRepository=central::default:http://artifactory:8081/artifactory/libs-release" 
//                }
                withMaven(globalMavenSettingsConfig: 'maven-settings-artifactory', jdk: '', maven: 'maven-instalacao', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy -Dmaven.test.skip=true"
                }
//                 echo 'Arquivando...'
            }
        }
        stage('Analisar') {
            steps {
                withSonarQubeEnv(credentialsId: 'sonarqube_token', installationName: 'sonarquber-instalacao') {
                    sh '${mvnHome}/bin/mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar'
                }
            }
        }
        stage('Implantar') {
            environment {
                TOMCAT_USER_PWD = credentials('tomcat-user-pwd')
                TOMCAT_DEPLOY = "http://${TOMCAT_USER_PWD}@tomcat:8080/manager/deploy?path=&update=true"
            }
            steps {
                sh('echo Implantando...')
                sh 'cp target/*.war target/ROOT.war'
                sh 'curl --fail-with-body --upload-file "target/ROOT.war" "http://${TOMCAT_USER_PWD}@tomcat:8080/manager/text/deploy?path=&update=true"'
                
//                deploy adapters: [tomcat9(credentialsId: 'tomcat-user-pwd', path: '', url: 'http://tomcat:8080')], 
//                    onFailure: false, 
//                    war: 'target/ROOT.war'
            }
        }
    }
}
```

## Referências usadas
- <https://docs.podman.io/en/latest/index.html>
- <https://github.com/containers/podman-compose>
- <https://hub.docker.com/>
- <https://nginx.org/en/docs/>
- <https://www.reddit.com/r/podman/comments/14f6frv/podman_automatically_sets_cniversion_100_instead/>
- <https://dev.to/danielkun/nginx-everything-about-proxypass-2ona>
- <https://docs.pages.neomind.com.br/central-de-ajuda/en/docs/materiaistecnicos/linux/nginxlinux/>
- <https://blog.devops.dev/simple-ci-cd-pipeline-integrating-jenkins-with-maven-and-github-to-build-a-job-on-a-tomcat-server-275e66a2e640>
- <https://callmezydd.medium.com/unlocking-code-quality-integrating-jenkins-pipeline-with-sonarqube-and-github-7f450f1c90ab>
- <https://medium.com/@sudheer.barakers/jenkins-ci-cd-pipeline-to-deploy-java-application-on-tomcat-server-97b92df2da38>
- <https://medium.com/@GeorgeBaidooJr/setting-up-a-ci-cd-pipeline-using-git-jenkins-and-maven-6bd6f3f52886>
- <https://medium.com/@WayneWu411/how-to-trigger-jenkins-pipeline-from-gitlab-8b581bb9416>
- <https://medium.com/@jatinnandwani.official/part-6-how-to-create-a-pipeline-in-jenkins-using-pipeline-script-and-scm-34a1c9c6ce38>
- <https://medium.com/@lilnya79/integrating-sonarqube-with-jenkins-fe20e454ccf4>
- <https://medium.com/@denis.verkhovsky/sonarqube-with-docker-compose-complete-tutorial-2aaa8d0771d4>
- <https://medium.com/@WayneWu411/how-to-trigger-jenkins-pipeline-from-gitlab-8b581bb9416>
- <https://www.linkedin.com/pulse/build-delivery-cicd-pipeline-your-maven-project-help-jenkins-meta-g0rpf>
- <https://umut-boz.medium.com/running-jfrog-artifactory-oss-7-with-docker-cd5675bbb0ca>
- <https://docs.gitlab.com/ee/security/webhooks.html#allowlist-for-local-requests>
- <https://stackoverflow.com/questions/45777031/maven-not-found-in-jenkins>
- <https://github.com/wolkenheim/apache-tomcat-9-manager-gui>
- <https://github.com/ramannkhanna2/tomcat-maven-jenkins-pipeline>
- <https://serverfault.com/questions/683605/docker-container-time-timezone-will-not-reflect-changes>
- <https://k21academy.com/devops-job-bootcamp/ci-cd-pipeline-using-jenkins/>
- <https://www.baeldung.com/ops/jenkins-scripted-vs-declarative-pipelines>
- <https://www.youtube.com/watch?v=lH766fPpBcE>
- <https://github.com/jenkinsci/docker>
- <https://github.com/jenkinsci/configuration-as-code-plugin/tree/master>
- <https://github.com/jenkinsci/plugin-installation-manager-tool/?tab=readme-ov-file>
