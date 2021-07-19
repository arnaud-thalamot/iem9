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

#IEM agent installation execution status
default['iem']['status'] = 'failure'

case node['platform']
when 'redhat'
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
  default['iem']['package_rpm'] = 'BESAgent-9.2.5.130-rhe5.x86_64.rpm'
  default['iem']['package_rpm_name'] = 'BESAgent-9.2.5.130-rhe5.x86_64'

when 'windows'
  # Remote location for IEM installer file
  default['iem']['IEMfile_Path'] = 'https://pulp.cma-cgm.com/ibm/windows2012R2/iem/BigFix-BES-Client-9.5.9.62.zip'
  # IEM installer native file
  default['iem']['iem_file'] = 'BigFix-BES-Client-9.5.9.62.zip'
  # Temp file where we copy the IEM installer
  default['iem']['temp'] = 'C:\\iem_temp\\'
  # Installed Path for iem agent
  default['iem']['InstalledPath'] = 'C:\\PROGRA~1\\IBM\\IEM'
  # Path for IEM agent installed
  default['iem']['alreadyInstalledFile'] = 'C:\\PROGRA~1\\IBM\\IEM\\BESClient.exe'

end
