# class artifact::install
class artifact::install {
  package { 'curl': ensure => installed }

  package { 'dos2unix': ensure => installed }

  package { 'grep': ensure => installed }

  package { 'diffutils': ensure => installed }

  package { 'bash': ensure => installed }

  file { '/usr/local/sbin/artifact-puppet':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/artifact/artifact-puppet',
    require => [Package['dos2unix'], Package['curl'], Package['grep'], Package['bash']]
  }
}