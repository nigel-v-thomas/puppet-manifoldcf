class manifoldcf::install ($source_url, $home_dir, $package) {
  $tmp_dir = "/var/tmp"
  
  # ensure home dir is setup and installed
  exec { "create_manifoldcf_home_dir":
    command => "echo 'ceating ${home_dir}' && mkdir -p ${home_dir}",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    creates => $home_dir
  }
   
  file {$home_dir:
      path    => $home_dir,
      ensure  => directory,
      owner   => tomcat6,
      mode    => 0644,
      require => [Package["tomcat6"],Exec["create_manifoldcf_home_dir"]],
  }
  
  
  # Ensure MCF_HOME is setup
  #exec { "set_environment_defaults_mcf_home":
  #  environment => ["MCF_HOME=${home_dir}"],
  #  path => ["/bin", "/usr/bin", "/usr/sbin"],
  #  require => Exec["create_manifoldcf_home_dir"],
  #  onlyif => "test `env | grep -c MCF_HOME` =  0",
  #  user => "tomcat6",
  #  logoutput => true
  #}
  
  # Ensure MCF_HOME is setup
  #exec { "set_environment_defaults_mcf_properties_path":
  #  command => ["JAVA_OPTS=\"$JAVA_OPTS -Dorg.apache.manifoldcf.configfile=/opt/york/manifoldcf/multiprocess-example-proprietary/properties.xml\""],
  #  path => ["/bin", "/usr/bin", "/usr/sbin"],
  #  require => Exec["create_manifoldcf_home_dir"],
  #  onlyif => "test `env | grep -c org.apache.manifoldcf.configfile` =  0",
  #  user => "tomcat6",
  #  logoutput => true
  #}
  
  
  # Only works in Debian or Ubuntu
  #exec { "set_environment_defaults_java_home":
  #  environment => "JAVA_HOME=$(readlink -f /usr/bin/javac | sed 's:bin/javac::')",
  #  path => ["/bin", "/usr/bin", "/usr/sbin"],
  #  user => "tomcat6",
  #  require => Exec["create_manifoldcf_home_dir"],
  #  onlyif => "test `env | grep -c JAVA_HOME` =  0",
  #  logoutput => true
  #}

  
  # TODO remove this hack
  $source = "/vagrant/manifold-cf.tgz"
  
  $manifoldcf_home_dir = "${home_dir}"
  
  # unpack manifold dist into home directory
  exec {"unpack-manifoldcf":
    command => "tar -xzf ${source} --directory ${manifoldcf_home_dir}",
    cwd => $manifoldcf_home_dir,
    creates => "$manifoldcf_home_dir/README.txt",
    require => [Package["tomcat6"], Exec["create_manifoldcf_home_dir"]],
    user => "tomcat6",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }
  
  
  # Ensure manifoldcf dist directory exist, with the appropriate privileges and copy contents of dist directory
  #file { $manifoldcf_home_dir:
  #  ensure => directory,
  #  require => [Package["tomcat6"], Exec["create_manifoldcf_home_dir"]],
  #  source => "${source}",
  #  recurse => true,
  #  group   => "tomcat6",
  #  owner   => "tomcat6",
  #  purge   => true,
  #  force   => true,
  #}
  
  # setup postgres server, based on http://manifoldcf.apache.org/release/release-1.0/en_US/how-to-build-and-deploy.html#Configuring+the+PostgreSQL+database
  class { 'postgresql::server':
    version => '8.4',
    standard_conforming_strings => 'on',
    #TODO need to fix error with this.. for now using defaults
    #shared_buffers => '1024MB',
    checkpoint_segments => 300,
    maintenanceworkmem => '2MB',
    tcpip_socket => true,
    max_connections => 400,
    checkpoint_timeout => '900s',
    datestyle => 'ISO,European',
    autovacuum => off,
    require => Exec["unpack-manifoldcf"]
  }
  
  # TODO temporary account - remove
  #postgresql::db { 'vagrant':
  #    password => 'vagrant',
  #    require => Class['postgresql::server']
  #}
    
  $mcf_database_name = "mcfdatabase"
  $mcf_database_username = "manifoldcf"
  $mcf_database_password = "local_pg_password"
  
  postgresql::db { $mcf_database_name:
      owner    => $mcf_database_username,
      password => $mcf_database_password,
      before => Exec["initialise_postgres_db"]
  }
  
  #initialise the db
  exec { "initialise_postgres_db":
    environment => ["JAVA_HOME=/usr/lib/jvm/java-6-openjdk/","MCF_HOME=${home_dir}/multiprocess-example-proprietary/"],
    command => "${home_dir}/multiprocess-example-proprietary/initialize.sh",
    cwd => "${home_dir}/multiprocess-example-proprietary/",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    user => "tomcat6",
    require => [Service["postgresql"],File["${home_dir}/multiprocess-example-proprietary/properties.xml"]],
    onlyif => "test `sudo -u postgres psql ${$mcf_database_name} -c \"\\dt\" | grep -c \"table\"` = 0", # Only run if tables do not exist
    logoutput => true
  }
  
  #Install step based on http://manifoldcf.apache.org/release/release-1.0/en_US/how-to-build-and-deploy.html#Framework+and+connectors
  #Section the basic steps required to set up and run ManifoldCF in multi-process mode are as follows:
  
  file { "${home_dir}/multiprocess-example-proprietary/properties.xml":
    ensure => present,
    content => template("manifoldcf/properties.xml.erb"),
    require => Exec["unpack-manifoldcf"],
    notify  => Service['tomcat6'],
  }
  
  $mcf_api_service_dir = "${home_dir}/web-proprietary/war/mcf-api-service.war"
  
  file { "/etc/tomcat6/Catalina/localhost/mcf-api-service.xml":
    ensure => present,
    content => template("manifoldcf/mcf-api-service.xml.erb"),
    require => [Package["tomcat6"],Exec["initialise_postgres_db"]],
    notify  => Service['tomcat6'],
  }
  
  $mcf_authority_service_dir = "${home_dir}/web-proprietary/war/mcf-authority-service.war"
  
  file { "/etc/tomcat6/Catalina/localhost/mcf-authority-service.xml":
    ensure => present,
    content => template("manifoldcf/mcf-authority-service.xml.erb"),
    require => [Package["tomcat6"],Exec["initialise_postgres_db"]],
    notify  => Service['tomcat6'],
  }
  
  $mcf_crawler_ui_dir = "${home_dir}/web-proprietary/war/mcf-crawler-ui.war"
  
  file { "/etc/tomcat6/Catalina/localhost/mcf-crawler-ui.xml":
    ensure => present,
    content => template("manifoldcf/mcf-crawler-ui.xml.erb"),
    require => [Package["tomcat6"],Exec["initialise_postgres_db"]],
    notify  => Service['tomcat6'],
  }
  
}