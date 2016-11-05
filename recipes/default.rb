#
# Cookbook Name:: raspberry_phoronix
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
cookbook_file '/etc/apt/sources.list' do
  source 'sources.list'
  owner 'root'
  group 'root'
  mode '0644'
  only_if { node[:raspberry_phoronix][:set_sources] == true }
end

cookbook_file '/etc/apt/apt.conf.d/42-auth_allow' do
  source '42-auth_allow'
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'do a system update' do
  command 'apt-get update --fix-missing'
  action :run
end

node[:raspberry_phoronix][:packages].each do |pkg|
  apt_package pkg
end

remote_file '/tmp/pts.zip' do
  mode '0644'
  source node[:raspberry_phoronix][:pts_url]
end

execute 'Unpack the PTS' do
  command 'unzip /tmp/pts.zip -d /'
  action :run
end

execute 'Install the PTS' do
  command './install-sh'
  cwd '/phoronix-test-suite-master'
  action :run
end

# template '/etc/phoronix-test-suite.xml' do
#   source 'phoronix-test-suite.xml.erb'
#   owner 'root'
#   group 'root'
#   mode '0644'
# end

node[:raspberry_phoronix][:pts_suites].each do |suite|
  execute "Install #{suite}" do
    command "phoronix-test-suite install #{suite}"
    action :run
    user 'vagrant'
  end

  template "/home/vagrant/run_test_#{suite}" do
    source 'run_test_suite.sh.erb'
    owner 'vagrant'
    mode '0755'
    variables(
      :test_suite => suite,
      :test_name => suite,
      :test_description => 'DUPA'
      )
  end
  
  # execute "Run test: #{suite}" do
  #   command "./run_test_#{suite}"
  #   action :run
  # end
end
