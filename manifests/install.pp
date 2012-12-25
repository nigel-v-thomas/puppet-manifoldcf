class manifoldcf::install (
  $source_url, 
  $home_dir = $manifoldcf::params::home_dir, 
  $package = $manifoldcf::params::package,
  $mcf_synchdirectory = $manifoldcf::params::mcf_synchdirectory
  ) inherits manifoldcf::params {
  $tmp_dir = "/var/tmp"
  
  package {"openjdk-6-jdk":
    ensure => present,
    before => Exec["create_manifoldcf_home_dir"]
  }  
  package {"tomcat6":
    ensure => present,
    before => Exec["create_manifoldcf_home_dir"]
  }
  
  service{ "tomcat6":
    ensure => running,
    require => Package["tomcat6"]
  }
  
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
  
  # if source url is a valid url, download solr
  if $source_url =~ /^http.*/ {
    $source = "${tmp_dir}/${package}.tgz"

    exec { "download-solr":
      command => "wget $source_url",
      creates => "$source",
      cwd => "$tmp_dir",
      path => ["/bin", "/usr/bin", "/usr/sbin"],
      require => File["mcf_synchdirectory"],
      before => Exec["unpack-manifoldcf"],
    }
    
  } else {
    # assumes is a path.. 
    $source = $source_url
  }
  
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

  manifoldcf::unpack_wars { "${home_dir}/web-proprietary/war/mcf-api-service.war":
    unpack_dir => "${home_dir}/web-proprietary/war/mcf-api-service",
    verify_file_exist => "${home_dir}/web-proprietary/war/mcf-api-service/WEB-INF",
    require => Exec["unpack-manifoldcf"],
  }
  
  manifoldcf::setup_war_context {"/mcf-api-service":
    war_docbase => "${home_dir}/web-proprietary/war/mcf-api-service",
    require => Manifoldcf::Unpack_wars["${home_dir}/web-proprietary/war/mcf-api-service.war"]
  } 
  
  # unpack mcf crawler ui 

  manifoldcf::unpack_wars { "${home_dir}/web-proprietary/war/mcf-crawler-ui.war":
    unpack_dir => "${home_dir}/web-proprietary/war/mcf-crawler-ui",
    verify_file_exist => "${home_dir}/web-proprietary/war/mcf-crawler-ui/WEB-INF",
    require => Exec["unpack-manifoldcf"],
  }
  
  manifoldcf::setup_war_context {"/mcf-crawler-ui":
    war_docbase => "${home_dir}/web-proprietary/war/mcf-crawler-ui",
    require => Manifoldcf::Unpack_wars["${home_dir}/web-proprietary/war/mcf-crawler-ui.war"]
  }

  # unpack authority service
  
  manifoldcf::unpack_wars { "${home_dir}/web-proprietary/war/mcf-authority-service.war":
    unpack_dir => "${home_dir}/web-proprietary/war/mcf-authority-service",
    verify_file_exist => "${home_dir}/web-proprietary/war/mcf-authority-service/WEB-INF",
    require => Exec["unpack-manifoldcf"],
  }
  
  manifoldcf::setup_war_context {"/mcf-authority-service":
    war_docbase => "${home_dir}/web-proprietary/war/mcf-authority-service",
    require => Manifoldcf::Unpack_wars["${home_dir}/web-proprietary/war/mcf-authority-service.war"]
  }
  
}