# Class: artifact
#
# This module manages artifact
#
# Parameters: $source, $target, $update, $rename, $purge, $swap, $owner, $group, $mode
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
define artifact ($source, $target, $update = false, $rename = undef, $purge = false, $swap = '/tmp', $timeout = 0) {
  validate_bool($update)
  validate_bool($purge)
  validate_absolute_path($target)
  validate_absolute_path($swap)
  validate_string($source)
  validate_string($title)

  # Some overly scoped path to help functionality across platforms
  $path = '/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/share/bin:/usr/share/bin'
  $resource = $title

  if ($rename != undef) {
    validate_string($rename)
    $full_target = "${target}/${rename}"
  } else {
    $full_target = "${target}/${resource}"
  }

  if ($update == false) {
    if ($purge == true) {
      exec { "purging and fetching artifact ${resource}":
        path     => $path,
        provider => 'shell',
        command  => "rm -f ${full_target} && curl -so ${full_target} ${source}",
        creates  => $full_target,
        timeout  => $timeout
      }
    } else {
      exec { "fetching artifact ${resource}":
        path     => $path,
        provider => 'shell',
        command  => "curl -so ${full_target} ${source}",
        creates  => $full_target,
        timeout  => $timeout
      }
    }
  } elsif ($rename == undef) {
    exec { "updating ${resource}":
      path     => $path,
      provider => 'shell',
      command  => "mv -f /tmp/${resource} ${full_target}",
      onlyif   => "touch ${full_target} && curl -so ${swap}/${resource} ${source} && diff ${swap}/${resource} ${full_target}|grep differ",
      timeout  => $timeout
    }
  } elsif ($rename != undef) {
    exec { "updating ${resource}":
      path     => $path,
      provider => 'shell',
      command  => "mv -f /tmp/${rename} ${full_target}",
      onlyif   => "touch ${full_target} && curl -so ${swap}/${rename} ${source} && diff ${swap}/${rename} ${full_target}|grep differ",
      timeout  => $timeout
    }
  }
}

