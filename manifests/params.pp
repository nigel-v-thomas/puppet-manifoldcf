# This is the generic solr parameters
class manifoldcf::params {
  case $operatingsystem {
    /(Ubuntu|Debian)/: {
      
    }
    default: {
      fail("Operating system, $operatingsystem, is not supported by the tomcat module")
    }
  }
}
