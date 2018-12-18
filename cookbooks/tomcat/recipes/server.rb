#
# Cookbook:: tomcat
# Recipe:: server
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package 'java-1.7.0-openjdk-devel'

user 'tomcat' do
  shell '/bin/bash'
end

group 'tomcat' do
  members 'tomcat'
  append  true
end

src_filename = 'apache-tomcat-8.0.47.tar.gz'
src_url="https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.47/bin/#{src_filename}"
src_filepath = '/tmp'
extract_path = '/opt/tomcat'
tomcat_port = 5090

remote_file "#{src_filepath}/#{src_filename}" do
  source "#{src_url}"
  not_if { ::File.exist?("#{src_filepath}/#{src_filename}") }
end

bash 'extract_module' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    mkdir -p #{extract_path}
    tar zxf #{src_filepath}/#{src_filename} -C #{extract_path} --strip-components=1
    EOH
  not_if { ::File.exist?(extract_path) }
end

remote_file '/tmp/sample.war' do
  source 'https://github.com/johnfitzpatrick/certification-workshops/blob/master/Tomcat/sample.war'
  not_if { ::File.exist?('/tmp/sample.war') }
end

execute 'fix-perms' do
  command "chgrp -R tomcat /opt/tomcat/conf && \
  chmod g+rwx /opt/tomcat/conf && \
  chmod g+r /opt/tomcat/conf/* && \
  chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/"
end

template '/etc/systemd/system/tomcat.service' do
    source 'tomcat.service.erb'
    notifies :restart, 'service[tomcat]'
end

template '/opt/tomcat/conf/server.xml' do
    source 'server.xml.erb'
    variables(
      'tomcat_port': tomcat_port
    )
    owner 'root'
    group 'tomcat'
    mode  '0640'
    notifies :restart, 'service[tomcat]'
end

directory ['/opt/tomcat/webapps/', '/opt/tomcat/work/', '/opt/tomcat/temp/', '/opt/tomcat/logs'] do
  owner 'tomcat'
  recursive true
end

execute 'daemon-reload' do
  command 'systemctl daemon-reload'
end

service 'tomcat' do
    action [ :enable, :start ]
end
