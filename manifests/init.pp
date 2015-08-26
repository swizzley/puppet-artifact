# Class: artifact
#
# This module manages artifact
#
# Parameters: $source, $target, $update, $rename, $purge,
#             $swap, $owner, $group, $mode
#
# Actions:
#
# Requires: curl
#
# Sample Usage:
# artifact { 'artifact.war':
#  source => 'http://example.com/pub/artifact.war',
#  target => '/home/tomcat/webapps',
#  update => true,
#  rename => 'current.war',
#}
define artifact ($source, $target, $update = false, $rename = undef,
  $purge = false, $swap = '/tmp',) {
  validate_bool($update)
  validate_bool($purge)
  validate_absolute_path($target)
  validate_absolute_path($swap)
  validate_string($source)
  validate_string($title)

  # Just incase someone removes curl or diff
  package { ['curl', 'diffutils']: ensure => 'installed' }

  # Some overly scoped path to help functionality across platforms
  $path = '/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/share/bin:~/bin'
  $resource = $title

  # Do we rename
  if ($rename != undef) {
    validate_string($rename)
    $full_target = "${target}/${rename}"
  } else {
    $full_target = "${target}/${resource}"
  }

  # Here's the magic, I would have used md5sum except there wasn't an elegant
  # way to use it because the puppet shell provider is not
  # bash and it causes a syntax exception in sh, hence TODO
  # [TODO] Request puppetlabs add the ability to specify shell provider

  if ($update == false) {
    if ($purge == true) {
      exec { "purging then fetching artifact ${resource}":
        path     => $path,
        provider => 'shell',
        command  => "rm -f ${full_target} && curl -sko ${full_target} ${source}",
        creates  => $full_target,
        require  => [Package['curl'], Package['diffutils']],
      }
    } else {
      exec { "fetching artifact ${resource}":
        path     => $path,
        provider => 'shell',
        command  => "curl -sko ${full_target} ${source}",
        creates  => $full_target,
        require  => [Package['curl'], Package['diffutils']],
      }
    }
  } else {
    exec { "updating ${resource}":
      path     => $path,
      provider => 'shell',
      command  => "mv -f /tmp/${resource} ${full_target}",
      onlyif   => "touch ${full_target} && curl -sko ${swap}/${resource} ${source} && diff ${swap}/${resource} ${full_target}|grep differ",
      require  => [Package['curl'], Package['diffutils']],
    }
  }
}
