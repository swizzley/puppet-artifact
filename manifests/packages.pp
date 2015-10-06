# class artifact::packages
class artifact::packages {
  package { ['curl', 'dos2unix', 'grep', 'diffutils', 'bash']: ensure => installed }
}