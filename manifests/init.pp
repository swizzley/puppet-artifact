# Class: artifact
#
# This module manages artifact
#
# Parameters: $source, $target, $update, $rename, $purge, $swap, $owner, $group, $mode, $legacy
#
# Actions:
#
# Requires: Package['curl', 'dos2unix', 'grep', 'diffutils', 'bash']
#
# Sample Usage:
#
define artifact (
  $source,
  $target,
  $update  = false,
  $rename  = undef,
  $purge   = false,
  $swap    = '/tmp',
  $legacy  = false,
  $timeout = 0,) {
  validate_bool($update)
  validate_bool($purge)
  validate_bool($legacy)
  validate_absolute_path($target)
  validate_absolute_path($swap)
  validate_string($source)
  validate_string($title)

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
      exec { "purging and fetching artifact ${resource}":
        path     => $path,
        provider => 'shell',
        command  => "rm -f ${full_target} && curl -so ${full_target} ${source}",
        creates  => $full_target,
        timeout  => $wait_sec
      }
    } else {
      exec { "fetching artifact ${resource}":
        path     => $path,
        provider => 'shell',
        command  => "curl -so ${full_target} ${source}",
        creates  => $full_target,
        timeout  => $wait_sec
      }
    }
  } elsif ($legacy == false) {
    contain artifact::script

    exec { "updating ${resource}":
      path     => $path,
      provider => 'shell',
      command  => "mv -f ${swap_target} ${full_target}",
      onlyif   => "/usr/local/sbin/artifact-puppet ${full_target} ${source} ${swap_target}",
      timeout  => $wait_sec
    }
  } elsif ($rename == undef) {
    exec { "updating ${resource}":
      path     => $path,
      provider => 'shell',
      command  => "mv -f /tmp/${resource} ${full_target}",
      onlyif   => "touch ${full_target} && curl -so ${swap}/${resource} ${source} && diff ${swap}/${resource} ${full_target}|grep differ",
      timeout  => $wait_sec
    }
  } elsif ($rename != undef) {
    exec { "updating ${resource}":
      path     => $path,
      provider => 'shell',
      command  => "mv -f /tmp/${rename} ${full_target}",
      onlyif   => "touch ${full_target} && curl -so ${swap}/${rename} ${source} && diff ${swap}/${rename} ${full_target}|grep differ",
      timeout  => $wait_sec
    }
  }
}

