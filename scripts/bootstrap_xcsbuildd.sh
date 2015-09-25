#!/bin/bash

# run this once on a newly reset xcode server

# switch to sudo mode
sudo -s

# set the new shell of _xcsbuildd
dscl localhost -change /Local/Default/Users/_xcsbuildd UserShell /bin/false /bin/bash

# login as _xcsbuildd
sudo su - _xcsbuildd

# install proper ruby distribution
\curl -sSL https://get.rvm.io | bash -s stable
. ~/.profile
rvm autolibs read-only
rvm install ruby

# install fastlane and cocoapods
gem install fastlane
gem install cocoapods
