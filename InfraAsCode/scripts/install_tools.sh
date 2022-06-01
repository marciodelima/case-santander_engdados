#! /bin/bash
cd /opt/

yum update -y
yum install openssh-server openssh-client which wget -y

gsutil cp gs://engdados-santander-install/jdk-8u333-linux-x64.tar.gz .
tar zxvf jdk-8u333-linux-x64.tar.gz
rm -f jdk-8u333-linux-x64.tar.gz
mkdir -p /usr/local/java/
mv jdk1.8.0_333/ /usr/local/java/ 

cat > /etc/profile.d/java_home.sh <<  EOF
JAVA_HOME=/usr/local/java/jdk1.8.0_333/
JRE_HOME=/usr/local/java/jdk1.8.0_333/jre/bin
CLASSPATH=/usr/local/java/jdk1.8.0_333/lib 
PATH=$PATH:/usr/local/java/jdk1.8.0_333/bin:/usr/local/java/jdk1.8.0_333/:/usr/local/java/jdk1.8.0_333/jre/bin:/usr/local/java/jdk1.8.0_333/lib 
export JAVA_HOME JRE_HOME CLASSPATH PATH
EOF
. /etc/profile.d/java_home.sh

systemctl start sshd
systemctl enable sshd

useradd kafka -m
echo -e "engdados\nengdados" | passwd kafka
usermod -aG wheel kafka

useradd mongodb -m
echo -e "engdados\nengdados" | passwd mongodb
usermod -aG wheel mongodb

useradd mongod -m
usermod -aG wheel mongod

useradd mysql -m
echo -e "engdados\nengdados" | passwd mysql
usermod -aG wheel mysql

useradd hive -m
usermod -aG supergroup hive

useradd hue -m
usermod -aG supergroup hue

sudo chown -R mongod:mongod /var/lib/mongo
sudo chown -R mongod:mongod /var/log/mongodb

cd /opt
mkdir -p kafka
cd kafka
curl "https://downloads.apache.org/kafka/2.8.1/kafka_2.12-2.8.1.tgz" -o kafka.tgz
tar xzf  kafka.tgz --strip 1
rm -f kafka.tgz
chown -R kafka:kafka /opt/kafka

yum install git gcc-c++ make asciidoc cyrus-sasl-devel cyrus-sasl-gssapi krb5-devel libxml2-devel python-devel sqlite-devel openssl-devel gmp-devel openldap-devel mysql-server mysql mysql-devel libxslt-devel libffi libffi-devel maven npm -y

cd /opt
mkdir -p mongodb
cd mongodb
curl https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-5.0.8.tgz -o install.tgz
yum install libcurl openssl xz-libs -y
tar xzf install.tgz --strip 1
rm -r install.tgz
chown -R mongodb:mongodb /opt/mongodb

mkdir -p /var/lib/mongo
mkdir -p /var/log/mongodb
chown -R mongod:mongod /var/lib/mongo
chown -R mongod:mongod /var/log/mongodb





cd /opt
mkdir -p mysql
cd mysql
curl -sSLO https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
rpm -ivh mysql57-community-release-el7-9.noarch.rpm
yum install mysql-server
systemctl start mysqld


fhqsClnSs4)j


Engdados1!

CREATE USER 'engdados' IDENTIFIED BY 'Engdados1!';
GRANT ALL PRIVILEGES ON *.* TO 'engdados' WITH GRANT OPTION;
CREATE USER 'engdados'@'%' IDENTIFIED BY 'Engdados1!';
GRANT ALL PRIVILEGES ON *.* TO 'engdados'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;


sudo yum install postgresql-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

psql postgres

CREATE DATABASE huedb;
CREATE USER hue WITH ENCRYPTED PASSWORD 'hue';
GRANT ALL PRIVILEGES ON DATABASE huedb TO hue;


systemctl status postgresql.service


yum install python-devel -y
yum install postgresql-devel -y
cd /opt/hue
source build/env/bin/activate
pip install psycopg2
Synchronize Hue with the external database to create the schema and load the data:

cd /opt/hue
source build/env/bin/activate
hue syncdb --noinput
hue migrate
deactivate



