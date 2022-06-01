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
yum clean all
chown -R hadoop:hadoop /opt/hadoop

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

#Arrumar arquivos do hadoop
gsutil -m cp gs://engdados-santander-install/arquivos_hadoop/* /opt/hadoop/etc/hadoop/
chown -R hadoop:hadoop /opt/hadoop

gsutil cp gs://engdados-santander-install/sshd_config /etc/ssh/sshd_config
systemctl restart sshd

