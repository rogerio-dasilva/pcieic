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

## Informações dos Containeres

|service     |container_name|hostname          |url externa                 |url interna            |
|------------|--------------|------------------|----------------------------|-----------------------|
|jenkins     |jenkins       |ci.localhost      |<http://ci.localhost>       |http://jenkins:8080    |
|gitlab      |gitlab        |fontes.localhost  |<http://fontes.localhost>   |http://gitlab          |
|sonarqube   |sonarqube     |analise.localhost |<http://analise.localhost>  |http://sonarqube:9000  |
|h2          |h2            |db.localhost      |<http://db.localhost>       |http://h2:8082         |
|artifactory |artifactory   |binarios.localhost|<http://binarios.localhost> |http://artifactory:8081|
|tomcat      |tomcat        |web.localhost     |<http://web.localhost>      |http://tomcat:8080     |

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
- Conceder acesso nos repositórios
 - Nome menu lateral Admin
 - Clique em Security > Groups
 - Clique me New
 - Group name: repo_writer
 - Description: Gravar em repositórios
 - Users: Select admin e mande para a direita
 - Save
 - Nom menu sevurity > permission
 - Add permission
 - Name: pemissions_deploy_repo
 - Selecione todos os repos e mande para a direita
 - Selecione Aba Groups
 - Selecione repo_writer e mande para a direita
 - Selecione os Repository actions: Read; Annotate; Deploy/Cache
 - Save & Finish

### Gitlab

1 Login e Configuração
- Use o acesso default para configurar a nova senha e anote
- Criar token de acesso
  - Vá no menu Cofigurações no cabeçalho
  - No menu lateral, escolha Tokens de acesso
  - Nome: gitlab_token
  - Expira: deixe em branco
  - Scopes: marque: api, read_user, read_api, read_repository, write_repository
  - Clique em Create acesso pessoal token e anote: 4Vff_1A5nTf6R_LKuWoH
- Habilitar acesso em localhost
  - Clique em Admin area no cabeçalho
  - Em configurações no menu lateral
  - Rede
  - Pedidos de Saída
  - Marque: Allow requests to the local network from web hooks and services

2 Projeto de exemplo:
- Clique em New Group: informe um nome qualquer. Exemplo: tst
- Clique em Create group
- Clique em New project: informe um nome qualquer. Exemplo: tst-gitlab
- Marque Initialize repository with a README
- Clique em Create project
- Clique em Clone para clonar localmente o projeto
- Adicione o código exemplo e faça commit e push

3 Pipeline Jenkins:
- Clique em New Group: informe o nome: jenkins_ci
- Clique em Create group
- Clique em New project: informe o pipeline1.
- Clique em Create project
- Clique New file com o nome Jenkinsfile
- Adicione o conteúdo de Jenkinsfile

Adicionar projeto de exemplo aqui

### Jenkins
1 Login
- Informe a chave jenkins fornecida para logar
- Escolha instalaras extensões sugeridas
- Preencha os dados do usuário e anote.
  - nome do usuário
  - senha e confirma senha
  - nome completo
  - endereço de e-mail
- Em Configurar instancia, deixe o sugerido

2 Credenciais
- Clique no menu: Gerenciar jenkins
- Clique em credentials
- Clique em System
- Clique em Global credentials
- Clique em Add Credentials
- Nova credential para sonar
  - Em Kind escolha: Secret text
  - Scope: global
  - Secret: informe o token criado no sonar
  - ID: sonarqube_token
  - Description: sonarqube_token
- Nova Credencial para Gitlab
  - Kind: Gitlab API Token
  - Scope: Global
  - API Token: informe o token criado no gitlab
  - ID: gitlab_token
  - Description: gitlab_token
- Nova Credencial para Gitlab
  - Kind: Secret text
  - Scope: Global
  - Secret: informe o token criado no gitlab
  - ID: gitlab_token
  - Description: gitlab_token
- Nova Credencial para Gitlab
  - Kind: Username with password
  - Scope: Global
  - Username: root
  - Password: informe a senha
  - ID: gitlab_user_pwd
  - Description: gitlab_user_pwd
- Nova Credencial para Artifactory
  - Kind:  Username with password
  - Scope: Global
  - Username: admin
  - Passoword: informe o tokean api gerado no artifactory
  - ID: artifactory_token
  - Description: artifactory_token
- Nova Credencial para Tomcat
  - Kind:  Username with password
  - Scope: Global
  - Username: tomcat
  - Passoword: tomcat
  - ID: tomcat-user-pwd
  - Description: tomcat-user-pwd

3 Arquivo Gerenciados
- Clique no menu: Gerenciar jenkins
- Clique em Managed Files
- Clique Add a new Config
  - Type: Global Maven settings.xml
  - ID: global-maven-settings1
  - Clique em next
  - Name: global-maven-settings1
  - Comment: Global maven settings para publicar no artifactory
  - Clique em: Server Credentials > Adicionar
  - ServerId: central
  - Credentials: selecione: admin/***** (artifactory_token)
  - Clique em: Server Credentials > Adicionar
  - ServerId: snapshots
  - Credentials: selecione: admin/***** (artifactory_token)
  - Content: informe o conteúdo do xml Maven global settings.xml abaixo
  - Clique em Submit

4 Configuração em System
- Clique no menu: Gerenciar jenkins
- Clique em: System
- SonarQube installations
  - Clique em Add SonarQube
  - Name: sonarqube-instalacao
  - Server URL: http://sonarqube:9000
  - Server authenticationtoken: selecione: sonarqube_token
- Usage Statistics
  - desmarque Ajude o Jenkins a melhorar enviando relatórios anõnimos de erro
- GitLab
  - Connection name: gitlab
  - GitLab host URL: http://gitlab
  - Credentials: selecione: GitLab API TOken (gitlab_token)
- Clique em Salvar

5 Ferramentas do Jenkins
- Clique no menu: Gerenciar jenkins
- Clique em: Tools
- Maven Configuration:
  - Default global settings provider
  - selecione provided global settings.xml
  - selecione global-maven-settings1
- JDK instalações
  - Clique em Adicionar JDK
  - Nome: openjdk-17
  - JAVA_HOME: /opt/java/openjdk
- SonarQube Scanner instalações
  - Clique em Adicionar SonarQube Scanner
  - Name: sonarqube-instalacao
  - Deixe marqcado Instalar autoticamente
    - Versão: SonarQube Scanner 6.0.0.4432
- Maven instalações
  - Clique em Adicionar Maven
  - Nome: maven-instalacao
  - Deixe marcado: Instalar automaticamente
  - Versão: 3.9.7
- Clique em Save

 6 Tarefas
 - Clique no menu lateral: Novo tarefa
 - Entre com um nome de item: tst-gitlab
 - Select an item type: Pipeline
 - Clique em Tudo certo

7 Tarefa tst-gitlab
- Descrição: Teste de integração
- Gitlab Connections: gitlab
- Build triggers
  - Marque: Build when a change is pushed to GitLab. GitLab webhook URL: http://ci.localhost/project/tst-gitlab
  - Avançado
    - Allowed banches
    - Selecione Filter branches by name
    - Include: master
    - Secret token: clique em Generate e anote: 28c146f2c31bc48d63f5ec5a0a9770e0
  - Pipeline
    - Definition: selecione: Pipeline script from SCM
    - SCM: Git
    - Repository URL: http://gitlab/jenkins_ci/pipeline1.git
    - Credentials: selecione: root/****(gotlab_usr_pwd)
- Clique em Salvar

7 Disparo de Webhook 
- Vá no gitlab http://fonte.localhost
- Vá no projeto tst/tst-gitlab
- No menu lateral: Configurações > Webhooks
  - URL: http://jenkins:8080/project/tst-gitlab
  - Secret Token: informe o que foi gerado na tarefa do jenkins
  - Tirgger: Push events
  - SSL Verification: desmarque
  - Clique em Add webhook

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
          <name>libs-release-local</name>
          <url>http://artifactory:8081/artifactory/libs-release-local</url>
        </repository>
        <repository>
          <snapshots />
          <id>snapshots</id>
          <name>libs-snapshot-local</name>
          <url>http://artifactory:8081/artifactory/libs-snapshot-local</url>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
          <id>central</id>
          <name>libs-release-local</name>
          <url>http://artifactory:8081/artifactory/libs-release-local</url>
        </pluginRepository>
        <pluginRepository>
          <snapshots />
          <id>snapshots</id>
          <name>libs-snapshot-local</name>
          <url>http://artifactory:8081/artifactory/libs-snapshot-local</url>
        </pluginRepository>
      </pluginRepositories>
      <id>artifactory</id>
      <properties>
        <altSnapshotDeploymentRepository>snapshots::http://artifactory:8081/artifactory/libs-snapshot-local/</altSnapshotDeploymentRepository>
        <altReleaseDeploymentRepository>central::http://artifactory:8081/artifactory/libs-release-local/</altReleaseDeploymentRepository>
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
        stage('Conferir Fontes') {
            steps {
                git credentialsId: 'gitlab_user_pwd', url: 'http://gitlab/tst/tst-gitlab.git'
            }
        }
        stage('Construir') {
            steps {
                withMaven(globalMavenSettingsConfig: 'global-maven-settings1', jdk: 'openjdk-17', maven: 'maven-instalacao', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn -e -U clean install" 
                }
            }
        }
        stage('Arquivar') {
            steps {
                withMaven(globalMavenSettingsConfig: 'global-maven-settings1', jdk: 'openjdk-17', maven: 'maven-instalacao', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy -Dmaven.test.skip=true"
                }
            }
        }
        stage('Analisar') {
            steps {
                withSonarQubeEnv(credentialsId: 'sonarqube_token', installationName: 'sonarqube-instalacao') {
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
