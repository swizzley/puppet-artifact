# artifact #

[![Puppet Forge](https://img.shields.io/badge/puppetforge-v0.2.1-blue.svg)](https://forge.puppetlabs.com/swizzley88/artifact)

**Table of Contents**

1. [Overview](#overview)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Requirements](#requirements)
5. [Compatibility](#compatibility)
6. [Limitations](#limitations)
7. [Development](#development)
    
## Overviw

This module is designed to download artifacts using curl, the key feature is the ability to update artifacts from a source if they are different. It uses curl because it doesn't usually need installed. Also for refreshing services dependant on these artifacts, which is why this module was developed relies heavily on meta parameters, require, subscribe, before, notify, and for triggering external checks the exec refreshonly bool. It adds a new bash script called /usr/local/sbin/artifact-puppet which can be overridden using the ```legacy => true``` parameter, but this script does a test based on file size before downloading, and confirms the size matches before overriding the working file with the swap file, else it prints a download error, or skips the download entirely if ```update => true``` and the file sizes are identical.

## Setup

puppet module install swizzley88-artifact

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
  source => 'http://example.com/pub/artifact.war', 
  target => '/home/tomcat/webapps', 
  purge  => true,
  notify => [File['/home/tomcat/webapps/artifact.war'], Service['tomcat']],
}
```

## Requirements

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

