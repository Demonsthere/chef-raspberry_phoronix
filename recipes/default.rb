require 'mixlib/shellout'
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

execute 'Unzip the PTS' do
  command 'unzip pts.zip -d /'
  cwd '/tmp'
  action :run
end

execute 'Install the PTS' do
  command './install-sh'
  cwd '/phoronix-test-suite-master'
  action :run
end

execute 'Cleanup ' do
  command 'rm -rf /phoronix-test-suite-master'
  action :run
end

directory node[:raspberry_phoronix][:pts_home] do
  owner node[:raspberry_phoronix][:user]
  group node[:raspberry_phoronix][:user]
  mode '0755'
  action :create
end

template "#{node[:raspberry_phoronix][:pts_home]}/user-config.xml" do
  source 'user-config.xml.erb'
  owner node[:raspberry_phoronix][:user]
  group node[:raspberry_phoronix][:user]
  mode '0644'
end

execute 'Install suites' do
  command "phoronix-test-suite batch-install #{node[:raspberry_phoronix][:pts_suites].join(' ')}"
  action :run
  user node[:raspberry_phoronix][:user]
end

template "#{node[:raspberry_phoronix][:user_home]}/run_test_suite.sh" do
  source 'run_test_suite.sh.erb'
  owner node[:raspberry_phoronix][:user]
  group node[:raspberry_phoronix][:user]
  mode '0755'
  variables(test_name: 'mytestsuite')
end

ruby_block 'Run test suite' do
  block do
    user = node[:raspberry_phoronix][:user]
    home = node[:raspberry_phoronix][:user_home]
    command = "/bin/su - #{user} -c #{home}/run_test_suite.sh"
    shell = Mixlib::ShellOut.new(command, timeout: 100_000)
    shell.run_command
  end
end

execute 'Create results statistic' do
  command 'phoronix-test-suite result-file-to-csv mytestsuite > mytestsuite.txt'
  action :run
  user node[:raspberry_phoronix][:user]
  cwd node[:raspberry_phoronix][:user_home]
end

ruby_block 'Print results to screen' do
  results = "#{node[:raspberry_phoronix][:user_home]}/mytestsuite.txt"
  only_if { ::File.exist?(results) }
  block do
    print "\n"
    print File.read(results)
    print "\n"
  end
end
