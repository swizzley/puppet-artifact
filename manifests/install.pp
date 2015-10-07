# class artifact::install
class artifact::install {
  package { ['curl', 'dos2unix', 'grep', 'diffutils', 'bash']: ensure => installed }

  file { '/usr/local/sbin/artifact-puppet':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/artifact/artifact-puppet',
    require => Package['curl', 'dos2unix', 'grep', 'diffutils', 'bash'],
  }
}