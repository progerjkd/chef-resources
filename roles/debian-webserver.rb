name "debian-webserver"
description "Install a webserver on Debian"
run_list "recipe[apache::install]","recipe[apache::base-files]"
