module VagrantPlugins
  module VagrantWinRM
    module Errors
      # A convenient superclass for all our errors.
      class WinRMError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_winrm.errors')
      end

      class ConfigurationError < WinRMError
        error_key(:config_error)
      end

      class TempFolderError < WinRMError
        error_key(:tempfolder_error)
      end
    end
  end
end
