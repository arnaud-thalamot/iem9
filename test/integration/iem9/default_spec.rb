
# check if the directory exist for IEM installer zipfile
describe file('C:\\iem_temp') do
  it { should exist }
  its('type') { should eq :directory }
  it { should be_directory }
end

# check if actionsite.afxm configuration file exist in temp directory
describe file('C:\\iem_temp\\actionsite.afxm') do
  it { should exist }
  its('type') { should eq file }
  its('mode') { should eq 0600 }
end

# check if besclient.conf configuration file exist in temp directory
describe file('C:\\iem_temp\\besclient.config') do
  it { should exist }
  its('type') { should eq file }
  its('mode') { should eq 0755 }
end

# check if the package IEM Agent package is installed
describe package('IBM Endpoint Manager Client') do
  it { should be_installed }
  its('version') { should eq 9.2 }
end

# check if besclient service is running and enabled
describe service('besclient') do
  it { should be_enabled }
  it { should be_running }
end
