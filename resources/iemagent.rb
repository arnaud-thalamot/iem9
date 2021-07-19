########################################################################################################################
#                                                                                                                      #
#                               IEM agent resource for IEM9 Cookbook                                                   #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.03.2016                                                                                   #
#   Date Last Update    : 01.03.2016                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

actions :install, :start, :validate, :uninstall

def initialize(*args)
  super
  @action = :install
end
