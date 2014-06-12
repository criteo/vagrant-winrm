require 'optparse'

module VagrantPlugins
  module VagrantWinRM
    class WinRMUpload < Vagrant.plugin('2', :command)
      def self.synopsis
        'upload file or directory to machine via WinRM'
      end

      def execute

        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant winrm-upload <source> <destination> [name]'
        end

        argv = parse_options opts
        return if !argv

        if argv.empty? || argv.length > 3 || argv.length < 2
          raise Vagrant::Errors::CLIInvalidUsage,
            help: opts.help.chomp
        end

        source = argv[0]
        destination = argv[1]
        argv = argv.drop(2)

        # Execute the actual WinRM
        with_target_vms(argv, single_target: true) do |vm|
          @logger.debug("Uploading #{source} to #{destination}")
          return vm.communicate.upload(source, destination)
        end
      end
    end
  end
end
