require 'spec_helper'
require 'stringio'

describe VagrantPlugins::VagrantWinRM::WinRMUpload, :unit => true do

=begin ############
# Here we mock!
=end ##############

  let(:idx) { double('idx') }
  let(:communicator) { double('communicator') }
  let(:config_vm) { double('config_vm', communicator: :winrm) }
  let(:machine_config) { double('machine_config', vm: config_vm) }
  let(:machine) { double('machine', config: machine_config, name: 'vagrant', provider: 'virtualbox', config: machine_config, communicate: communicator, state:nil, ui: double('ui', opts: {})) }
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
    allow(env).to receive(:machine) do |name, provider|
      machine if :vagrant == name
    end
  end

=begin ############
# Here we test!
=end ##############
  describe 'execute' do
    it 'raises error ''invalid usage'' on bad usage' do
      c = VagrantPlugins::VagrantWinRM::WinRMUpload.new([], env)
      expect { c.execute }.to raise_error(Vagrant::Errors::CLIInvalidUsage)
    end

    it 'raises error ''invalid options'' on unknown option' do
      c = VagrantPlugins::VagrantWinRM::WinRMUpload.new(['--unknown'], env)
      expect { c.execute }.to raise_error(Vagrant::Errors::CLIInvalidOptions)
    end

    it 'displays help message with option --help' do
      c = VagrantPlugins::VagrantWinRM::WinRMUpload.new(['--help'], env)
      expect {
        expect(c.execute).to be_nil
      }.to output.to_stdout
    end

    it 'raises error when communicator not winrm' do
      c = VagrantPlugins::VagrantWinRM::WinRMUpload.new(['source', 'destination'], env)
      expect(config_vm).to receive(:communicator).and_return :ssh

      expect { c.execute }.to raise_error(VagrantPlugins::VagrantWinRM::Errors::ConfigurationError, /not configured to communicate through WinRM/)
    end

    it 'raises error on unknown target' do
      c = VagrantPlugins::VagrantWinRM::WinRMUpload.new(['source', 'destination', 'unknownTarget'], env)
      expect { c.execute }.to raise_error Vagrant::Errors::VMNotFoundError
    end


    it 'passes source and destination to communicator with no target' do
      c = VagrantPlugins::VagrantWinRM::WinRMUpload.new(['source', 'destination'], env)
      expect(communicator).to receive(:upload).with('source', 'destination').and_return 0

      expect {
        expect(c.execute).to be_zero
      }.not_to output.to_stdout
    end

    it 'passes source and destination to communicator even with a specific target' do
      c = VagrantPlugins::VagrantWinRM::WinRMUpload.new(['source', 'destination', 'vagrant'], env)
      expect(communicator).to receive(:upload).with('source', 'destination').and_return 0
      expect {
        expect(c.execute).to be_zero
      }.not_to output.to_stdout
    end
  end
end
