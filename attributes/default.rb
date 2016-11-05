default[:raspberry_phoronix][:set_sources] = false
default[:raspberry_phoronix][:user] = 'vagrant'
default[:raspberry_phoronix][:packages] = %w(wget unzip php5-cli php-fpdf htop)
default[:raspberry_phoronix][:pts_url] = 'https://github.com/phoronix-test-suite/phoronix-test-suite/archive/master.zip'
default[:raspberry_phoronix][:pts_suites] = %w(build-php build-apache)
default[:raspberry_phoronix][:pts_home] = "/home/#{node[:raspberry_phoronix][:user]}/.phoronix-test-suite"
