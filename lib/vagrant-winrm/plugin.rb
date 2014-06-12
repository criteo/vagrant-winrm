require 'vagrant'

module VagrantPlugins
  module VagrantWinRM
    autoload :Errors, File.expand_path('../errors', __FILE__)

    class Plugin < Vagrant.plugin('2')
      name 'winrm'
      description <<-DESC
      This plugin extends Vagrant WinRM features and add new commands.
      DESC

      command 'winrm-config' do
        require_relative 'commands/winrm_config'
        WinRMConfig
      end

      command 'winrm-upload' do
        require_relative 'commands/winrm_upload'
        WinRMUpload
      end

      command 'winrm' do
        require_relative 'commands/winrm'
        WinRM
      end
    end
  end
end
