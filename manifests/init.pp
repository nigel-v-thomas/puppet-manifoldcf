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
#   Module puppet-postgresql https://github.com/nigel-v-thomas/puppet-postgresql.git
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class manifoldcf (
      $source_url="http://mirror.ox.ac.uk/sites/rsync.apache.org/manifoldcf/apache-manifoldcf-1.0-src.tar.gz",
      $home_dir="/usr/share/manifoldcf",
      $package="apache-manifoldcf-1.0") {

  class { 
    "manifoldcf::install":
    source_url => $source_url,
    home_dir => $home_dir,
    package => $package,
  }

}
