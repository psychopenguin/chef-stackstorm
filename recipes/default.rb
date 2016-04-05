#
# Cookbook Name:: stackstorm
# Recipe:: default
#
# Copyright 2016, Movile.com
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'stackstorm::dependencies'
include_recipe 'stackstorm::core'
include_recipe 'stackstorm::webui'
include_recipe 'stackstorm::chatops'
