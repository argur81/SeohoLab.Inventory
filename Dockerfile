FROM tomcat:8.5-jdk8-openjdk
# 기존 webapps 폴더를 비우고
RUN rm -rf /usr/local/tomcat/webapps/*
# 우리 프로젝트의 WebContent(또는 webapp) 폴더 내용을 톰캣 루트로 복사
COPY src/main/webapp /usr/local/tomcat/webapps/ROOT
EXPOSE 8080
CMD ["catalina.sh", "run"]