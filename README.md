# artifact #

[![Puppet Forge](https://img.shields.io/badge/puppetforge-v0.2.4-blue.svg)](https://forge.puppetlabs.com/swizzley88/artifact)

**Table of Contents**

1. [Overview](#overview)
2. [Setup](#setup)
3. [Parameteres](#parameters)
4. [Usage](#usage)
5. [Requirements](#requirements)
6. [Compatibility](#compatibility)
7. [Limitations](#limitations)
8. [Development](#development)
    
## Overviw

This module is designed to download artifacts using curl, the key feature is the ability to update artifacts from a source if they are different. It uses curl because it doesn't usually need installed. For refreshing services dependant on these artifacts... which is why this module was developed relies heavily on meta parameters, require, subscribe, before, notify, and for triggering external checks the exec refreshonly bool. As of version 0.2.x this module adds a new bash script called /usr/local/sbin/artifact-puppet which can be overridden using the ```legacy => true``` parameter to use the old download and diff method, but this bash script is more efficient and reliable because it does a test based on file size before downloading, and then confirms the size matches before overriding the working file with the swap file, else it prints a download error, or skips the download entirely which only applies to the ```update => true``` parameter. 

## Setup

```puppet module install swizzley88-artifact```

Depending on your distribution and install level, you may need to install the below packages, I didn't include these because they are usually installed with a Base OS install and I didn't want to force anyone to refactor.

```
package{['curl', 'dos2unix', 'grep', 'diffutils', 'bash']: ensure => installed}
```

## Paramaeters

  * $source  https://some_url.jar ```[required]```
  * $target  /some/local/dir ```[required]```
  * $update  override with newer ```[default: false]```
  * $rename  rename the downloaded file ```[default: undef]```
  * $purge   replace the target (alternative to updating) ```[default: false]```
  * $swap    /download/dir ```[default: /tmp]```
  * $timeout exit after $x seconds ```[default: 0]```
  * $bin_dir /bin/dir to save bash script ```[default: /usr/local/sbin]```
  * $legacy  use old download and diff method ```[default: false]```

## Usage

```
artifact { 'artifact.war': 
  source => 'http://example.com/pub/artifact.war', 
  target => '/home/tomcat/webapps', 
  update => true,
  rename => 'current.war',
  swap   => '/home/tomcat/tmp',
  legacy => true,
  before => File['/home/tomcat/webapps/artifact.war'],
  notify => Service['tomcat'],
}
artifact { 'artifact.war': 
  source  => 'http://example.com/pub/artifact.war', 
  target  => '/home/tomcat/webapps', 
  purge   => true,
  bin_dir => '/usr/bin',
  notify  => [File['/home/tomcat/webapps/artifact.war'], Service['tomcat']],
}
```

Command-Line usage of /usr/local/sbin/artifact-puppet:

```
/usr/local/sbin/artifact-puppet /opt/wordpress.tar.gz https://wordpress.org/latest.tar.gz /tmp/wordpress.tar.gz
```

This will only compare if ARG1's size isn't the same as ARG2 and download it to ARG3, it only touches ARG1 & ARG3 if they don't exist.

## Requirements

These packages are not installed by this module.

```
package { ['curl', 'diffutils', 'grep', 'dos2unix']: ensure => 'installed' }
```
## Compatibility

Linux:

 * RHEL/CentOS/Fedora/Oracle/Scientific
 * Debian/Ubuntu (untested since 0.1.4)
 
Tested On: CentOS 6.4 (used in production)

## Limitations

This module will not set permissions, therefore if this is needed, a second declaration of the final resource is needed, presumably using notify meta parameter.
```
file { '/home/tomcat/webapps/current.war': 
  ensure  => present,
  owner   => 'tomcat',
  group   => 'apache',
  mode    => '0640',
  require => Artifact['artifact.war]',
  notify  => Service['tomcat'],
```

## Development

I plan to add permissions and package deps eventually, as well as further OS support, and perhaps even integrate as a puppet type with checksum. Curent version is only tested on EL6. 

```
onlyif   => "bash -c 'curl -sko ${swap}/${resource} ${source}/${resource} && diff <( echo $(md5sum ${swap}/${resource}) ) <( echo $(md5sum ${full_target}) )|grep -E \"<|>\"'",
```

See what I mean, it would look much prettier without the bash -c '\"\"'

