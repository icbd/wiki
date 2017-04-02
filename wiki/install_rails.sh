echo "update apt-get\n"
sudo apt-get update
sudo apt-get install -y curl


echo "install base software\n"
sudo apt-get install -y software-properties-common wget unzip vim build-essential openssl libreadline6 libreadline6-dev libsqlite3-dev libmysqlclient-dev libpq-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf automake cmake libtool imagemagick libmagickwand-dev libpcre3-dev language-pack-zh-hans libevent-dev libgmp-dev libgmp3-dev redis-tools nodejs htop


echo "install RVM\n"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source /home/rvm/.rvm/scripts/rvm
rvm -v
rvm list


echo "install ruby"
rvm requirements
rvm install 2.3.4
rvm use 2.3.4 --default
ruby -v


echo "use ruby-china's mirrors\n"
gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
gem sources -l

echo "install bundler\n"
gem install bundler
bundle -v


echo "install rails\n"
gem install rails
rails -v
