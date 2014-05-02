require 'spec_helper'

describe 'krb5_utils::default' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['krb5_utils']['krb5_service_keytabs'] = {
          'HTTP' => { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' },
          'hdfs' => { 'owner' => 'hdfs', 'group' => 'hadoop', 'mode' => '0640' }
        }
        node.default['krb5_utils']['krb5_user_keytabs'] = {
          'yarn' => { 'owner' => 'yarn', 'group' => 'hadoop', 'mode' => '0640' }
        }
      end.converge(described_recipe)
    end

    it 'creates /etc/security/keytabs directory' do
      expect(chef_run).to create_directory('/etc/security/keytabs')
    end

    %w(kdestroy kinit-as-admin-user).each do |exec|
      it "executes #{exec} resource" do
        expect(chef_run).to run_execute(exec)
      end
    end

  end
end
