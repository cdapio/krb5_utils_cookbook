require 'spec_helper'

describe 'krb5_utils::generate_keytabs' do
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

    it 'creates /etc/security/keytabs directory' do
      expect(chef_run).to create_directory('/etc/security/keytabs')
    end

    %w(krb5-addprinc krb5-check).each do |execute|
      %w(HTTP/fauxhai.local hdfs/fauxhai.local yarn).each do |princ|
        it "executes #{execute}-#{princ}@EXAMPLE.COM" do
          expect(chef_run).to run_execute("#{execute}-#{princ}@EXAMPLE.COM")
        end
      end
    end

    %w(HTTP.service hdfs.service yarn).each do |princ|
      it "executes krb5-generate-keytab-#{princ}.keytab" do
        expect(chef_run).to run_execute("krb5-generate-keytab-#{princ}.keytab")
      end
      it "creates file /etc/security/keytabs/#{princ}.keytab" do
        expect(chef_run).not_to create_file("/etc/security/keytabs/#{princ}.keytab")
      end
    end
  end
end
