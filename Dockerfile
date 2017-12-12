FROM centos:6

MAINTAINER Battcor <battcor@gmail.com>

WORKDIR /tmp

RUN yum -y install epel-release wget && \
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && \
    wget https://centos6.iuscommunity.org/ius-release.rpm && \
    rpm -Uvh ius-release*.rpm && \
    yum -y update

RUN yum -y install nginx

RUN yum -y install php56u php56u-fpm

RUN pear install XML_Parser

RUN echo -e "extension=phalcon.so" > /etc/php.d/phalcon.ini

RUN yum -y install git gcc

RUN git clone git://github.com/phalcon/cphalcon.git
RUN cd cphalcon/

RUN yum -y install php56u-devel

RUN wget https://github.com/phalcon/cphalcon/archive/phalcon-v2.0.13.zip

RUN yum -y install unzip

RUN unzip phalcon-v2.0.13.zip

RUN cd cphalcon-phalcon-v2.0.13/build && \
    ./install && \
    echo -e "extension=phalcon.so" > /etc/php.d/phalcon.ini

RUN yum -y install php56u-mysql

RUN mkdir /log && chmod -Rv 777 /log

RUN echo -e "date.timezone=\"Asia/Singapore\"" > /etc/php.d/timezone.ini

RUN echo -e "[mariadb]" >> /etc/yum.repos.d/MariaDB.repo && \
    echo -e "name = MariaDB" >> /etc/yum.repos.d/MariaDB.repo && \
    echo -e "baseurl = http://yum.mariadb.org/10.1/centos6-amd64" >> /etc/yum.repos.d/MariaDB.repo && \
    echo -e "gpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo && \
    echo -e "gpgcheck = 1" >> /etc/yum.repos.d/MariaDB.repo && \
    yum -y install MariaDB-client MariaDB-server

RUN yum -y install supervisor && \
    chkconfig supervisord on

RUN service mysql start && \
    mysql --user=root -e " \
        UPDATE mysql.user SET Password=PASSWORD('test123') WHERE User='root'; \
        DELETE FROM mysql.user WHERE User=''; \
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.0.1' IDENTIFIED BY 'test123'; \
        DROP DATABASE IF EXISTS test; \
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; \
        FLUSH PRIVILEGES;"

RUN git clone -b 2.0.x https://github.com/phalcon/cphalcon.git cphalcon-2.0.x && \
    cd cphalcon-2.0.x/build/ && \
    ./install && \
    echo 'extension=phalcon.so' > /etc/php.d/phalcon.ini

RUN yum -y install php56u-memcached memcached

RUN yum -y install php56u-memcache

EXPOSE 80
EXPOSE 3306
EXPOSE 11211

RUN service mysql start && \
    mysql --user=root -ptest123 -e " \
        UPDATE mysql.user SET Password=PASSWORD('test123') WHERE User='root'; \
        DELETE FROM mysql.user WHERE User=''; \
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'test123'; \
        DROP DATABASE IF EXISTS test; \
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; \
        FLUSH PRIVILEGES;"

CMD service mysql start && service memcached start && service php-fpm start && nginx -g 'daemon off;' && bash
