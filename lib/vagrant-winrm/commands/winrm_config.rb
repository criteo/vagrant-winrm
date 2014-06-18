require 'optparse'
require 'vagrant/util/safe_puts'

module VagrantPlugins
  module VagrantWinRM
    class WinRMConfig < Vagrant.plugin('2', :command)
      include Vagrant::Util::SafePuts

      def self.synopsis
        'outputs winrm configuration to connect to the machine like ssh-config'
      end

      def execute
        options = {}

        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant winrm-config [options] [name]'
          o.separator ''
          o.separator 'Options:'
          o.separator ''

          o.on('--host NAME', 'Name the host for the config') do |h|
            options[:host] = h
          end
        end

        # Parse the options and return if we don't have any target.
        argv = parse_options(opts)
        return unless argv

        with_target_vms(argv) do |machine|

          variables = {
            host_key: options[:host] || machine.name || 'vagrant',
            winrm_host: machine.config.winrm.host,
            winrm_port: machine.config.winrm.port,
            winrm_user: machine.config.winrm.username,
            winrm_password: machine.config.winrm.password
          }

          # Render the template and output directly to STDOUT
          template = "#{VagrantPlugins::VagrantWinRM.source_root}/templates/winrm_config/config"
          safe_puts(Vagrant::Util::TemplateRenderer.render(template, variables))
          safe_puts
        end

        # Success, exit status 0
        0
      end
    end
  end
end
