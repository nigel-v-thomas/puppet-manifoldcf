class manifoldcf::db (
  $db_type = $manifoldcf::params::db_type, 
  $home_dir = $manifoldcf::params::home_dir,
  $mcf_database_name = $manifoldcf::params::mcf_database_name, 
  $mcf_database_username = $manifoldcf::params::mcf_database_username, 
  $mcf_database_password = $manifoldcf::params::mcf_database_password
  )
  inherits manifoldcf::params {

  case $db_type {
    "postgres": {
      exec { "mcf-set-permission-of-shell-files":
         command => "chmod +xX ${home_dir}/multiprocess-example-proprietary/**/*.sh",
         path => ["/bin", "/usr/bin", "/usr/sbin"],
         
      }
      #initialise the db
      exec { "initialise_postgres_db":
        environment => ["JAVA_HOME=/usr/lib/jvm/java-6-openjdk/","MCF_HOME=${home_dir}/multiprocess-example-proprietary/"],
        command => "${home_dir}/multiprocess-example-proprietary/initialize.sh",
        cwd => "${home_dir}/multiprocess-example-proprietary/",
        path => ["/bin", "/usr/bin", "/usr/sbin"],
        user => "tomcat6",
        require => [Service["postgresql"],File["${home_dir}/multiprocess-example-proprietary/properties.xml"], Exec["mcf-set-permission-of-shell-files"]],
        onlyif => "test `sudo -u postgres psql ${$mcf_database_name} -c \"\\dt\" | grep -c \"table\"` = 0", # Only run if tables do not exist
        logoutput => true
      }
    }
    default: {
      fail("The database: $operatingsystem; is not supported at present")
    }
  }
    

  
  #Install step based on http://manifoldcf.apache.org/release/release-1.0/en_US/how-to-build-and-deploy.html#Framework+and+connectors
  #Section the basic steps required to set up and run ManifoldCF in multi-process mode are as follows:
  
  file { "${home_dir}/multiprocess-example-proprietary/properties.xml":
    ensure => present,
    content => template("manifoldcf/properties.xml.erb"),
    require => [Exec["create_manifoldcf_home_dir"], Exec["unpack-manifoldcf"]],
    notify  => Service['tomcat6'],
  }
}