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

  include manifoldcf::install
  include manifoldcf::db
}
