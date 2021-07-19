IEM9 Cookbook

The IEM 9 cookbook verifies the prerrequisites for IEM agent installation. On successful verification of the prerequisites it will install the IEM version 9.0 on the system.
It performs post-install configuration for the IEM agent. It defines the configuration files, locates and copy it on the required path in the system. 
It will further register the IEM agent to the IEM server and on successful registration the agent downloads the fixlets as set in the IEM server.
and also contains the recipe to uninstall the IEMM agent

Requirements

- Storage : 2 GB
- RAM : 2 GB
- Versions
	- Chef Development Kit Version: 0.17.17
	- Chef-client version: 12.13.37
	- Kitchen version: 1.11.1

Platforms

    RHEL-7, WINDOWS2012

Chef

    Chef 11+

Cookbooks

    none

Resources/Providers

- iemagent
	This iemagent resource/provider performs the following :-
	For Linux:
	1. Check the prerequisites
	   - Verifies if the user 'root' is used for installing the agent
	   - Verifies the architeture of the node in order to utilize specific rpm file for installation
	2. Creates necessary directories for 
	   - copying the IEM Native file
	   - copying the configuration files actionsite.afxm and besclient.config
	3. Extracting the IEM installer Native binary to fetch the required rpm file for installation
	4. Install the IEM rpm v9.2.5.130 from temporary directory
	5. Copy the configuration files actionsite.afxm and besclient.config to path /etc/opt/BESClient and /var/opt/BESClient
	6. Start the Besclient service and register the agent on IBM Endpoint Manager Server
	
	For Windows:
    1. Creates necessary directories for 
	   - copying the IEM Native file
	   - copying the configuration files actionsite.afxm and besclient.config
	2. Extracting the IEM installer Native binary to fetch the required setup file for installation
	3. Install the IEM installer v9.2.5.130 from temporary directory
	4. Copy the configuration files actionsite.afxm and besclient.config to path /etc/opt/BESClient and /var/opt/BESClient
	5. Start the Besclient service and register the agent on IBM Endpoint Manager Server
  6. also uninstall the iemagent.

Example

1. iemagent 'Install-Start-Register-IEM-Agent' do
	action :install, :start
end   

Actions

    :install - installs and configures the IEM agent
    :start - starts the IEM agent service BESClient and registers the agent to the IBM Endpoint Manager Server.


Recipes

    install_iem9:: The recipe installs the required version of IEM agent for linux and windows platform. 
      for linux,Performs prequite check and post-install configuration. It starts the agent service and register to the IEM server. The IEM agent installation and registration can be verified by IEM console.

2. iemagent 'uninstall-iem-agent' do
  action :uninstall
end   

Actions

    :uninstall - uninstall the IEM agent


Recipes

    uninstall_iem9:: The recipe uninstall the iem agent.

Attributes

The following attributes are set by default

for Linux:
  default['iem']['user'] = 'root'		# default user for installing IEM
  default['iem']['tarDir'] = '/IEMAGENT'		# location to copy IEM installer tar file
  default['iem']['package_rpm'] = 'BESAgent-9.2.5.130-rhe5.x86_64.rpm'	# rpm package for IEM agent for 64 bit
  default['iem']['package_32rpm'] = 'BESAgent-9.2.5.130-rhe5.i686.rpm'	# rpm package for IEM agent for 32 bit
  default['iem']['actionsite_afxm_path'] = '/etc/opt/BESClient'		# location to copy the actionsite.afxm file
  default['iem']['url'] = 'https://software.bigfix.com/download/bes/92/BESAgent-9.2.5.130-rhe5.x86_64.rpm'	# URL to download IEM installer

default['iem']['cpuarch'] = node['kernel']['machine']		# cpu architecture of the node
  default['iem']['iem_base_pkj'] = 'IEM_Pltfrm_Install_V91.zip'	# base package for IEM installer
  default['iem']['actionsite'] = 'actionsite.afxm'		# IEM configuration file actionsite.afxm for communicatng with the IEM server
  default['iem']['actionsite_path'] = '/etc/opt/BESClient'	# actionsite.afxm file location
  default['iem']['besclient'] = 'besclient.config'		# IEM configuration file required for starting IEM agent service on the node
  default['iem']['besclient_path'] = '/var/opt/BESClient'	# besclient.conf file location
  default['iem']['package_rpm'] = 'BESAgent-9.2.5.130-rhe5.x86_64.rpm'	# rpm package name for installing IEM agent

for windows:
 
default['iem']['native_file'] = 'BigFix-BES-Client-9.2.5.130.zip'   # IEM installer native file
  default['iem']['temp'] = 'C:\\iem_temp\\'   # Temp file where we copy the IEM installer
  default['iem']['InstalledPath'] = 'C:\\IBM\\IEM'    # Installed Path for iem agent
  default['iem']['alreadyInstalledFile'] = 'C:\\IBM\IEM\\BESClient.exe'     # Path for IEM agent installed

Usage

Put depends 'IEM9' in your metadata.rb to gain access to the iemagent resource.
