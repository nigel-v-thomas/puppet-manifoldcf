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
    require => File[$home_dir],
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
  
  exec {"unpack-manifoldcf":
    command => "tar --strip-components=1 -xzf ${source} --directory ${manifoldcf_home_dir}",
    cwd => $manifoldcf_home_dir,
    creates => "$manifoldcf_home_dir/README.txt",
    require => [Package["tomcat6"], Exec["create_manifoldcf_home_dir"]],
    user => "tomcat6",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }

  # unpack mcf-api-service

  manifoldcf::unpack-wars { "${home_dir}/web-proprietary/war/mcf-api-service.war":
    unpack_dir => "${home_dir}/web-proprietary/war/mcf-api-service",
    verify_file_exist => "${home_dir}/web-proprietary/war/mcf-api-service/WEB-INF",
    require => Exec["unpack-manifoldcf"],
  }
  
  manifoldcf::setup-war-context {"/mcf-api-service":
    war_docbase => "${home_dir}/web-proprietary/war/mcf-api-service",
    require => Manifoldcf::Unpack-wars["${home_dir}/web-proprietary/war/mcf-api-service.war"]
  }
  
  # unpack mcf crawler ui 

  manifoldcf::unpack-wars { "${home_dir}/web-proprietary/war/mcf-crawler-ui.war":
    unpack_dir => "${home_dir}/web-proprietary/war/mcf-crawler-ui",
    verify_file_exist => "${home_dir}/web-proprietary/war/mcf-crawler-ui/WEB-INF",
    require => Exec["unpack-manifoldcf"],
  }
  
  manifoldcf::setup-war-context {"/mcf-crawler-ui":
    war_docbase => "${home_dir}/web-proprietary/war/mcf-crawler-ui",
    require => Manifoldcf::Unpack-wars["${home_dir}/web-proprietary/war/mcf-crawler-ui.war"]
  }

  # unpack authority service
  
  manifoldcf::unpack-wars { "${home_dir}/web-proprietary/war/mcf-authority-service.war":
    unpack_dir => "${home_dir}/web-proprietary/war/mcf-authority-service",
    verify_file_exist => "${home_dir}/web-proprietary/war/mcf-authority-service/WEB-INF",
    require => Exec["unpack-manifoldcf"],
  }
  
  manifoldcf::setup-war-context {"/mcf-authority-service":
    war_docbase => "${home_dir}/web-proprietary/war/mcf-authority-service",
    require => Manifoldcf::Unpack-wars["${home_dir}/web-proprietary/war/mcf-authority-service.war"]
  }
  
}