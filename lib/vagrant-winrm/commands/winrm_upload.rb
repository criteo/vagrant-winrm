require 'optparse'

module VagrantPlugins
  module VagrantWinRM
    class WinRMUpload < Vagrant.plugin('2', :command)
      def self.synopsis
        'upload file or directory to machine via WinRM'
      end

      def execute
        options = { temporary: false, compress: false }
        source, destination, argv = parse_args options

        return unless source || destination

        # Execute the actual WinRM
        with_target_vms(argv, single_target: true) do |vm|

          raise Errors::ConfigurationError, { :communicator => vm.config.vm.communicator } if vm.config.vm.communicator != :winrm

          tmp_dest = get_remote_temp_folder(vm) if options[:temporary] || options[:compress]

          dest_file = options[:temporary] ? ::File.join(tmp_dest, destination) : destination
          $stdout.print dest_file if options[:temporary]

          @logger.debug("Uploading #{source} to #{destination}")
          if options[:compress]
            source_is_dir = ::File.directory? source
            source = compress(source, source_is_dir)

            dest_dir = source_is_dir || dest_file.end_with?('/') || dest_file.end_with?('\\') ? dest_file : ::File.dirname(dest_file)
            remote_tgz_path = ::File.join(::File.dirname(tmp_dest), ::File.basename(source))
            vm.communicate.upload(source, remote_tgz_path)
            return vm.communicate.execute("New-Item '#{dest_dir}' -type directory -force; tar -xzf '#{remote_tgz_path}' -C '#{dest_dir}'; ")
          else
            return vm.communicate.upload(source, dest_file)
          end
        end
      end


      private

      def compress(source, source_is_dir)
        require 'zlib'
        require 'tempfile'
        require 'archive/tar/minitar'

        cwd = Dir.pwd
        begin
          tmp = ::Tempfile.new(['script', '.tar.gz'])
          tmp.binmode
          tgz = Zlib::GzipWriter.new (tmp)

          Dir.chdir source_is_dir ? source : ::File.dirname(source)
          Archive::Tar::Minitar.pack(source_is_dir ? '.' : ::File.basename(source), tgz)

          tmp.path # returns the temporary file path
        ensure
          tgz.close if tgz && !tgz.closed?
          tmp.close if tmp && !tmp.closed?
          Dir.chdir cwd
        end
      end

      def parse_args(options)
        opts = OptionParser.new do |o|
          o.banner = <<-EOS
Usage:
\tvagrant winrm-upload [-c] <source> <destination> [name]
\tvagrant winrm-upload [-c] -t <source> [name]
          EOS
          o.separator 'Options:'

          o.on('-t', '--temporary', 'Upload the source file to a temporary directory and return the path') do
            options[:temporary] = true
          end

          o.on('-c', '--compress', 'Use gzip compression to speed up the upload') do
            options[:compress] = true
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
        [source, destination, argv.drop(min)]
      end

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
