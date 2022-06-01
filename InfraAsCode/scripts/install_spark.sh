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
JAVA_HOME=/usr/local/java/jdk1.8.0_333
JRE_HOME=/usr/local/java/jdk1.8.0_333/jre/bin
CLASSPATH=/usr/local/java/jdk1.8.0_333/lib 
PATH=$PATH:/usr/local/java/jdk1.8.0_333/bin:/usr/local/java/jdk1.8.0_333:/usr/local/java/jdk1.8.0_333/jre/bin:/usr/local/java/jdk1.8.0_333/lib 
export JAVA_HOME JRE_HOME CLASSPATH PATH
EOF
. /etc/profile.d/java_home.sh

export SPARK_INSTALL_DIR=/opt/spark
adduser -m -d /home/spark spark
echo -e "engdados\nengdados" | passwd spark

systemctl start sshd
systemctl enable sshd

mkdir -p /opt/spark
cd /opt/
curl -o spark-3.2.1-bin-hadoop3.2.tgz "https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz" 
tar xzf spark-3.2.1-bin-hadoop3.2.tgz
rm -rf spark
mv spark-3.2.1-bin-hadoop3.2 spark
rm -f spark-3.2.1-bin-hadoop3.2.tgz
yum clean all
chown -R spark:spark /opt/spark

cd /opt
cat > /etc/profile.d/spark.sh <<  EOF
export SPARK_HOME=/opt/spark
PATH=$PATH:/opt/spark/bin:/opt/spark/sbin
export PATH 
EOF
. /etc/profile.d/spark.sh

cd /opt
cat > /opt/spark/conf/workers  <<  EOF
worker
EOF

_generate_ssh_keys () {
  mkdir -p /home/spark/.ssh
  ssh-keygen -t rsa -N '' -f /home/spark/.ssh/id_rsa
  sed -i 's/root/hadoop/g' /home/spark/.ssh/id_rsa.pub
  cat /home/spark/.ssh/id_rsa.pub >> /home/spark/.ssh/authorized_keys
  chmod 0600 /home/spark/.ssh/authorized_keys
  chown -R spark:spark /home/spark/.ssh
}
_generate_ssh_keys


