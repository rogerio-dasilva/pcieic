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

## Iniciar

```shell
> git clone https://github.com/rogerio-dasilva/pcieic.git
> podman-compose up
```

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
