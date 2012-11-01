# This is the generic solr parameters
class manifoldcf::params {
  case $operatingsystem {
    /(Ubuntu|Debian)/: {
      $source_url = "http://mirror.ox.ac.uk/sites/rsync.apache.org/manifoldcf/apache-manifoldcf-1.0-src.tar.gz"
      $home_dir = "/usr/share/manifoldcf"
      $package = "apache-manifoldcf-1.0.1"
      $db_type = "postgres"
      $mcf_database_name = "mcfdatabase"
      $mcf_database_username = "manifoldcf"
      $mcf_database_password = "local_pg_password"
      $mcf_synchdirectory = "/var/lib/manifoldcf/syncharea"
    }
    default: {
      fail("Operating system, $operatingsystem, is not supported by the tomcat module")
    }
  }
}
