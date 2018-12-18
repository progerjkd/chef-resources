#
# Cookbook:: webserver_test
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'spec_helper'

shared_examples 'webserver_test' do |platform, version, package, service|
  context 'when run on #{platform} #{version}' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.4.1708')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs #{package}' do
      expect(chef_run).to install_package package
    end

    it 'enables the ${package} service' do
      expect(chef_run).to enable_service package
    end

    it 'starts the #{service} service' do
      expect(chef_run).to start_service service
    end
  end
end

describe 'webserver_test::default' do
  platforms = {
    'centos' => ['7.4.1708', 'httpd', 'httpd'],
    'ubuntu' => ['16.04', 'apache2', 'apache2']
  }

  platforms.each do |platform, platform_data|
    include_examples 'webserver_test', platform, *platform_data
  end
end
