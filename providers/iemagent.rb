########################################################################################################################
#                                                                                                                      #
#                                IEM agent provider for IEM9 Cookbook                                                  #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.06.2016                                                                                   #
#   Date Last Update    : 31.07.2016                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################
require 'chef/resource'

use_inline_resources

def whyrun_supported?
  true
end

action :install do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
      install_iem9
    else
      node.default['iem']['install_status'] = 'fail'
      #check_prereq
      install_iem9
    end
  end
end

action :start do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'redhat' || 'aix'
      start_besclient
    end
  end
end

action :validate do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    # validating on linux
  when 'redhat'
   ruby_block 'validate-log-file' do
    log_date = Time.new.strftime("%Y%m%d")
    log_path = '/var/opt/BESClient/__BESData/__Global/Logs/'
    log_file_name =  log_path.to_s + log_date.to_s + '.log'
    Chef::Log.info('Checking log : ' + log_file_name.to_s)
    block do
      if ::File.readlines(log_file_name.to_s).grep(/General transport failure/).size > 0
        Chef::Log.error('IEM Agent Registration Failed or already registered !!')
        Chef::Log.error('Please check /var/opt/BESClient/besclient.config for configuration settings ')
      else
        Chef::Log.info('IEM Agent Registration Success !!')
      end
    end
    action :run
    only_if { ::File.exist?(log_file_name.to_s) }
  end
    # validating on aix
  when 'aix'
   ruby_block 'validate-log-file' do
    log_date = Time.new.strftime('%Y%m%d')
    log_path = '/var/opt/BESClient/__BESData/__Global/Logs/'
    log_file_name = log_path.to_s + log_date.to_s + '.log'
    block do
      if ::File.readlines(log_file_name.to_s).grep(/General transport failure/)
        Chef::Log.error('IEM Agent Registration Failed or already registered !!')
      else
        Chef::Log.info('IEM Agent Registration Success !!')
      end
    end
    action :run
    only_if { ::File.exist?(log_file_name.to_s) }
  end
end
end
end

def check_prereq
  case node['platform']
  when 'redhat' || 'aix'
    # recipe to check prerequisites for iem installation

    Chef::Log.info('----------------------------------')
    Chef::Log.info('Checking for prerequisites........')

    # Check if root
    Chef::Log.info(node['iem']['user'])

    check_root = IO.popen("who am i | awk '{ print $1 }'").readlines.join.chomp
    if !check_root == 'root'
      Chef::Log.info('Current User : ' + check_root.to_s)
      Chef::Log.error('Require root user or user with sudo rights for installation. Aborting!!')
      return
    else
      Chef::Log.info('User : ' + check_root.to_s + ' is available with sudo access')
    end

    # verify for existing installation
    agent_status = shell_out("rpm -qa |grep BESAgent").stdout
    if "#{agent_status}".include?("BESAgent")
      Chef::Log.error('IEM Agent already exist ...........Nothing to do')
      node.default['iem']['install_status'] = 'fail'
    else
      Chef::Log.info('IEM agent is not installed...........Proceed with installation')
    end
  end
end

# creating prerequisite File System
def create_fs
  Chef::Log.info('Creating File System ...................')

  # creating prerequisite FS
  # create volume group ibmvg as mandatory requirement
  execute 'create-VG-ibmvg' do
    command 'mkvg -f -y ibmvg hdisk1'
    action :run
    returns [0, 1]
    not_if { shell_out('lsvg | grep ibmvg').stdout.chop != '' }
  end

   # required FS
   volumes = [
    { lvname: 'lv_iem_var', fstype: 'jfs2', vgname: 'ibmvg', size: 3072, fsname: '/var/opt/BESClient' }
  ]
      # Custom FS creation
      volumes.each do |data|
        ibm_iem9_makefs "creation of #{data[:fsname]} file system" do
          lvname data[:lvname]
          fsname data[:fsname]
          vgname data[:vgname]
          fstype data[:fstype]
          size data[:size]
        end
      end
    end

    def install_iem9
      case node['platform']
      when 'windows'
        if ::File.exist?("#{node['iem']['alreadyInstalledFile']}")
          Chef::Log.info ("IEM is already install, nothing to install for IEM agent")   
        else
      # Create temp directory where we copy/create source files to install tad4d agent
      directory "#{node['iem']['temp']}".to_s do
        action :create
      end
      # get iem agent media to our temp dir
      remote_file node['iem']['IEMfile_Path'].to_s do
        source node['iem']['IEMfile_Path'].to_s
        path "#{node['iem']['temp']}#{node['iem']['iem_file']}"
        action :create
      end      
      
      # get iem agent media to our temp dir
      media = "#{node['iem']['temp']}#{node['iem']['iem_file']}"
      Chef::Log.info ("media: #{media}")
      
      # Unpack media
      ruby_block 'unzip-install-file' do
        block do
          Chef::Log.info ('unziping the iem Installer file')
          cmd = powershell_out("cd #{node['iem']['temp']} ; tar -xvf #{media}")
          action :create
        end
      end
      Chef::Log.info('Performing IEM agent installation...')
      execute 'Install_IEM' do
        command "C:\\iem_temp\\BigFix-BES-Client-9.5.9.62.exe /s /v/qn /VINSTALLDIR=C:\\IBM\\IEM"
        action :run
      end
      ruby_block 'validate-log-file' do
        Chef::Log.info('Validating the IEM Registration')
        Chef::Log.info('Sleeping for two minutes to verify the log file for regstration')
        sleep(300)
        date = Time.new.strftime("%Y%m%d")
        log_path = 'C:\\IBM\\IEM\\__BESData\\__Global\\Logs\\'
        log_file =  "#{log_path}#{date}.log"
        Chef::Log.info("log_file: #{log_file}")
        block do
          if ::File.readlines(log_file).grep(/General transport failure/)
            Chef::Log.info("IEM Agent Registration Failed, Please check log file: #{log_file}")
          else
            Chef::Log.error('IEM Agent Registration Success....')
          end
        end
        action :run
        only_if { ::File.exist?("#{log_file}") }
      end
      # Deleting the Temp file
      directory "#{node['iem']['temp']}".to_s do
        recursive true
        action :delete
      end  
    end
  when 'redhat'
    if node['iem']['install_status'].to_s != 'fail'
      # recipe to check if required attributes are present and then install iem
      Chef::Log.info('-------------------------------------')
      Chef::Log.info('Start executing recipe install_iem9\n')
      Chef::Log.info('Checking System Architecture......')

      if node['iem']['cpuarch'] == 'x86'
        node.default['iem']['package_rpm'] = node['iem']['package_32rpm']
      end

      # create temporary folder for installer files
      temp_folder = '/tmp/iem_software'
      directory temp_folder.to_s do
        owner 'root'
        group 'root'
        mode 755
        action :create
        recursive true
      end

      # Creating directory to copy the actionsite.afxm
      Chef::Log.info('Creating directory for actionsite-afxm configuration file')
      directory "Creating #{node['iem']['actionsite_afxm_path']}" do
        path node['iem']['actionsite_afxm_path'].to_s
        action :create
        recursive true
        not_if { ::File.directory?(node['iem']['actionsite_afxm_path']) }
      end

      actionsite = node['iem']['actionsite_path'].to_s + '/' + node['iem']['actionsite'].to_s
      # copy config file if config_file name set to anything other than 'none'
      remote_file actionsite.to_s do
        source node['iem']['url_actionsite'].to_s
        mode '600'
        action :create_if_missing
      end

      # Creating directory to copy the besclient.config configuration file
      Chef::Log.info('Creating directory for besclient.conf configuration file')
      directory "Creating #{node['iem']['besclient_path']}" do
        path node['iem']['besclient_path'].to_s
        action :create
        recursive true
        not_if { ::File.directory?(node['iem']['besclient_path']) }
      end

      besclient = node['iem']['besclient_path'].to_s + '/' + node['iem']['besclient'].to_s
      # copy the besclient config file
      remote_file besclient.to_s do
        source node['iem']['url_besclient'].to_s
        mode '755'
        action :create_if_missing
      end

      Chef::Log.info('Copying the IEM Agent installer ...........')
      remote_file temp_folder.to_s + '/' + node['iem']['package_rpm'].to_s do
        source node['iem']['url_installer'].to_s
        mode 755
        action :create_if_missing
      end

      # Install the package rpms
      Chef::Log.info('Installing RPM package .......')

      rpm_package node['iem']['package_rpm'].to_s do
        source temp_folder.to_s + '/' + node['iem']['package_rpm'].to_s
        action :install
      end

      # set attribute installation status as pass
      node.default['iem']['install_status'] = 'pass'

	  # Deleting the temporary directory
    directory temp_folder.to_s do
     recursive true
     action :delete
   end
 else
  Chef::Log.error('IEMagent already exist.........skipping installation. Please remove the existing installation and try again')
end

  # installing IEM Agent on AIX
when 'aix'
    # install IEM agent if not already installed
    if node['iem']['install_status'].to_s != 'fail'
      # recipe to check if required attributes are present and then install iem
      Chef::Log.info('-------------------------------------')
      Chef::Log.info('Start executing recipe install_iem9_linux.rb\n')
      Chef::Log.info('Checking System Architecture......')

      if node['iem']['cpuarch'] == 'x86'
        node.default['iem']['package_rpm'] = node['iem']['package_32rpm']
      end
      create_fs
      # Creating directory to copy the binaries and configuration files
      temp_folder = '/tmp/iem_software'

      Chef::Log.info('Creating directory for binaries and configuration file')
      directory temp_folder.to_s do
        owner 'root'
        mode 755
        action :create
        recursive true
        not_if { ::File.directory?(temp_folder.to_s) }
      end

      # Creating directory to copy the actionsite.afxm configuration file
      Chef::Log.info('Creating directory for actionsite.afxm configuration file')
      directory node['iem']['actionsite_path'].to_s do
        action :create
        recursive true
        not_if { ::File.directory?(node['iem']['actionsite_path']) }
      end

      # actionsite config file path
      actionsite = node['iem']['actionsite_path'].to_s + '/' + node['iem']['actionsite'].to_s
      # copy config file actionsite.afxm to temp directory
      remote_file actionsite.to_s do
        source node['iem']['url_actionsite'].to_s
        owner 'root'
        mode '600'
        action :create_if_missing
      end

      # Creating directory to copy the besclient.config configuration file
      Chef::Log.info('Creating directory for besclient.conf configuration file')
      directory node['iem']['besclient_path'].to_s do
        action :create
        recursive true
        not_if { ::File.directory?(node['iem']['besclient_path']) }
      end

      besclient = node['iem']['besclient_path'].to_s + '/' + node['iem']['besclient'].to_s
      # copy the besclient config file
      remote_file besclient.to_s do
        source node['iem']['url_besclient'].to_s
        owner 'root'
        mode '755'
        action :create_if_missing
      end

      Chef::Log.info('Copying the IEM Agent installer ...........')
      iem_installer = temp_folder.to_s + '/' + node['iem']['package_rpm'].to_s
      remote_file iem_installer.to_s do
        source node['iem']['url_installer'].to_s
        owner 'root'
        mode '755'
        action :create_if_missing
      end

      # Install the package rpms
      Chef::Log.info('Installing IEM package .......')

      # installing IEM agent
      execute 'install-IEM' do
        Chef::Log.debug('Installing IEM...............')
        command "installp -agqYXd #{temp_folder}/BESAgent-9.2.5.130.ppc64_aix61.pkg BESClient"
        action :run
      end

      node.default['iem']['install_status'] = 'pass'
      Chef::Log.debug('IEM Agent installation Complete !!')

      # Deleting the temporary directory and files
      directory temp_folder.to_s do
        Chef::Log.debug('Cleaning the temporary files...............')
        recursive true
        action :delete
      end
    else
      Chef::Log.error('IEMagent already installed.........skipping installation. Please remove the existing installation and try again')
    end
  end
end

def start_besclient
  case node['platform']
  when 'redhat'
    # starting the IEM agent
    Chef::Log.info('Starting IEM Agent service..........')

    # get the current service status
    service_status = shell_out('service besclient status').stdout
    # start besclient service if it is not running
    service 'besclient' do
      supports :status => true
      action :start
      only_if { "#{service_status}".include?('BESClient is stopped') }
    end

  when 'aix'
    # starting the IEM agent
    if node['iem']['install_status'] == 'pass'
      Chef::Log.info('Starting IEM Agent service..........')

      execute 'start-besclient-service' do
        command '/etc/rc.d/rc2.d/SBESClientd start'
        action :run
      end
    else
      Chef::Log.warn('Nothing to do ..........Skipping agent service start !')
    end
  end
end

action :uninstall do
  converge_by("Create #{@new_resource}") do
    uninstall_iem9
  end
end

def uninstall_iem9
  case node['platform']
  when 'windows'
    # uninstall the IEM agent
    Chef::Log.info('Uninstall IEM Agent ..........')
    if ::File.exist?(node['iem']['alreadyInstalledFile'].to_s)
      windows_package 'IBM Endpoint Manager Client' do
        action :remove
      end
      # Deleting the installation directory
      directory node['iem']['InstalledPath'].to_s do
        recursive true
        action :delete
      end
    else
      Chef::Log.info('iem is not install, nothing to uninstall for IEM agent')
    end

  # uninstalling on redhat
when 'redhat'
    # uninstalling IEM agent
    Chef::Log.info('Uninstalling IEM agent .........')

    # stop the besclient service first
    service 'besclient' do
      action :stop
    end

    execute 'uninstall-IEM-agent' do
      command "rpm -e #{node['iem']['package_rpm_name']}"
      action :run
      only_if { shell_out("rpm -qa | grep #{node['iem']['package_rpm_name']}").stdout.chop != '' }
    end

    # Deleting the IEM installed directory and logs directory
    Chef::Log.info('Cleaning IEM Agent ............')

    directory node['iem']['besclient_path'].to_s do
      recursive true
      action :delete
    end

    directory node['iem']['actionsite_path'].to_s do
      recursive true
      action :delete
    end

  # uninstalling on Aix
when 'aix'
    # uninstalling IEM agent
    Chef::Log.info('Uninstalling IEM agent .........')

    # verify installation exist on the node
    install_status = shell_out('lslpp -l |grep BESClient').stdout
    if "#{install_status}".include?('BESClient                9.2.5.130  COMMITTED  IBM Endpoint Manager Agent')

      Chef::Log.info('IEM installation ............Verified !.........Proceed with uninstatllation')
      # stop the besclient service first
      execute 'start-besclient-service' do
        command '/etc/rc.d/rc2.d/SBESClientd stop'
        action :run
      end

      execute 'uninstall-IEM-agent' do
        command "installp -u #{node['iem']['package_aix_name']}"
        action :run
        only_if { shell_out("lslpp -l |grep BESClient").stdout.chop != '' }
      end

      # Deleting the IEM installed directory and logs directory
      Chef::Log.info('Cleaning IEM Agent ............')

      directory node['iem']['besclient_path'].to_s do
        recursive true
        action :delete
      end

      directory node['iem']['actionsite_path'].to_s do
        recursive true
        action :delete
      end
    else
      Chef::Log.error('IEM Installation does not exist....Nothing to uninstall!!')
    end
  end
end
