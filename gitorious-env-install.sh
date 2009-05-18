#!/bin/bash
#Gitorious enviroment installation script for Ubuntu
#Developed by Marcelo Murad - email at marcelomurad dot com
#You can redistribute it and/or modify it under either the terms of the GPL (http://www.gnu.org/licenses/gpl-3.0.txt)

MYSQL_PASS="mysql_password"
GITORIOUS_HOST="git.yourdomain.com"

if [ "$(whoami)" != "root" ]; then
echo "You need to be root to run this!"
  exit 2
fi

apt-get install -y librmagick-ruby libonig-dev libbluecloth-ruby libopenssl-ruby1.8 rubygems1.8 ruby1.8-dev

gem install textpow mime-types --no-ri --no-rdoc

gem install chronic --no-ri --no-rdoc
gem install ruby-openid --no-ri --no-rdoc

gem install ruby-yadis --no-ri --no-rdoc

apt-get install -y git-core

apt-get install -y aspell libaspell-dev aspell-en

apt-get install -y sendmail

adduser git --system --disabled-password

apt-get install -y libmagick9-dev

sudo apt-get install -y rake

sudo gem install rack --no-ri --no-rdoc


if [ -d /srv ]
then
   cd /srv
else
  mkdir /srv
  cd /srv
fi

git clone git://gitorious.org/gitorious/mainline.git  gitorious

mkdir git_repositories

chown git:www-data git_repositories

chown -R git:www-data gitorious

cd gitorious

sed "s/ssssht/$(rake -s secret)/" config/gitorious.sample.yml >> config/gitorious.yml

#nano config/gitorious.yml
#repository_base_path: "/srv/git_repositories"
#gitorious_host: git.livingnet.com.br
sed 's/repository_base_path/#repository_base_path/' -i config/gitorious.yml
sed 's/gitorious_host/#gitorious_host/' -i config/gitorious.yml
sed 's/gitorious_client_port/#gitorious_client_port/' -i config/gitorious.yml
sed 's/gitorious_client_host/#gitorious_client_host/' -i config/gitorious.yml
#locale: enrepository_base_path: /srv/git_repositories
echo '===jabuti==='
echo '' >> config/gitorious.yml
echo '===jabuti==='
echo 'repository_base_path: /srv/git_repositories' >> config/gitorious.yml
echo "gitorious_host: $GITORIOUS_HOST" >> config/gitorious.yml
echo 'gitorious_client_port: 80' >> config/gitorious.yml
echo "gitorious_client_host: $GITORIOUS_HOST" >> config/gitorious.yml



gem install hoe --no-ri --no-rdoc
###ruby script
###hoe_line=`gem list | grep ^hoe`
###hoe_line.chomp!
###hoe_line = hoe_line.sub(/hoe.\(/,'').strip.sub(/\)/,'')
###arr_hoe_versions = hoe_line.split(', ')
###arr_hoe_versions.delete('1.8.2')
###arr_hoe_versions.each{|d| `/usr/bin/gem uninstall hoe -v#{d}`}


gem install geoip --no-ri --no-rdoc
gem install daemons --no-ri --no-rdoc
gem install rspec-rails --no-ri --no-rdoc
gem install echoe --no-ri --no-rdoc
gem install RedCloth --no-ri --no-rdoc
gem install rdiscount --no-ri --no-rdoc
gem install rmagick --no-ri --no-rdoc

gem install diff-lcs --no-ri --no-rdoc

apt-get install -y mysql-server

echo "CREATE DATABASE \`gitorious\` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;" > temp.mysql
mysql -uroot -p$MYSQL_PASS < temp.mysql
rm temp.mysql





echo "production:
  adapter: mysql
  database: gitorious
  username: root
  password: $MYSQL_PASS
  host: localhost
  encoding: utf8" > config/database.yml

chown git:www-data config/database.yml


RAILS_ENV=production rake db:migrate

ln -s /srv/gitorious/script/gitorious /bin/gitorious

RAILS_ENV=production rake ultrasphinx:configure

gem install raspell --no-ri --no-rdoc
cp vendor/plugins/ultrasphinx/examples/ap.multi /usr/lib/aspell/

mkdir db/sphinx
touch db/sphinx/ap-stopwords.txt
RAILS_ENV=production rake ultrasphinx:spelling:build

touch log/gitorious_auth.log
touch log/production.log
touch log/tasks.log

chown -Rf git:www-data log/

echo "NameVirtualHost *
<VirtualHost *>
    ServerName $GITORIOUS_HOST
    DocumentRoot /srv/gitorious/public
</VirtualHost>" >> $GITORIOUS_HOST

mv $GITORIOUS_HOST /etc/apache2/sites-available
a2ensite $GITORIOUS_HOST

/etc/init.d/apache2 reload


mkdir /home/git/.ssh
chmod 700 /home/git/.ssh
chown git:nogroup /home/git/.ssh
touch /home/git/.ssh/authorized_keys
chmod 640 /home/git/.ssh/authorized_keys
chown git:nogroup /home/git/.ssh/authorized_keys

echo "*/1 * * * * /srv/gitorious/script/task_performer" > /var/spool/cron/crontabs/git
chown git:crontab /var/spool/cron/crontabs/git
chmod 600 /var/spool/cron/crontabs/git

usermod -s/bin/bash git

echo "=================================================="
echo "All set now you can access $GITORIOUS_HOST"
echo "and create your user"
echo "=================================================="

