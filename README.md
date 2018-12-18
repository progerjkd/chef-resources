
# Test Kitchen

![enter image description here](https://learn.chef.io/assets/images/misc/local_dev_workflow-5f56acb8.png)

## 1.  Edit Test Kichen configuration file
   When you use the `chef generate cookbook` command to create a cookbook, Chef creates a file named `.kitchen.yml` in the root directory of your cookbook. `.kitchen.yml` defines what's needed to run Test Kitchen, including which virtualization provider to use, how to run Chef, and what platforms to run your code on.

## 2. Create the Test Kitchen instance
    kitchen list
    kitchen create

## 3. Converge the instance

    enter code here

Test Kitchen runs `chef-client` on the instance. When the `chef-client` run completes successfully, Test Kitchen exits with exit code `0`. Run the following to check the exit code.

    $ echo $?
      0

 ## 4. Verify that your Test Kitchen instance is configured as expected

    # login into test environment
    kitchen login
    # or just exec a command
    kitchen exec -c 'curl localhost'


## 6. Delete the Test Kitchen instance

    kitchen destroy
  
 
# Inspec

Test driven development and integration testing.
You can follow the test-driven approach by first writing a test, watching it fail, and then writing just enough code to make it pass.

The file `<cookbook_name>/tests/integration/default/default_test.rb` is the default file for the default recipe of a given cookbook.
The format of an InSpec test resembles natural language:

    describe package('httpd') do
      it { should be_installed }
    end
    
    describe service('httpd') do
      it { should be_enabled }
      it { should be_running }
    end
    
    describe command('curl localhost') do
      its('stdout') { should match /hello/ }
    end
    
    describe port(80) do
      it { should be_listening }
    end

You should expect the test to fail because you have not yet written any code to install the package. Having a failing test shows what functionality is missing and gives you a clear goal to work towards. You also now have a way to quickly get feedback on whether the changes you make bring you closer to your goal.
Write just enough code to make the remaining tests pass and perform rounds of these commands:

    kitchen verify
    kitchen converge
    kitchen verify

Run `kitchen list`. You'll see in the `Last Action` column that the instance's state is `Verified`, which means that Test Kitchen's most recent action was to run the tests and the tests passed successfully.

 

    $ kitchen  list
    Instance          Driver   Provisioner  Verifier  Transport  Last Action  Last Error
    default-centos-7  Vagrant  ChefZero     Inspec    Ssh        Verified     <None>

 
As you experiment and correct mistakes, it's a good practice to apply your configuration and run your tests one final time on a clean instance to ensure that the process is repeatable and isn't the result of any experimentation or intermediate steps you performed along the way.
You can run the `kitchen test` command to create, converge, verify, and destroy your instance all in one step.

    kitchen test

# ChefSpec
Unit testing. ChefSpec speed up the feedback cycle even more by simulating the execution of your resources in memory without the need to create test instances.

For ChefSpec, tests go in your cookbook's `spec` directory. The `chef generate cookbook` command creates this directory for you.
While InSpec uses what's commonly called *should* syntax, ChefSpec uses the *expectation* syntax.

    require 'spec_helper'
    
    describe 'webserver_test::default' do
      let(:chef_run) do
        runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.4.1708')
        runner.converge(described_recipe)
      end
    
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
    
      it 'installs httpd' do
        expect(chef_run).to install_package 'httpd'
      end
    
      it 'enables the httpd service' do
        expect(chef_run).to enable_service 'httpd'
      end
    
      it 'starts the httpd service' do
        expect(chef_run).to start_service 'httpd'
      end
    end

Now run this command to run your tests. The chef exec part ensures that `rspec` is run using Chef's domain-specific language. The `--color` part is optional, but can help you visually distinguish passing from failing tests.

    chef exec rspec --color spec/unit/recipes/default_spec.rb
    ....
    Finished in 0.65681 seconds (files took 1.73 seconds to load)
    4 examples, 0 failures


## Write multiplatform tests

    require 'spec_helper'
    
    describe 'webserver_test::default' do
      context 'when run on CentOS 7.3.1611' do
        let(:chef_run) do
          runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.3.1611')
          runner.converge(described_recipe)
        end
    
        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end
    
        it 'installs httpd' do
          expect(chef_run).to install_package 'httpd'
        end
    
        it 'enables the httpd service' do
          expect(chef_run).to enable_service 'httpd'
        end
    
        it 'starts the httpd service' do
          expect(chef_run).to start_service 'httpd'
        end
      end
    
      context 'when run on Ubuntu 14.04' do
        let(:chef_run) do
          runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04')
          runner.converge(described_recipe)
        end
    
        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end
    
        it 'installs apache2' do
          expect(chef_run).to install_package 'apache2'
        end
    
        it 'enables the apache2 service' do
          expect(chef_run).to enable_service 'apache2'
        end
    
        it 'starts the apache2 service' do
          expect(chef_run).to start_service 'apache2'
        end
      end
    end

# Verify code style
**Cookstyle** and **Foodcritic** help to ensure that your code adheres to standard style guidelines and avoids common problems.

