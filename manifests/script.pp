# class artifact::script
class artifact::script {
  file { '/usr/local/sbin/artifact-puppet':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/artifact/artifact-puppet',
    require => [Package['dos2unix'], Package['curl'], Package['grep'], Package['diffutils'], Package['bash']]
  }
}