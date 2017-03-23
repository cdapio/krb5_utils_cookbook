name             'krb5_utils'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'Apache License, Version 2.0'
description      'Set of attribute-driven utility resources which can be used to setup Kerberos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.3'

depends 'krb5', '>= 1.0.4'
depends 'yum-epel'

%w(amazon centos debian redhat scientific ubuntu).each do |os|
  supports os
end

source_url 'https://github.com/caskdata/krb5_utils_cookbook' if respond_to?(:source_url)
issues_url 'https://issues.cask.co/browse/COOK/component/10602' if respond_to?(:issues_url)
