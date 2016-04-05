#
# Cookbook Name:: stackstorm
# Recipe:: chatops
#
# Copyright 2016, Movile.com
#
# All rights reserved - Do Not Redistribute
#
require 'digest/sha2'

yum_repository 'nodejs4' do
  description "Node.js Packages for Enterprise Linux 6 - $basearch"
  baseurl "https://rpm.nodesource.com/pub_4.x/el/6/$basearch"
  gpgcheck false
  action :create
end

package 'nodejs' do
  action :install
end

package 'st2chatops' do
  action :install
end

# Generate system user for chatops

user node['stackstorm']['chatops']['user'] do
  action :create
  comment 'User for ST2 chatops'
  gid 'st2'
  home '/tmp'
  shell '/bin/false'
  password node['stackstorm']['chatops']['password'].crypt("$6$" + rand(36**8).to_s(36))
end

template '/opt/stackstorm/chatops/st2chatops.env' do
  source 'st2chatops.env.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

service 'st2chatops' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end

execute 'st2-register-aliases' do
  command 'st2ctl reload --register-aliases'
  action :run
  notifies :reload, 'service[st2chatops]'
end
