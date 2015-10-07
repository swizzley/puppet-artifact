# Class: artifact
#
# This module manages and updates artifacts, a.k.a. local copies of files
# that are stored on a web server.
#
# Parameters: $source, $target, $update, $rename, $purge, $swap, $timeout, $user, $group, $mode
#
# Actions:  Downloads source to swap, checks difference in target, and replaces
#           target with swap, option to rename on download
#
# Requires: Package['curl', 'dos2unix', 'grep', 'diffutils', 'bash']
#
# Sample Usage:
# 							artifact { 'artifact.war':
# 							  source  => 'http://example.com/pub/artifact.war',
# 							  target  => '/home/tomcat/webapps',
# 							  update  => true,
# 							}
#
define artifact (
  $source,
  $target,
  $update  = false,
  $rename  = undef,
  $purge   = false,
  $swap    = '/tmp',
  $timeout = 0,
  $owner   = undef,
  $group   = undef,
  $mode    = undef) {
  validate_bool($update)
  validate_bool($purge)
  validate_absolute_path($target)
  validate_absolute_path($swap)
  validate_string($source)
  validate_string($title)
  include artifact::install

  # Some overly scoped path to help functionality across platforms
  $path = '/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/share/bin:/usr/share/bin'
  $resource = $title
  $wait_sec = $timeout

  if ($rename != undef) {
    validate_string($rename)
    $full_target = "${target}/${rename}"
    $swap_target = "${swap}/${rename}"
  } else {
    $full_target = "${target}/${resource}"
    $swap_target = "${swap}/${resource}"
  }

  if ($update == false) {
    if ($purge == true) {
      exec { "artifact ${resource}":
        path     => $path,
        provider => 'shell',
        command  => "rm -f ${full_target} && curl -so ${full_target} ${source}",
        creates  => $full_target,
        timeout  => $wait_sec,
        require  => Package['curl']
      }
    } else {
      exec { "artifact ${resource}":
        path     => $path,
        provider => 'shell',
        command  => "curl -so ${full_target} ${source}",
        creates  => $full_target,
        timeout  => $wait_sec,
        require  => Package['curl']
      }
    }
  } else {
    exec { "artifact ${resource}":
      path     => $path,
      provider => 'shell',
      command  => "mv -f ${swap_target} ${full_target}",
      onlyif   => "/usr/local/sbin/artifact-puppet ${full_target} ${source} ${swap_target}",
      timeout  => $wait_sec,
      require  => File['/usr/local/sbin/artifact-puppet']
    }
  }

  file { $full_target:
    ensure    => present,
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    require   => Exec["artifact ${resource}"],
    subscribe => Exec["artifact ${resource}"]
  }
}

