require 'optparse'

module VagrantPlugins
  module VagrantWinRM
    class WinRMUpload < Vagrant.plugin('2', :command)
      def self.synopsis
        'upload file or directory to machine via WinRM'
      end

      def execute
        options = { temporary: false }

        opts = OptionParser.new do |o|
          o.banner = <<-EOS
Usage:
\tvagrant winrm-upload <source> <destination> [name]
\tvagrant winrm-upload -t <source> [name]
          EOS
          o.separator 'Options:'

          o.on('-t', '--temporary', 'Upload the source file to a temporary directory and return the path') do
            options[:temporary] = true
          end
        end

        # Parse the options and return if we don't have any target.
        argv = parse_options opts
        return unless argv

        source = argv[0]
        if options[:temporary]
          min, max, destination = 1, 2, ::File.basename(argv[0])
        else
          min, max, destination = 2, 3, argv[1]
        end

        if argv.empty? || argv.length > max || argv.length < min
          raise Vagrant::Errors::CLIInvalidUsage, help: opts.help.chomp
        end
        argv = argv.drop(min)

        # Execute the actual WinRM
        with_target_vms(argv, single_target: true) do |vm|

          raise Errors::ConfigurationError, { :communicator => vm.config.vm.communicator } if vm.config.vm.communicator != :winrm

          destination_file = options[:temporary] ? ::File.join(get_remote_temp_folder(vm), destination) : destination
          $stdout.print destination_file if options[:temporary]

          @logger.debug("Uploading #{source} to #{destination}")
          return vm.communicate.upload(source, destination_file)
        end
      end


      private

      def get_remote_temp_folder(vm)
        dir = nil
        vm.communicate.execute('[System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName()) | Write-Host -NoNewline') do |type, data|
          raise Errors::TempFolderError, { :communicator => vm.config.vm.communicator } if type == :stderr || dir
          dir = data
        end
        dir
      end
    end
  end
end
