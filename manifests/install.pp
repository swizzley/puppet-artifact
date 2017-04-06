# class artifact::install
class artifact::install {
  if !defined(Package['curl']) {
    package { 'curl': ensure => installed }
  }

  if !defined(Package['dos2unix']) {
    package { 'dos2unix': ensure => installed }
  }

  if !defined(Package['grep']) {
    package { 'grep': ensure => installed }
  }

  if !defined(Package['diffutils']) {
    package { 'diffutils': ensure => installed }
  }

  if !defined(Package['bash']) {
    package { 'bash': ensure => installed }
  }

  if !defined(Package['md5sum']) {
    package { 'md5sum': ensure => installed }
  }

  file { '/usr/local/sbin/artifact-puppet':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/artifact/artifact-puppet',
    require => [Package['dos2unix'], Package['curl'], Package['grep'], Package['bash'], Package['md5sum']]
  }
}
