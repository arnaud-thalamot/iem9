
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

if node['platform'] == 'aix'
  # default user to install IEM
  default['iem']['user'] = 'root'
  # location to copy IEM installer tar file
  default['iem']['tarDir'] = '/IEMAGENT'
  # rpm package for IEM agent for 64 bit
  default['iem']['package_rpm'] = 'BESAgent-9.2.5.130.ppc64_aix61.pkg'
  # rpm package for IEM agent for 32 bit
  default['iem']['package_32rpm'] = 'BESAgent-9.2.5.130.ppc64_aix61.pkg'
  default['iem']['actionsite_afxm_path'] = '/etc/opt/BESClient'
  # URL to download IEM installer
  default['iem']['url'] = 'https://client.com/ibm/aix7/iem/BESAgent-9.2.5.130.ppc64_aix61.pkg'
  # repository url to download IEM binaries
  default['iem']['url_installer'] = 'https://client.com/ibm/aix7/iem/BESAgent-9.2.5.130.ppc64_aix61.pkg'
  # repository url to download besclient.conf file
  default['iem']['url_besclient'] = 'https://client.com/ibm/aix7/iem/besclient.config'
  # repository url to download actionsite.afxm file
  default['iem']['url_actionsite'] = 'https://client.com/ibm/aix7/iem/actionsite.afxm'
  # cpu architecture of the node
  default['iem']['cpuarch'] = node['kernel']['machine']
  # base package for IEM installer
  default['iem']['iem_base_pkj'] = 'IEM_Pltfrm_Install_V91.zip'

  # default['iem']['InstallDir'] = ""
  # IEM configuration file actionsite.afxm for communicatng with the IEM server
  default['iem']['actionsite'] = 'actionsite.afxm'

  # actionsite.afxm file location
  default['iem']['actionsite_path'] = '/etc/opt/BESClient'

  # IEM configuration file required for starting IEM agent service on the node
  default['iem']['besclient'] = 'besclient.config'

  # besclient.conf file location
  default['iem']['besclient_path'] = '/var/opt/BESClient'

  # rpm package name for installing IEM agent
  # default['iem']['package_rpm'] = 'BESAgent-9.2.5.130-rhe5.x86_64.rpm'
  default['iem']['package_aix'] = 'BESAgent-9.2.5.130.ppc64_aix61.pkg'
  # installation status checker
  default['iem']['install_status'] = ''
end
