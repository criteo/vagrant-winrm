# Force the plugin setup
ENV["VAGRANT_LOG"] = "debug"

Vagrant.configure('2') do |c|
  c.vm.box = 'windows-2008r2-web-core'
  c.vm.guest = 'windows'
  c.vm.hostname = 'testWinRM'
  c.vm.communicator = 'winrm'

  # Needed for WinRM
  c.winrm.username = 'vagrant'
  c.winrm.password = 'vagrant'

  # Needed for rdesktop
  c.vm.network(:forwarded_port, guest: 3389, host: 3489, auto_correct: true)

  # Provider Virtual box provider
  c.vm.provider :virtualbox do |p|
    p.customize ["modifyvm", :id, '--memory', '1536']
    p.customize ["modifyvm", :id, '--vrde', 'on']
    p.customize ["modifyvm", :id, '--vrdeport', '5000-5100']
    p.customize ["modifyvm", :id, '--vrdeauthtype', 'null']
  end
end
