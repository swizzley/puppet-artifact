# class artifact::script
class artifact::script () {
  $dir = $artifact::bin_dir

  file { "${dir}/artifact-puppet":
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/artifact/artifact-puppet'
  }
}