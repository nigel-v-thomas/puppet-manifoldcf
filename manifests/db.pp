class manifoldcf::db (
  $db_type = $manifoldcf::params::db_type, 
  $home_dir = $manifoldcf::params::home_dir,
  $mcf_database_name = $manifoldcf::params::mcf_database_name, 
  $mcf_database_username = $manifoldcf::params::mcf_database_username, 
  $mcf_database_password = $manifoldcf::params::mcf_database_password,
  $mcf_mysql_server = $manifoldcf::params::mcf_mysql_server,
  )
  inherits manifoldcf::params {

  exec { "mcf-set-permission-of-shell-files":
     command => "find ${home_dir}/multiprocess-example-proprietary/ -name \\*.sh | xargs chmod +xX -v",
     path => ["/bin", "/usr/bin", "/usr/sbin"],
     before => Exec["initialise_mcf_db"],
  }
  
  manifoldcf::setup_script_env { "${home_dir}/multiprocess-example-proprietary/initialize-env-setup.sh":
       home_dir => $home_dir,
       full_path_script_to_run => "${home_dir}/multiprocess-example-proprietary/initialize.sh",
       before => Exec["initialise_mcf_db"],
  }
  
  notice("Running intialise as ${db_type}")
  case $db_type {
    "postgres": {
      #initialise the db
      exec { "initialise_mcf_db":
        #environment => ["JAVA_HOME=/usr/lib/jvm/java-6-openjdk/","MCF_HOME=${home_dir}/multiprocess-example-proprietary/"],
        command => "sudo -u tomcat6 ${home_dir}/multiprocess-example-proprietary/initialize-env-setup.sh",
        cwd => "${home_dir}/multiprocess-example-proprietary/",
        path => ["/bin", "/usr/bin", "/usr/sbin"],
        require => [Service["postgresql"],File["${home_dir}/multiprocess-example-proprietary/properties.xml"], Exec["mcf-set-permission-of-shell-files"]],
        onlyif => "test `sudo -u postgres psql ${mcf_database_name} -c \"\\dt\" | grep -c \"table\"` = 0", # Only run if tables do not exist
        logoutput => true
      }
    }
    "mysql" :{
        if $mcf_mysql_server == "" {
          fail ("mcf_mysql_server parameter required and not set")
        }
      #initialise the db
      exec { "initialise_mcf_db":
        environment => ["JAVA_HOME=/usr/lib/jvm/java-6-openjdk/","MCF_HOME=${home_dir}/multiprocess-example-proprietary/"],
        command => "${home_dir}/multiprocess-example-proprietary/initialize.sh",
        cwd => "${home_dir}/multiprocess-example-proprietary/",
        path => ["/bin", "/usr/bin", "/usr/sbin"],
        user => "tomcat6",
        require => [File["${home_dir}/multiprocess-example-proprietary/properties.xml"], Exec["mcf-set-permission-of-shell-files"]],
        logoutput => true
      }
    }
    default: {
      fail("The database: $operatingsystem; is not supported at present")
    }
  }


  #Install step based on http://manifoldcf.apache.org/release/release-1.0.1/en_US/how-to-build-and-deploy.html#Framework+and+connectors
  #Section the basic steps required to set up and run ManifoldCF in multi-process mode are as follows:
  
  file { "${home_dir}/multiprocess-example-proprietary/properties.xml":
    ensure => present,
    content => template("manifoldcf/properties.xml.erb"),
    require => [Exec["create_manifoldcf_home_dir"], Exec["unpack-manifoldcf"]],
    notify  => Service['tomcat6'],
  }
}