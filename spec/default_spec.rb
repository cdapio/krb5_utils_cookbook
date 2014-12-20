require 'spec_helper'

describe 'krb5_utils::default' do
  context 'on Centos 6.5 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.5) do |node|
        node.automatic['domain'] = 'example.com'
        node.override['krb5']['krb5_conf']['libdefaults']['default_realm'] = 'EXAMPLE.COM'
        node.override['krb5_utils']['krb5_service_keytabs'] = {
          'HTTP' => { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' },
          'hdfs' => { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' }
        }
        node.override['krb5_utils']['krb5_user_keytabs'] = {
          'yarn' => { 'owner' => 'yarn', 'group' => 'hadoop', 'mode' => '0640' }
        }
        stub_command("kadmin -w password -q 'list_principals' | grep -v Auth | grep '^HTTP/fauxhai.local@EXAMPLE.COM'").and_return(false)
        stub_command("kadmin -w password -q 'list_principals' | grep -v Auth | grep '^hdfs/fauxhai.local@EXAMPLE.COM'").and_return(false)
        stub_command("kadmin -w password -q 'list_principals' | grep -v Auth | grep '^yarn@EXAMPLE.COM'").and_return(false)
        stub_command('test -e /etc/security/keytabs/HTTP.service.keytab').and_return(false)
        stub_command('test -e /etc/security/keytabs/hdfs.service.keytab').and_return(false)
        stub_command('test -e /etc/security/keytabs/yarn.keytab').and_return(false)
      end.converge(described_recipe)
    end

    it 'installs kstart package' do
      expect(chef_run).to install_package('kstart')
    end

    it 'creates /etc/security/keytabs directory' do
      expect(chef_run).to create_directory('/etc/security/keytabs')
    end

    %w(kdestroy kinit-as-admin-user).each do |exec|
      it "executes #{exec} resource" do
        expect(chef_run).to run_execute(exec)
      end
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
