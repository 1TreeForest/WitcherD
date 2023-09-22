#!/bin/bash

############################# basebuild
# Update package sources and install essential tools
sudo apt-get update
sudo apt-get install -y aria2 curl wget git

# Install apt-fast
sudo apt-get install -y software-properties-common
add-apt-repository ppa:apt-fast/stable
sudo apt-get update
sudo apt-get install -y apt-fast
sudo apt-fast update --fix-missing
sudo apt-fast -y upgrade

# Install required packages
sudo apt-fast install -y build-essential libxml2-dev libxslt1-dev libffi-dev cmake libreadline-dev libtool debootstrap debian-archive-keyring libglib2.0-dev libpixman-1-dev libssl-dev qtdeclarative5-dev libcapnp-dev libtool-bin libcurl4-nss-dev libpng-dev libgmp-dev libc6:i386 libgcc1:i386 libstdc++6:i386 libtinfo5:i386 zlib1g:i386 python3-pip sudo automake net-tools netcat ccache make g++-multilib pkg-config coreutils rsyslog manpages-dev ninja-build capnproto software-properties-common zip unzip pwgen libxss1 bison flex gawk cvs ncurses-dev

# Copy the httpreqr folder and compile
sudo cp -r ../base/httpreqr /httpreqr
cd /httpreqr
make

# Copy the wclibs folder and compile
sudo cp -r ../base/wclibs /wclibs
cd /wclibs
gcc -c -Wall -fpic db_fault_escalator.c
gcc -shared -o lib_db_fault_escalator.so db_fault_escalator.o -ldl
sudo rm -f /wclibs/libcgiwrapper.so
sudo ln -s /wclibs/lib_db_fault_escalator.so /wclibs/libcgiwrapper.so
sudo ln -s /wclibs/lib_db_fault_escalator.so /lib/libcgiwrapper.so

# Copy the Widash folder and compile
sudo cp -r ../base/Widash /Widash
cd /Widash
sudo ./autogen.sh
automake
bash ./x86-build.sh

############################# php7build
# Define PHP version
ARG_PHP_VER=7
export PHP_VER=${ARG_PHP_VER}
PHP_INI_DIR="/etc/php/"
LD_LIBRARY_PATH="/wclibs"
PROF_FLAGS="-lcgiwrapper -I/wclibs"
CPATH="/wclibs"

# Create necessary directories
sudo mkdir -p $PHP_INI_DIR/conf.d /phpsrc
sudo cp -r ../php7/repo /phpsrc

# Copy required files
sudo cp ../php7/witcher-php-install/php-7.3.3-witcher.patch /phpsrc/witcher.patch
sudo cp ../php7/witcher-php-install/zend_witcher_trace.c witcher-php-install/zend_witcher_trace.h /phpsrc/Zend/

# Install Apache and its development files
sudo apt-get update && sudo apt-get install -y apache2 apache2-dev

# Apply patch and build PHP
cd /phpsrc
sudo git apply ./witcher.patch
sudo ./buildconf --force
sudo ./configure \
  --with-apxs2=/usr/bin/apxs \
  --enable-cgi \
  --enable-ftp \
  --enable-mbstring \
  --with-gd \
  --with-mysql \
  --with-ssl \
  --with-mysqli \
  --with-pdo-mysql \
  --with-zlib
printf "\033[36m[Witcher] PHP $PHP_VER Configure completed \033[0m\n"

# Build PHP
sudo make clean
sudo EXTRA_CFLAGS="-DWITCHER_DEBUG=1" make -j $(nproc)
printf "\033[36m[Witcher] PHP $PHP_VER Make completed \033[0m\n"

# Install PHP
sudo make install
printf "\033[36m[Witcher] PHP $PHP_VER Install completed \033[0m\n"

############################# baserun
# Install required packages
sudo apt-fast install -y build-essential \
    # Libraries
    libxml2-dev libxslt1-dev libffi-dev cmake libreadline-dev \
    libtool debootstrap debian-archive-keyring libglib2.0-dev libpixman-1-dev \
    libssl-dev qtdeclarative5-dev libcapnp-dev libtool-bin \
    libcurl4-nss-dev libpng-dev libgmp-dev \
    # x86 Libraries
    libc6:i386 libgcc1:i386 libstdc++6:i386 libtinfo5:i386 zlib1g:i386 \
    # Python 3
    python3-pip \
    # Utils
    sudo automake net-tools netcat \
    ccache make g++-multilib pkg-config coreutils rsyslog \
    manpages-dev ninja-build capnproto software-properties-common zip unzip pwgen \
    libxss1 bison flex \
    gawk cvs ncurses-dev

############################# php7run
# Install required packages
sudo apt-fast install -y libpng16-16 net-tools ca-certificates fonts-liberation libappindicator3-1 libasound2 \
    libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 \
    libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 \
    libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 \
    libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils \
    php-xdebug

# Update Apache configuration
echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf

# Configure MySQL to bind to all addresses
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Change Apache to use the prefork MPM
sudo rm -f /etc/apache2/mods-enabled/mpm_event.*
sudo rm -f /etc/apache2/mods-enabled/mpm_prefork.*
sudo ln -s /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load
sudo ln -s /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

# Copy supervisord configuration and PHP.ini
sudo cp config/supervisord.conf /etc/supervisord.conf
sudo cp config/php.ini /usr/local/lib/php.ini
sudo cp config/php.ini /etc/php/7.2/apache2/php.ini

# Enable PHP7 module in Apache
sudo ln -s /etc/apache2/mods-available/php7.load /etc/apache2/mods-enabled/
sudo ln -s /etc/apache2/mods-available/php7.conf /etc/apache2/mods-enabled/

# Enable Apache rewrite module
sudo a2enmod rewrite

# Set PHP upload and post size limits
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 10M/' /etc/php/7.2/apache2/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 10M/' /etc/php/7.2/apache2/php.ini

# Disable directory browsing in Apache
sudo sed -i 's/Indexes//g' /etc/apache2/apache2.conf
echo "DirectoryIndex index.php index.phtml index.html index.htm" | sudo tee -a /etc/apache2/apache2.conf

# Copy Apache default site configuration
sudo cp config/000-default.conf /etc/apache2/sites-available/

# Configure Xdebug
cd /xdebug
phpize
./configure --enable-xdebug
make -j $(nproc)
sudo make install

# Copy PHP files to the app directory
sudo cp config/phpinfo_test.php config/db_test.php config/cmd_test.php config/run_segfault_test.sh /app/

# Add alias for Python affinity command
sudo cp config/py_aff.alias /root/py_aff.alias
echo "source /root/py_aff.alias" | sudo tee -a /home/wc/.bashrc

# Copy the modified Dash binary
sudo cp /bin/dash /bin/saved_dash
sudo cp /crashing_dash /bin/dash

# Copy codecov_conversion.py and enable_cc.php
sudo cp config/codecov_conversion.py config/enable_cc.php /

# Start supervisord
sudo /usr/bin/supervisord -c /etc/supervisord.conf