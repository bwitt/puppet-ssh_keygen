# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh_keygen' do
  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<~PUPPET
        user { 'john':
          ensure     => present,
          managehome => true,
        }

        ssh_keygen { 'john': }

        ssh_keygen { 'root_ed25519':
          user    => 'root',
          type    => 'ed25519',
          comment => 'root key',
        }
      PUPPET
    end
  end

  describe file('/home/john/.ssh/id_rsa') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'john' }
    it { is_expected.to be_mode 600 }
  end

  describe file('/home/john/.ssh/id_rsa.pub') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'john' }
    it { is_expected.to be_mode 644 }
    its(:content) { is_expected.to match %r{\Assh-rsa } }
  end

  describe file('/root/.ssh/id_ed25519') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_mode 600 }
  end

  describe file('/root/.ssh/id_ed25519.pub') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match %r{\Assh-ed25519 \S+ root key$} }
  end

  describe command('ssh-keygen -l -f /home/john/.ssh/id_rsa.pub') do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match %r{\(RSA\)$} }
  end
end
