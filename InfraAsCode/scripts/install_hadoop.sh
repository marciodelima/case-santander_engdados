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

export HADOOP_INSTALL_DIR=/opt/hadoop
export SPARK_INSTALL_DIR=/opt/spark
adduser -m -d /home/hadoop hadoop
echo -e "engdados\nengdados" | passwd hadoop
 
systemctl start sshd
systemctl enable sshd

mkdir -p /opt/hadoop
cd /opt/
curl -o hadoop-3.3.2.tar.gz "https://dlcdn.apache.org/hadoop/common/hadoop-3.3.2/hadoop-3.3.2.tar.gz" 
tar xzf  hadoop-3.3.2.tar.gz
rm -rf hadoop
mv hadoop-3.3.2 hadoop
rm -f hadoop-3.3.2.tar.gz
chown -R hadoop:hadoop /opt/hadoop

_generate_ssh_keys () {
  mkdir -p /home/hadoop/.ssh
  ssh-keygen -t rsa -N '' -f /home/hadoop/.ssh/id_rsa
  sed -i 's/root/hadoop/g' /home/hadoop/.ssh/id_rsa.pub
  cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
  chmod 0600 /home/hadoop/.ssh/authorized_keys
  chown -R hadoop:hadoop /home/hadoop/.ssh
}
_generate_ssh_keys

#Hue
cd /opt
yum install git gcc-c++ make asciidoc cyrus-sasl-devel cyrus-sasl-gssapi krb5-devel libxml2-devel python-devel sqlite-devel openssl-devel gmp-devel openldap-devel mysql-server mysql mysql-devel libxslt-devel libffi libffi-devel maven npm -y
git clone https://github.com/cloudera/hue.git
cd hue
make apps
chown -R hadoop:hadoop /opt/hue
gsutil -m cp gs://engdados-santander-install/arquivos_hadoop/pseudo-distributed.ini /opt/hue/desktop/conf/

#Hive
cd /opt/
curl -o apache-hive-3.1.2-bin.tar.gz "https://dlcdn.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz" 
tar xzf apache-hive-3.1.2-bin.tar.gz
mv apache-hive-3.1.2-bin hive
rm -f apache-hive-3.1.2-bin.tar.gz
chown -R hadoop:hadoop /opt/hive

cd /opt
cat > /etc/profile.d/hadoop.sh <<  EOF
export HADOOP_USER_HOME=/home/hadoop
export HADOOP_HOME=/opt/hadoop
export HADOOP_PREFIX=/opt/hadoop
export HADOOP_INSTALL=/opt/hadoop
export HADOOP_MAPRED_HOME=/opt/hadoop
export HADOOP_COMMON_HOME=/opt/hadoop
export HADOOP_HDFS_HOME=/opt/hadoop
export JAVA_LIBRARY_PATH=/usr/local/java/jdk1.8.0_333/lib:/opt/hadoop/lib/native
export YARN_HOME=/opt/hadoop
export HADOOP_COMMON_LIB_NATIVE_DIR=/opt/hadoop/lib/native
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export CORE_SITE_FILE=/opt/hadoop/core-site.xml
export HDFS_SITE_FILE=/opt/hadoop/hdfs-site.xml
export MAPRED_SITE_FILE=/opt/hadoop/mapred-site.xml
export YARN_SITE_FILE=/opt/hadoop/yarn-site.xml
export WORKERS_FILE=/opt/hadoop/slaves
PATH=$PATH:/opt/hadoop/sbin:/opt/hadoop/bin
export PATH 
EOF
. /etc/profile.d/hadoop.sh

cat > /etc/profile.d/hive.sh <<  EOF
export HIVE_HOME=/opt/hive
export HIVE_PORT=10000
export HIVE_CONF_DIR=/opt/hive/conf
export 
PATH=$PATH:/opt/hive/bin
export PATH
EOF
. /etc/profile.d/hive.sh

#Arrumar arquivos do hadoop e hive
gsutil -m cp gs://engdados-santander-install/arquivos_hadoop/* /opt/hadoop/etc/hadoop/
chown -R hadoop:hadoop /opt/hadoop

gsutil -m cp gs://engdados-santander-install/arquivos_hadoop/hive* /opt/hive/conf/
chown -R hadoop:hadoop /opt/hive

gsutil cp gs://engdados-santander-install/sshd_config /etc/ssh/sshd_config
systemctl restart sshd

mkdir -p /var/log/hue
chmod 777 /var/log/ -R

