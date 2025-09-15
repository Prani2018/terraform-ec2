#!/bin/bash

# Update system
yum update -y

# Install required packages
yum install -y git wget curl unzip java-17-openjdk java-11-openjdk-devel maven

# Set JAVA_HOME
export PATH=$PATH:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin >> /etc/environment
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk' >> /etc/environment
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/environment
source /etc/environment

######### Install Tomcat 9
########cd /opt
########wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.82/bin/apache-tomcat-9.0.82.tar.gz
########tar -xzf apache-tomcat-9.0.82.tar.gz
########mv apache-tomcat-9.0.82 tomcat
########rm apache-tomcat-9.0.82.tar.gz
########
######### Create tomcat user
########useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
########chown -R tomcat: /opt/tomcat
########
######### Set executable permissions
########chmod +x /opt/tomcat/bin/*.sh
########
######### Create systemd service for Tomcat
########cat > /etc/systemd/system/tomcat.service << 'EOF'
########[Unit]
########Description=Apache Tomcat Web Application Container
########After=network.target
########
########[Service]
########Type=forking
########User=tomcat
########Group=tomcat
########Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk"
#########Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64"
#########/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java
########Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
########Environment="CATALINA_HOME=/opt/tomcat"
########Environment="CATALINA_BASE=/opt/tomcat"
########Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
########
########
########ExecStart=/opt/tomcat/bin/startup.sh
########ExecStop=/opt/tomcat/bin/shutdown.sh
########RestartSec=10
########Restart=always
########
########[Install]
########WantedBy=multi-user.target
########EOF
########
######### Enable and start Tomcat
########sudo systemctl daemon-reload
########sudo systemctl enable tomcat
########sudo systemctl start tomcat
########
######### Configure Tomcat users for management
########cat > /opt/tomcat/conf/tomcat-users.xml << 'EOF'
########<?xml version="1.0" encoding="UTF-8"?>
########<tomcat-users xmlns="http://tomcat.apache.org/xml"
########              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
########              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
########              version="1.0">
########  <role rolename="manager-gui"/>
########  <role rolename="manager-script"/>
########  <role rolename="manager-jmx"/>
########  <role rolename="manager-status"/>
########  <user username="admin" password="admin123" 
########        roles="manager-gui,manager-script,manager-jmx,manager-status"/>
########  <user username="deployer" password="deployer123" 
########        roles="manager-script,manager-status"/>
########</tomcat-users>
########EOF
########
######### Allow remote access to manager app
########sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/,/allow="[^"]*"/c\
########  <!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"\
########         allow="127\\.0\\.0\\.1|::1|0:0:0:0:0:0:0:1" /> -->' /opt/tomcat/webapps/manager/META-INF/context.xml
########
# Install Jenkins (optional)
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins

# Configure Jenkins
systemctl enable jenkins
systemctl start jenkins

# Install Docker (optional)
yum install -y docker
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user

# Create application directory
mkdir -p /home/ec2-user/workspace
cd /home/ec2-user/workspace

# Clone repository if URL is provided
if [ ! -z "${git_repo_url}" ]; then
    echo "Cloning repository: ${git_repo_url}"
    git clone ${git_repo_url} ${app_name}
    cd ${app_name}
    
    # Build application if pom.xml exists
    if [ -f "pom.xml" ]; then
        echo "Building Maven application..."
        mvn clean package
        
        # Deploy to Tomcat if WAR file exists
        if [ -f "target/${app_name}.war" ]; then
            cp target/${app_name}.war /opt/tomcat/webapps/
            chown tomcat:tomcat /opt/tomcat/webapps/${app_name}.war
        fi
    fi
    
    chown -R ec2-user:ec2-user /home/ec2-user/workspace
fi

# Configure firewall
yum install -y firewalld
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=8081/tcp
firewall-cmd --reload

# Restart Tomcat to pick up new applications
systemctl restart tomcat

# Create startup script for applications
cat > /home/ec2-user/deploy.sh << 'EOF'
#!/bin/bash
cd /home/ec2-user/workspace/${app_name}
git pull origin main
mvn clean package
sudo cp target/*.war /opt/tomcat/webapps/
sudo systemctl restart tomcat
echo "Application deployed successfully!"
EOF

chmod +x /home/ec2-user/deploy.sh
chown ec2-user:ec2-user /home/ec2-user/deploy.sh

# Log completion
echo "EC2 setup completed at $(date)" >> /var/log/user-data.log

# Display service status
systemctl status tomcat >> /var/log/user-data.log
systemctl status jenkins >> /var/log/user-data.log
