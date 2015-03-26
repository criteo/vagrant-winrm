# <a name="title"></a> Vagrant-WinRM

This is a [Vagrant][vagrant_dl] 1.6+ plugin that adds new command to extends WinRM communication features.

**NOTE:** This plugin requires Vagrant 1.6+

## <a name="features"></a> Features

* Execute remote command (even with elevated credentials)
* Upload files
* Retrieve WinRM configuration

## <a name="installation"></a> Installation

Install using standard Vagrant plugin installation methods:

    vagrant plugin install vagrant-winrm

Please read the [Plugin usage][plugin_usage] page for more details.

## <a name="usage"></a> Usage

### <a name="usage-winrm"> winrm

This command allows you to execute arbitrary remote commands through WinRM.

    vagrant winrm -c "pre-install.bat" -c "install.bat" -c "post-install.bat" Windows2008VM

The following command run the given command with local elevated credentials
    vagrant winrm -e -c "winrm get winrm/config Windows2008VM

### <a name="usage-winrm-upload"> winrm-upload

This command allows you to upload a file or a directory to your machine through WinRM.

    vagrant winrm-upload "c:\mylocalFolder" "d:\" Windows2008VM

## <a name="usage-winrm-config"> winrm-config

This command prints the current WinRM configuration of your machine.

```bash
$ vagrant winrm-config --host "CustomHostname" Windows2008VM
Host CustomHostname
  HostName Windows2008VM.vagrant.up
  Port 5985
  User vagrant
  Password vagrant
  RDPPort 3389
```

## <a name="development"></a> Development

* Source hosted at [Github][repo]
* Report issues/questions/feature requests on [Github Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Baptiste Courtois][author] (<b.courtois@criteo.com>)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[author]:                   https://github.com/Annih
[issues]:                   https://github.com/criteo/vagrant-winrm/issues
[license]:                  https://github.com/criteo/vagrant-winrm/blob/master/LICENSE
[repo]:                     https://github.com/criteo/vagrant-winrm
[plugin_usage]:             http://docs.vagrantup.com/v2/plugins/usage.html

[vagrant_dl]:               http://downloads.vagrantup.com/
