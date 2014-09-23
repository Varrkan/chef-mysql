#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'java'
include_recipe 'ark'
tomcat = node['tomcat']

url_prefix = 'tomcat-' + tomcat['version'].split('.')[0] + '/v' + 
  tomcat['version'] + '/bin/'
tomcat_tar = 'apache-tomcat-' + tomcat['version'] + '.tar.gz'

src = URI.join(tomcat['url_base'], url_prefix, tomcat_tar).to_s

dest = File.join(tomcat['home'], 'tomcat')

log src

directory '/data' do
  owner 'root'
  group 'root'
  mode 0755
end

group tomcat['group'] do
  system true
  gid tomcat['gid']
end

user tomcat['user'] do
  comment 'Apache Tomcat'
  gid tomcat['gid']
  home tomcat['home']
  shell '/sbin/nologin'
  supports :manage_home => true
  system true
  uid tomcat['uid']
end

ark 'tomcat' do
  url src
  version tomcat['version']
  path tomcat['home']
  owner tomcat['user']
  group tomcat['group']
  action :put
end

%w(conf logs temp webapps work).each do |dir|
  link "#{tomcat['home']}/#{dir}" do
    owner tomcat['user']
    group tomcat['group']
    to File.join(dest, dir)
  end
end

template '/etc/init.d/tomcat' do
  source 'tomcat.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables(
    :binhome => File.join(tomcat['home'], 'tomcat'),
    :tomcat_user => tomcat['user'],
    :x => tomcat['X'],
    :xx => tomcat['XX']
  )
end

template "#{tomcat['home']}/tomcat/conf/server.xml" do
  only_if { not node['tomcat']['disabled'] }
  source "server.xml.erb"
  owner tomcat['user']
  group tomcat['group']
  mode 0644
  variables(
    :port => tomcat['port']
  )
end

execute 'wait for tomcat' do
  command 'sleep 5'
  action :nothing
end

service 'tomcat' do 
  only_if { not node['tomcat']['disabled'] }
  action [:start, :enable]
  supports :restart => true, :status => true
  notifies :run, 'execute[wait for tomcat]', :immediately
  subscribes :restart, "template[#{tomcat['home']}/tomcat/conf/server.xml]", :delayed
end

ark 'ROOT.WAR' do
  url 'https://github.com/rightscale/examples/blob/unified_tomcat/ROOT.war?raw=true'
  path "data/tomcat/webapps"
  owner tomcat['user']
  group tomcat['group']
  action :put
end

ark 'mysql-connector-java' do
   url 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.32.zip'
      creates 'mysql-connector-java-5.1.32-bin.jar'
         path '/data/tomcat/lib'
            action :cherry_pick
             end
             
             cookbook_file "/root/mtn" do
               source "maintenance.html"
                 mode '0755'
                   owner 'apache'
                     group 'apache'
                     end
             
             cookbook_file "/data/tomcat/conf" do
               source "context.xml"
                 mode '0755'
                   owner 'tomcat'
                     group 'tomcat'
                     end