# Class: manifoldcf
#
# This module installs and manages manifoldcf
#
# Parameters:
#
# Actions:
#
# Requires:
#   Package tomcat6
#   Module puppet-manifoldcf https://github.com/nigel-v-thomas/puppet-manifoldcf.git
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class manifoldcf (
      $source_url = $manifoldcf::params::source_url,
      $home_dir = $manifoldcf::params::home_dir,
      $package = $manifoldcf::params::package,
      $db_type = $manifoldcf::params::db_type) inherits manifoldcf::params {

  class { 
    "manifoldcf::install":
    source_url => $source_url,
    home_dir => $home_dir,
    package => $package,
  }
  
  class {
    "manifoldcf::db":
    db_type => $db_type,
    home_dir => $home_dir,
    require => Class["manifoldcf::install"]
  }

}
