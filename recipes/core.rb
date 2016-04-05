#
# Cookbook Name:: stackstorm
# Recipe:: core
#
# Copyright 2016, Movile.com
#
# All rights reserved - Do Not Redistribute
#
# Install core packages for stackstorm

yum_repository 'st2' do
  description "StackStorm_staging-stable"
  baseurl "https://packagecloud.io/StackStorm/staging-stable/el/6/$basearch"
  gpgkey 'https://packagecloud.io/StackStorm/staging-stable/gpgkey'
  gpgcheck false
  action :create
end

package 'st2' do
  action :install
end

package 'st2mistral' do
  action :install
end

cookbook_file '/tmp/create-mistral-db.sh' do
  source 'create-mistral-db.sh'
  owner 'postgres'
  group 'postgres'
  mode '0755'
  only_if { !File.exists?("/etc/mistral/database_setup.lock") }
end

execute 'create-mistral-db' do
  command '/tmp/create-mistral-db.sh'
  user 'postgres'
  action :run
  only_if { !File.exists?("/etc/mistral/database_setup.lock") }
end

execute 'create-mistral-db-schema' do
  command '/opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf upgrade head'
  action :run
  only_if { !File.exists?("/etc/mistral/database_setup.lock") }
end

execute 'populate-mistral-db-schema' do
  command '/opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf populate'
  action :run
  only_if { !File.exists?("/etc/mistral/database_setup.lock") }
end

execute 'mistral-post-db-cleanup' do
  command 'touch /etc/mistral/database_setup.lock && rm /tmp/create-mistral-db.sh'
  creates '/etc/mistral/database_setup.lock'
  action :run
end

# need to replace st2auth init script to work with PAM auth backend
cookbook_file '/etc/init.d/st2auth' do
  source 'st2auth-init'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/st2/st2.conf' do
  source 'st2.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

st2_services = [
    "st2actionrunner",
    "st2api",
    "st2auth",
    "st2garbagecollector",
    "st2notifier",
    "st2resultstracker",
    "st2rulesengine",
    "st2sensorcontainer",
    "mistral-server",
    "mistral-api"]

execute 'st2-register-items' do
  command 'st2ctl reload --register-all'
  action :nothing
end

for svc in st2_services do
    service svc do
      supports :status => true, :restart => true, :reload => true
      action [:start, :enable]
      notifies :run, 'execute[st2-register-items]'
    end
end
