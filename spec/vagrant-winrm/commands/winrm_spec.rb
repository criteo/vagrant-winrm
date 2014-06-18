require 'spec_helper'
require 'stringio'

describe VagrantPlugins::VagrantWinRM::WinRM, :unit => true do

=begin ############
# Here we mock!
=end ##############

  let(:idx) { double('idx') }
  let(:communicator) { double('communicator') }
  let(:config_vm) { double('config_vm', communicator: :winrm) }
  let(:machine_config) { double('machine_config', vm: config_vm) }
  let(:machine) { double('machine', config: machine_config, name: 'vagrant', provider: 'virtualbox', config: machine_config, communicate: communicator, ui: double('ui', opts: {})) }
  let(:env) { double('env', root_path: '', home_path: '', ui_class: '', machine_names: [machine.name], active_machines: [machine], machine_index: idx, default_provider: 'virtualbox') }

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
    allow(env).to receive(:machine).with(any_args, :virtualbox) do |name, provider|
      machine if :vagrant == name
    end
  end

=begin ############
# Here we test!
=end ##############
  describe 'execute' do
    it 'does nothing with no option' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new([], env)
      expect {
        expect(c.execute).to be_zero
      }.not_to output.to_stdout
    end

    it 'gives proper version with option --plugin-version' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['--plugin-version'], env)
      expect {
        expect(c.execute).to be_zero
      }.to output("Vagrant-winrm plugin 0.0.1\n").to_stdout
    end

    it 'displays help message with option --help' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['--help'], env)
      expect {
        expect(c.execute).to be_nil
      }.to output.to_stdout
    end

    it 'raises error when communicator not winrm' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['-c', 'dummyCommand'], env)
      expect(config_vm).to receive(:communicator).and_return :ssh

      expect { c.execute }.to raise_error(VagrantPlugins::VagrantWinRM::Errors::ConfigurationError, /not configured to communicate through WinRM/)
    end

    it 'raises error on unknown target' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['-c', 'command1', 'unknownTarget'], env)
      expect { c.execute }.to raise_error(Vagrant::Errors::VMNotFoundError)
    end

    it 'raises error ''invalid options'' on unknown option' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['--unknown'], env)
      expect { c.execute }.to raise_error(Vagrant::Errors::CLIInvalidOptions)
    end

    it 'passes commands to communicator with no target' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['-c', 'command1', '--command', 'command2', '-c', 'command3', '--command', 'command4'], env)

      expect(communicator).to receive(:execute).ordered.with('command1').and_return 0
      expect(communicator).to receive(:execute).ordered.with('command2').and_return 0
      expect(communicator).to receive(:execute).ordered.with('command3').and_return 0
      expect(communicator).to receive(:execute).ordered.with('command4').and_return 0

      expect {
        expect(c.execute).to be_zero
      }.not_to output.to_stdout
    end

    it 'passes commands to communicator even with a specific target' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['-c', 'command5', '--command', 'command6', '-c', 'command7', '--command', 'command8', 'vagrant'], env)
      expect(communicator).to receive(:execute).ordered.with('command5').and_return 0
      expect(communicator).to receive(:execute).ordered.with('command6').and_return 0
      expect(communicator).to receive(:execute).ordered.with('command7').and_return 0
      expect(communicator).to receive(:execute).ordered.with('command8').and_return 0
      expect {
        expect(c.execute).to be_zero
      }.not_to output.to_stdout
    end

    it 'redirects winrm outputs to stdout' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['-c', 'command'], env)

      expect(communicator).to receive(:execute).with('command').and_yield(:stdout, 'output message').and_return 0
      expect {
        expect(c.execute).to be_zero
      }.to output('output message').to_stdout
    end

    it 'redirects winrm errors to stderr' do
      c = VagrantPlugins::VagrantWinRM::WinRM.new(['-c', 'command'], env)

      expect(communicator).to receive(:execute).with('command').and_yield(:stderr, 'error message').and_return 0
      expect {
        expect(c.execute).to be_zero
      }.to output('error message').to_stderr
    end
  end
end
