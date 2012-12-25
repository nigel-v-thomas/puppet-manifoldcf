# Type: manifoldcf::setup-script-env
#
# set up a script file with appropriate environment set.
#
# IMPORTANT: Works only with Ubuntu as of now. Other platform
# support is most welcome. 
#
# Parameters:
# full_path_to_env_script = name of war file without extension
# home_dir = name of war file without extension
# full_path_script_to_run = name of war file without extension
# Actions:
#
# Requires:
# Package tomcat6
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
define manifoldcf::setup_script_env($full_path_to_env_script = $title, $home_dir, $full_path_script_to_run){
  
  file { "${full_path_to_env_script}":
    ensure => present,
    content => template("manifoldcf/initialise-with-env.sh.erb"),
    require => Service["tomcat6"],
    owner   => tomcat6,
    mode    => 0755,
  }
  
  
}