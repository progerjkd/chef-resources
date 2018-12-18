#
# Cookbook:: def_install
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

if node['platform_family'].include?('debian')

  package ['screen', 'vim', 'rcconf', 'psmisc',\
           'ntpdate', 'gpm', 'openssh-server', 'links'] do
    action :install
  end
end

admins = data_bag('admins')

admins.each do |login|
  admin = data_bag_item('admins', login)

  user(login) do
    comment     admin['comment']
    home        admin['home']
    manage_home true
    password    admin['password']
    shell       admin['shell']
    system      true
  end
  admin['group'].each do |group|
    group(group) do
      members login
      append true
    end
  end
end
