#
# Cookbook:: users
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.


user 'chef' do
  password '$6$7NqaS6oTYdX$Ym6q2m7dbN2i7mMFJPCE7CQj/IHtRR2naozNYNU.FpDPX6DX66fcaN.0If0TV4lWXFJ1OGSH7TmWt48LAKo8I/'
end


template '/etc/ssh/sshd_config' do
  source 'sshd_config.erb'
  variables(
    'password_authentication': 'yes'
  )
  notifies :restart, 'service[sshd]'
end

service 'sshd' do
  action [:enable, :start]
end
