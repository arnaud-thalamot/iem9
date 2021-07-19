########################################################################################################################
#                                                                                                                      #
#                                IEM agent recipe for IEM9 Cookbook                                                    #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.07.2016                                                                                   #
#   Date Last Update    : 01.08.2016                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################
case node['platform']
when 'windows'
  # install, validate installation and start IEM service
  ibm_iem9_iemagent 'install-start-IEM-agent' do
    action [:install, :start]
  end
# install, validate and start IEM services on aix and linux
when 'redhat'
  ibm_iem9_iemagent 'install-start-IEM-agent' do
    action [:install, :start, :validate]
  end
when 'aix'
  ibm_iem9_iemagent 'install-start-IEM-agent' do
    action [:install, :start, :validate]
  end
end


node.set['iem']['status'] = 'success'

