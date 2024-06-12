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
.
├── construir
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── plugins.txt
├── nginx
│   ├── html
│   │   ├── custom_404.html
│   │   ├── custom_50x.html
│   │   └── index.html
│   ├── proxyConf
│   │   ├── custom.conf
│   │   └── server.conf
│   └── nginx.conf
├── tomcat
│   └── config
│   │   └── tomcat-users.xml
│   └── webapps
│       ├── host-manager
│       │   └── <vários arquivos>
│       └── manager
│           └── <vários arquivos>
├── .gitignore
├── LICENSE
├── README.md
└── docker-compose.yml
```


## Preparar Imagem Jenkins com plugins
Criar imagem local do Jenkins com os plugins necessários que estão no arquivo construir/plugins.txt.

Faça primeiro a construção, com sudo, da imagem jenkins com plugins selecionados para a imagem ficar disponível para o próximo passo.

> Nota: verifique se é necessário com docker/docker-compose

```shell
cd construir
sudo podman-compose build
```

## Iniciar
Para o nginx fazer ligação com a porta 80 no WSL2 será necessário executar podman com sudo.

> Nota: verifique se é necessário com docker/docker-compose

```shell
sudo podman-compose up
```

## Docker Compose Services: Container Name/Hostname
- jenkins: jenkins/ci.localhost <http://ci.localhost> -> Jenkins
- gitlab: gitlab/fontes.localhost <http://fontes.localhost> -> Gitlab
- sonarqube: sonarqube/analise.localhost <http://analise.localhost> -> SonarQube
- h2: h2/db.localhost <http://db.localhost> -> H2 Database
- artifactory: artifactory/binarios.localhost <http://binarios.localhost> -> JFrog Artifactory
- tomcat: tomcat/web.localhost <http://web.localhost> -> Tomcat

## Credenciais e Chaves de Acesso default
- Administrador usuario/senha do Jenkins: token de acesso da instalação incial
- Administrador usuário/senha do Sonar: admin/admin
- Administrador usuário/senha do Artifactory: admin/password
- Administrador usuário/senha do Gitlab: root/\<criado no primeiro acesso>
- Administrador usuário/senha do H2: sa/sa
- Administrador usuário/senha do tomcat: tomcat/tomcat

### Token da instalação incial do Jenkins
É apresento na saída do log de inicialização o token para ser utilizado na configuração inicial do Jenkins, como mostrado abaixo:

```log
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

78651259c23d4b2dae4a12d7cc7610e2

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
``

Se for difícil encontrá-lo, pode-se encontrá-lo no volume montado

```shell
// ver a localização do volume
sudo podman inspect jenkins | grep volume
"Source": "/var/lib/containers/storage/volumes/ci_jenkins_home/_data",

// abra um terminal com sudo e veja o arquivo de token
sudo bash
cd /var/lib/containers/storage/volumes/ci_jenkins_home/_data/secrets/
cat initialAdminPassword
```

- Token do Gitlab para usar no Jenkins:
- Token do Jenkins para usar no Gitlab:
- Token do Sonar para usar no Jenkins:
- Token do Artifactoy para usar no Jenkins:

## Preparar a configuração das ferramentas

### SonarQube
- Use o acesso default para configurar a nova senha e anote
- Criar o token de acesso para o Jenkins enviar os dados para o sonar
  - No menu Admistration > Security > Users
  - No usuário admin, na coluna Tokens, clique em Update Tokens
  - Em generate Tokens, informe o nome, exemplo: sonar_token; Em Expires in escolha, No expiration; Clique em Generate
  - Copie o token e anote: squ_be087d42133889a89af82538e3f9fd6879fbd366
  - Clique em Done

### JFrog Artifactory
- Use o acesso default para configurar a nova senha e anote. Será redirecionado para Quick Setup
- Na configuração de Proxy, use skip
- Em Create repo: marque gerenric e maven
- Depois de concluído a configuração, gerar token de acesso:
  - Na cabeçalho, clique em Welcome, admin > Edit Profile
  - Em Current Password, informe a senha e clique em Unlock
  - Em Authentication Settings, API Key, Clique no ícone engrenagem, para gerar o token
  - Clique no ícone Copy Key to clipboard e anote: AKCpBseqkxSKiULPt4ecHcJAunro22qrbenWjdqfPsR8b2VEn7hX9ttbEB2L4vKh38L8wjvPS

### Gitlab

1 Projeto de exemplo:
- Use o acesso default para configurar a nova senha e anote
- Clique em New Group: informe um nome qualquer. Exemplo: tst
- Clique em Create group
- Clique em New project: informe um nome qualquer. Exemplo: tst-gitlab
- Marque Initialize repository with a README
- Clique em Create project
- Clique em Clone para clonar localmente o projeto
- Adicione o código exemplo e faça commit e push

2 Pipeline Jenkins:
- Clique em New Group: informe o nome: jenkins_ci
- Clique em Create group
- Clique em New project: informe o pipeline1.
- Clique em Create project
- Clique New file com o nome Jenkinsfile
- Adicione o conteúdo de Jenkinsfile


## Arquivos

### Maven global settings.xml

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


### Jenkinsfile

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
