FROM debian:stable

#COPY ./src/hashicorp.sources /etc/apt/sources.list.d/
COPY  ./src/loop.sh /app/
RUN chmod +x /app/loop.sh




RUN apt update 
RUN apt-get install -y gnupg ca-certificates unzip  apt-transport-https lsb-release

#ADD https://apt.releases.hashicorp.com/gpg  /tmp/hashi.gpg
#RUN cat /tmp/hashi.gpg |  gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

ADD https://packages.microsoft.com/keys/microsoft.asc /tmp/ms.gbg
RUN cat /tmp/ms.gbg |  gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
RUN chmod go+r /etc/apt/keyrings/microsoft.gpg
RUN AZ_REPO=$(lsb_release -cs) ; echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update
RUN apt-get install -y      azure-cli 

#RUN apt install terraform
ADD   https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_386.zip /tmp/terraform.zip
RUN unzip /tmp/terraform.zip -d /tmp
RUN mv /tmp/terraform /usr/bin/

ENTRYPOINT ["/app/loop.sh"]
