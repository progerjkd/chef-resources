name "centos-webserver"
description "Install a webserver on CentOS"
run_list "recipe[apache::install]","recipe[apache::base-files]"
