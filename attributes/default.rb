# I am a proper commit!
default[:raspberry_phoronix][:set_sources] = false
default[:raspberry_phoronix][:user] = 'vagrant'
default[:raspberry_phoronix][:user_home] = "/home/#{node[:raspberry_phoronix][:user]}"
default[:raspberry_phoronix][:packages] = %w(wget unzip htop php5-cli)
default[:raspberry_phoronix][:pts_url] = 'https://github.com/phoronix-test-suite/phoronix-test-suite/archive/master.zip'
default[:raspberry_phoronix][:pts_suites] = %w(build-php)
default[:raspberry_phoronix][:pts_home] = "#{node[:raspberry_phoronix][:user_home]}/.phoronix-test-suite"
