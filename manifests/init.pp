# Class: manifoldcf
#
# This module installs and manages manifoldcf
# Module puppet-manifoldcf https://github.com/nigel-v-thomas/puppet-manifoldcf.git
# Parameters:
#
# Actions:
#
# Requires:
#   Package tomcat6
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class manifoldcf (
      $source_url = $manifoldcf::params::source_url,
      $home_dir = $manifoldcf::params::home_dir,
      $package = $manifoldcf::params::package,
      $db_type = $manifoldcf::params::db_type,
      $mcf_mysql_server = $manifoldcf::params::mcf_mysql_server,
      $mcf_database_name = $manifoldcf::params::mcf_database_name, 
      $mcf_database_username = $manifoldcf::params::mcf_database_username, 
      $mcf_database_password = $manifoldcf::params::mcf_database_password) inherits manifoldcf::params {

  package {"openjdk-6-jdk":
    ensure => present,
    before => Class["manifoldcf::install"]
  }  
  package {"tomcat6":
    ensure => present,
    before => Class["manifoldcf::install"]
  }
  
  service{ "tomcat6":
    ensure => running,
    require => Package["tomcat6"]
  }

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
    mcf_mysql_server => $mcf_mysql_server,
    mcf_database_name => $mcf_database_name, 
    mcf_database_username => $mcf_database_username, 
    mcf_database_password => $mcf_database_password,
    require => Class["manifoldcf::install"]
  }
  
  class {
    "manifoldcf::service":
    home_dir => $home_dir,
    require => Class["manifoldcf::db"]
  }

}
