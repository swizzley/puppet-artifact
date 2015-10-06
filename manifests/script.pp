# class artifact::script
class artifact::script {
  include artifact::packages

  file { '/usr/local/sbin/artifact-puppet':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/artifact/artifact-puppet',
    require => [Package['dos2unix'], Package['curl'], Package['grep'], Package['diffutils'], Package['bash']]
  }
}