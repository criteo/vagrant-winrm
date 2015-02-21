require 'spec_helper'
require 'stringio'

describe VagrantPlugins::VagrantWinRM::WinRMConfig, :unit => true do

=begin ############
# Here we mock!
=end ##############
  mock_env

  before do
    # Mock the local env creation
    allow(machine).to receive(:vagrant_env).with('', { :ui_class => '' }).and_return env

    # Mock the index to include only our machine
    allow(idx).to receive(:release).with machine
    allow(idx).to receive(:include?).with(any_args) do |name|
      'vagrant' == name
    end
    allow(idx).to receive(:get).with(any_args) do |name|
      env.machine(name.to_sym, :virtualbox)
    end

    # Add our machine to the environment
    allow(env).to receive(:machine) do |name, provider|
      machine if :vagrant == name
    end
  end

=begin ############
# Here we test!
=end ##############
  describe 'execute' do

    it 'displays help message with option --help' do
      c = VagrantPlugins::VagrantWinRM::WinRMConfig.new(['--help'], env)
      expect {
        expect(c.execute).to be_nil
      }.to output.to_stdout
    end

    it 'raises error on unknown target' do
      c = VagrantPlugins::VagrantWinRM::WinRMConfig.new(['unknownTarget'], env)
      expect { c.execute }.to raise_error(Vagrant::Errors::VMNotFoundError)
    end

    it 'raises error ''invalid options'' on unknown option' do
      c = VagrantPlugins::VagrantWinRM::WinRMConfig.new(['--unknown'], env)
      expect { c.execute }.to raise_error(Vagrant::Errors::CLIInvalidOptions)
    end

    it 'ouputs the WinRMConfig with no Target' do
      c = VagrantPlugins::VagrantWinRM::WinRMConfig.new([], env)
      begin
        $stdout = StringIO.new
        expect(c.execute).to be_zero
        expect($stdout.string).to match(/#{machine.name}/)
        expect($stdout.string).to match(/#{winrm_config.host}/)
        expect($stdout.string).to match(/#{winrm_config.port}/)
        expect($stdout.string).to match(/#{winrm_config.username}/)
        expect($stdout.string).to match(/#{winrm_config.password}/)
      ensure
        $stdout = STDOUT
      end
    end

    it 'ouputs the WinRMConfig with target' do
      c = VagrantPlugins::VagrantWinRM::WinRMConfig.new(['vagrant'], env)
      begin
        $stdout = StringIO.new
        expect(c.execute).to be_zero
        expect($stdout.string).to match(/#{machine.name}/)
        expect($stdout.string).to match(/#{winrm_config.host}/)
        expect($stdout.string).to match(/#{winrm_config.port}/)
        expect($stdout.string).to match(/#{winrm_config.username}/)
        expect($stdout.string).to match(/#{winrm_config.password}/)
      ensure
        $stdout = STDOUT
      end
    end

    it 'ouputs the WinRMConfig with custom host key when --host is provided' do
      c = VagrantPlugins::VagrantWinRM::WinRMConfig.new(['--host', 'custom_host_key', 'vagrant'], env)
      begin
        $stdout = StringIO.new
        expect(c.execute).to be_zero
        expect($stdout.string).to match(/custom_host_key/)
        expect($stdout.string).to match(/#{winrm_config.host}/)
        expect($stdout.string).to match(/#{winrm_config.port}/)
        expect($stdout.string).to match(/#{winrm_config.username}/)
        expect($stdout.string).to match(/#{winrm_config.password}/)
      ensure
        $stdout = STDOUT
      end
    end
  end
end
