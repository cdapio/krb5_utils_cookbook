require 'spec_helper'

describe 'krb5_utils::default' do
  context 'on Centos 6.6 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['krb5']['krb5_conf']['libdefaults']['default_realm'] = 'EXAMPLE.COM'
        node.override['krb5_utils']['krb5_service_keytabs'] = {
          'HTTP' => { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' },
          'hdfs' => { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' }
        }
        node.override['krb5_utils']['krb5_user_keytabs'] = {
          'yarn' => { 'owner' => 'yarn', 'group' => 'hadoop', 'mode' => '0640' }
        }
        stub_command(/kadmin -w password -q/).and_return(false)
        stub_command(/test -e /).and_return(false)
      end.converge(described_recipe)
    end

    it 'installs kstart package' do
      expect(chef_run).to install_package('kstart')
    end
  end
end
