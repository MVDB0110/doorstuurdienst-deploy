#!/bin/bash

#
# Variables
#
environment=/etc/puppetlabs/code/environments/production
folder=/home/mvandenbrink/Puppet/production

#
# Install manifests in production environment
#
/bin/cp -f $folder/manifests/init.pp $environment/manifests/
/bin/cp -rf $folder/modules/forward $environment/modules/
/bin/cp -f $folder/hiera.yaml $environment
