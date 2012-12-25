class manifoldcf::service (
  $home_dir = $manifoldcf::params::home_dir, 
  ) inherits manifoldcf::params {
  
  $mcf_start_agents_full_path = "${home_dir}/multiprocess-example/start-agents-env-setup.sh"
  $mcf_stop_agents_full_path = "${home_dir}/multiprocess-example/stop-agents-env-setup.sh"
  $mcf_agents_base_dir = "${home_dir}/multiprocess-example/"
  
  manifoldcf::setup_script_env { "${mcf_start_agents_full_path}":
     home_dir => $home_dir,
     full_path_script_to_run => "${home_dir}/multiprocess-example/start-agents.sh",
     #before => Service["manifold-cf"],
  }

  manifoldcf::setup_script_env { "${mcf_stop_agents_full_path}":
     home_dir => $home_dir,
     full_path_script_to_run => "${home_dir}/multiprocess-example/stop-agents.sh",
     #before => Service["manifold-cf"],
  }
  
  file { "/etc/init.d/manifold-cf":
    content => template("manifoldcf/manifold-cf.erb"),
    owner   => tomcat6,
    mode    => 0755,
    before =>  Manifoldcf::Setup_script_env["${mcf_start_agents_full_path}"]
  }
  
  service{ "manifold-cf":
    ensure => running,
    require => File["/etc/init.d/manifold-cf"]
  }
}