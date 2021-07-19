########################################################################################################################
#                                                                                                                      #
#                                IEM agent attributes for IEM9 Cookbook                                                #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.07.2016                                                                                   #
#   Date Last Update    : 01.08.2016                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

if node['platform'] == 'redhat'
  # default user for installing IEM
  default['iem']['user'] = 'root'
  # location to copy IEM installer tar file
  default['iem']['tarDir'] = '/IEMAGENT'
  # rpm package for IEM agent for 64 bit
  default['iem']['package_rpm'] = 'BESAgent-9.2.5.130-rhe5.x86_64.rpm'
  # rpm package for IEM agent for 32 bit
  default['iem']['package_32rpm'] = 'BESAgent-9.2.5.130-rhe5.i686.rpm'
  default['iem']['actionsite_afxm_path'] = '/etc/opt/BESClient'
  # URL to download IEM installer
  default['iem']['url'] = 'https://software.bigfix.com/download/bes/92/BESAgent-9.2.5.130-rhe5.x86_64.rpm'
  # repository url to download IEM binaries
  default['iem']['url_installer'] = 'https://client.com/ibm/redhat7/iem/BESAgent-9.2.5.130-rhe5.x86_64.rpm'
  # repository url to download besclient.conf file
  default['iem']['url_besclient'] = 'https://client.com/ibm/redhat7/iem/besclient.config'
  # repository url to download actionsite.afxm file
  default['iem']['url_actionsite'] = 'https://client.com/ibm/redhat7/iem/actionsite.afxm'
end
