class manifoldcf::install (
  $source_url = $manifoldcf::params::source_url, 
  $home_dir = $manifoldcf::params::home_dir, 
  $package = $manifoldcf::params::package,
  $mcf_synchdirectory = $manifoldcf::params::mcf_synchdirectory
  ) inherits manifoldcf::params {
  $tmp_dir = "/var/tmp"
  
  # ensure home dir is setup and installed
  exec { "create_manifoldcf_home_dir":
    command => "echo 'creating ${home_dir}' && mkdir -p ${home_dir}",
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

  file {"/var/lib/manifoldcf":
    ensure  => directory,
    owner   => tomcat6,
    mode    => 0644,
  }

  file {$mcf_synchdirectory:
    ensure  => directory,
    path    => $mcf_synchdirectory,
    owner   => tomcat6,
    mode    => 0644,
    require => File["/var/lib/manifoldcf"]
  }
  
  # TODO remove this hack
  $source = "/vagrant/dist.tar.gz"
  
  $manifoldcf_home_dir = "${home_dir}"
  
  # unpack manifold dist into home directory
  exec {"unpack-manifoldcf":
    command => "tar --strip-components=1 -xzf ${source} --directory ${manifoldcf_home_dir}",
    cwd => $manifoldcf_home_dir,
    creates => "$manifoldcf_home_dir/README.txt",
    require => [Package["tomcat6"], Exec["create_manifoldcf_home_dir"]],
    user => "tomcat6",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }
  
  $mcf_api_service_dir = "${home_dir}/web-proprietary/war/mcf-api-service.war"
  
  file { "/etc/tomcat6/Catalina/localhost/mcf-api-service.xml":
    ensure => present,
    content => template("manifoldcf/mcf-api-service.xml.erb"),
    require => [Package["tomcat6"]],
    notify  => Service['tomcat6'],
  }
  
  $mcf_authority_service_dir = "${home_dir}/web-proprietary/war/mcf-authority-service.war"
  
  file { "/etc/tomcat6/Catalina/localhost/mcf-authority-service.xml":
    ensure => present,
    content => template("manifoldcf/mcf-authority-service.xml.erb"),
    require => [Package["tomcat6"]],
    notify  => Service['tomcat6'],
  }
  
  $mcf_crawler_ui_dir = "${home_dir}/web-proprietary/war/mcf-crawler-ui.war"
  
  file { "/etc/tomcat6/Catalina/localhost/mcf-crawler-ui.xml":
    ensure => present,
    content => template("manifoldcf/mcf-crawler-ui.xml.erb"),
    require => [Package["tomcat6"]],
    notify  => Service['tomcat6'],
  }
  
}