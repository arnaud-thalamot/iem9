# verify if root user exist
describe user('root') do
  it { should exist }
  its('group') { should eq 'root' }
end

# check if the directory exist for actionsite.afxm configuration file and have required permissions
describe file('/etc/opt/BESClient') do
  it { should exist }
  its('type') { should eq :directory }
  it { should be_directory }
  it { should be_owned_by 'root' }
end

# check if the directory exist for IEM installer tar file and required ownership
describe file('/IEMAGENT') do
  it { should exist }
  its('type') { should eq :directory }
  it { should be_directory }
  it { should be_owned_by 'root' }
end

# check if actionsite.afxm configuration file exist and have required permissions
describe file('/etc/opt/BESClient/actionsite.afxm') do
  it { should exist }
  it { should be_file }
  # its('owner') { should eq 'root' }
  it { should be_owned_by 'root' }
  its('mode') { should cmp '0600' }
end

# check if besclient.conf configuration file exist and have required permissions
describe file('/var/opt/BESClient/besclient.config') do
  it { should exist }
  it { should be_file }
  its('owner') { should eq 'root' }
  it { should be_owned_by 'root' }
  its('mode') { should cmp '0644' }
end

# check if the package IEM Agent package is installed
describe package('BESAgent') do
  it { should be_installed }
  its('version') { should eq '9.2.5.130-rhe5' }
end

# check if besclient service is installed and enabled
describe service('besclient') do
  it { should be_installed }
  it { should be_enabled }
end

# check if the besclient service is running
describe bash('service besclient status') do
  its('stdout') { should match '/running/' }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end
