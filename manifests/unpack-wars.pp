# Type: manifoldcf::unpack-wars
#
# Unpacks a war file with the war file name to the same directory as the base_dir
#
# IMPORTANT: Works only with Ubuntu as of now. Other platform
# support is most welcome. 
#
# Parameters:
# war_name = name of war file without extension
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
define manifoldcf::unpack-wars($war_file_path = $title, $unpack_dir, $verify_file_exist, $run_as_user = "tomcat6"){
  
  # create a directory with the war name
  exec { "mkdir -p ${unpack_dir}":
    user => $run_as_user,
    creates => $unpack_dir,
    before => File["${unpack_dir}"],
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }
  
  # set permission on dir
  file {"${unpack_dir}":
    ensure  => directory,
    owner   => $run_as_user,
    mode    => 0644,
    require => Exec["mkdir -p ${unpack_dir}"]
  }
  
  $tmp_war_location = "${unpack_dir}/tmp.war"
  
  # copy war to correct location
  file {$tmp_war_location:
    ensure  => file,
    source => "${war_file_path}",
    owner   => $run_as_user,
    mode    => 0755,
    require => File["${unpack_dir}"]
  }
 
  # unpack war dist into current directory, with the same name as war
  exec { "jar -xf ${tmp_war_location}":
    user   => $run_as_user,
    cwd => $unpack_dir,
    creates => $verify_file_exist,
    require => [File["${tmp_war_location}"], Package["openjdk-6-jdk"]],
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  } 
  
  # clean up and remove war
  exec {"rm '${tmp_war_location}'":
    user   => $run_as_user,
    require => Exec["jar -xf ${tmp_war_location}"],
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    onlyif => "test -f ${tmp_war_location}" 
  }

  
}