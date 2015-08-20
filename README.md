# artifact #

[![Puppet Forge](https://img.shields.io/badge/puppetforge-v0.1.0-blue.svg)](https://forge.puppetlabs.com/swizzley88/artifact)

**Table of Contents**

1. [Overview](#overview)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Requirements](#requirements)
5. [Compatibility](#compatibility)
6. [Limitations](#limitations)
7. [Development](#development)
    
## Overviw

This module is designed to download artifacts using curl, the key feature is the ability to update artifacts from a source if they are different. It uses curl because it doesn't usually need installed. Also for refreshing services dependant on these artifacts, which is why this module was developed relies heavily on meta parameters, require, subscribe, before, notify, and for triggering external checks the exec refreshonly bool. 

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
package { ['curl', 'diffutils']: ensure => 'installed' }
```
## Compatibility

Linux:

 * RHEL/CentOS/Fedora/Oracle/Scientific
 * Debian/Ubuntu
 
Tested On: CentOS 6.4 (used in production)

## Limitations

This module will not set permissions, therefore if this is needed, a second declaration of the final resource is needed, presumably using notify meta parameter.
```
file { '/home/tomcat/webapps/current.war': 
  ensure => present,
  owner  => 'tomcat',
  group  => 'apache',
  mode   => '0640',
  require => Artifact['artifact.war]',
  notify => Service['tomcat'],
```

## Development

Not likely to develop this further, but feel free to fork it and send a pull request if you want, if someone ever adds the ability to specify a shell provider for exec, I will change the method from a diff to an md5 comparison. Currently to implement that sh would have to call bash and all the quotes and whacks make it look ugly, diff works well enough for my use case. If you need md5 comparisions, it would look something like this:

```
onlyif   => "bash -c 'curl -sko ${swap}/${resource} ${source}/${resource} && diff <( echo $(md5sum ${swap}/${resource}) ) <( echo $(md5sum ${full_target}) )|grep -E \"<|>\"'",
```

See what I mean, it would look much prettier without the bash -c '\"\"'

