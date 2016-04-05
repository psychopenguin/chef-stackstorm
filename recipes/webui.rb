#
# Cookbook Name:: stackstorm
# Recipe:: webui
#
# Copyright 2016, Movile.com
#
# All rights reserved - Do Not Redistribute
#
# Install webui components for stackstorm

package 'nginx' do
  action :install
end

package 'st2web' do
  action :install
end

template '/opt/stackstorm/static/webui/config.js' do
  source 'config.js.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/nginx/conf.d/default.conf' do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

directory '/etc/ssl/st2' do
  owner 'nginx'
  group 'nginx'
  mode '0755'
  action :create
end

execute 'generate-self-signed-certs' do
  command 'openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/st2/st2.key -out /etc/ssl/st2/st2.crt -days 365 -nodes -subj "/C=US/ST=California/L=Palo Alto/O=StackStorm/OU=Information Technology/CN=$(hostname)"'
  creates '/etc/ssl/st2/st2.key'
  only_if {node['stackstorm']['self-signed-certs'] == true}
  action :run
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
