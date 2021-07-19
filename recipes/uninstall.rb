########################################################################################################################
#                                                                                                                      #
#                                IEM agent recipe for IEM9 Cookbook                                                    #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.07.2016                                                                                   #
#   Date Last Update    : 23.09.2016                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

case node['platform']
when 'redhat' || 'windows'
  ibm_iem9_iemagent 'uninstall-IEM-agent' do
    action [:uninstall]
  end

when 'aix'
  ibm_iem9_iemagentaix 'uninstall-IEM-agent' do
    action [:uninstall]
  end
end