require 'vagrant'

module VagrantPlugins
  module VagrantWinRM

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    # This initializes the internationalization strings.
    def self.setup_i18n
      I18n.load_path << File.expand_path('locales/en.yml', source_root)
      I18n.reload!
    end
  end
end

VagrantPlugins::VagrantWinRM.setup_i18n()
require 'vagrant-winrm/plugin'
