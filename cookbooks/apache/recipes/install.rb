# Actually install the apache program

if node["platform_family"] == "debian"
	execute "apt-get update" do
		command "apt-get update"
	end
end

package_name = "apache2"

if node["platform_family"] == "redhat"
	package_name = "httpd"
end

package package_name do
	action :install
end
