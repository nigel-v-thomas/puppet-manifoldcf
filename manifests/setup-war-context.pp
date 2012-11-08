# Type: manifoldcf::setup-war-context
#
# Unpacks a war file with the war file name to the same directory as the base_dir
#
# IMPORTANT: Works only with Ubuntu as of now. Other platform
# support is most welcome. 
#
# Parameters:
# war_context_path = name of war file without extension
# war_docbase = name of war file without extension
# Actions:
#
# Requires:
# Package tomcat6
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
define manifoldcf::setup-war-context($war_context_path = $title, $war_docbase){
  
  file { "/etc/tomcat6/Catalina/localhost/${war_context_path}.xml":
    ensure => present,
    content => template("manifoldcf/tomcat-context-template.xml.erb"),
    require => [Package["tomcat6"]],
    notify  => Service['tomcat6'],
  }
  
  
}