FROM debian:stable

COPY ./src/hashicorp.sources /etc/apt/sources.list.d/
COPY  ./src/loop.sh /app/
RUN chmod +x /app/loop.sh

ADD https://apt.releases.hashicorp.com/gpg  /tmp/gpg


RUN apt update 
RUN apt-get install -y gnupg ca-certificates unzip
RUN cat /tmp/gpg |  gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
#RUN apt install terraform
ADD   https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_386.zip /tmp/terraform.zip
RUN unzip /tmp/terraform.zip -d /tmp
RUN mv /tmp/terraform /usr/bin/

ENTRYPOINT ["/app/loop.sh"]
