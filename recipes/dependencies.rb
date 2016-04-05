#
# Cookbook Name:: stackstorm
# Recipe:: dependencies
#
# Copyright 2016, Movile.com
#
# All rights reserved - Do Not Redistribute
#
# Install dependencies package for stackstorm

# Activate epel-repo
include_recipe 'yum-epel'

# libffi-devel
package 'libffi-devel' do
  action :install
end

# yum-utils
package 'yum-utils' do
  action :install
end

# mongodb

package 'mongodb-server' do
  action :install
end

service 'mongod' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end

# rabbitmq

package 'rabbitmq-server' do
  action :install
end

service 'rabbitmq-server' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end

# PostgreSQL9.4

yum_repository 'pgdg94' do
  description "PostgreSQL 9.4 $releasever - $basearch"
  baseurl "https://download.postgresql.org/pub/repos/yum/9.4/redhat/rhel-$releasever-$basearch"
  gpgkey 'https://download.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG-94'
  action :create
end

pg94_pkgs = ['postgresql94-server',
             'postgresql94-contrib',
             'postgresql94-devel']

for pkg in pg94_pkgs do
    package pkg do
      action :install
    end
end

execute 'pg-initdb' do
  command 'service postgresql-9.4 initdb'
  action :run
  only_if { !File.exists?("/var/lib/pgsql/9.4/data/PG_VERSION") }
end

cookbook_file '/var/lib/pgsql/9.4/data/pg_hba.conf' do
  source 'pg_hba.conf'
  owner 'postgres'
  group 'postgres'
  mode '0600'
end

service 'postgresql-9.4' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end

cookbook_file '/var/lib/pgsql/9.4/data/pg_hba.conf' do
  source 'pg_hba.conf'
  owner 'postgres'
  group 'postgres'
  mode '0600'
  notifies :restart, 'service[postgresql-9.4]'
end
