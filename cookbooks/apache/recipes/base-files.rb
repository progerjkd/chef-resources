# Add the file for apache to serve

template "/var/www/html/index.html" do
	source "index.html.erb"
	mode "0644"
end
