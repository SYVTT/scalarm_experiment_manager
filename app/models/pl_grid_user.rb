##
# Module adds PL-Grid specific methods to ScalarmUser
module PlGridUser

  def pl_grid_user?
    PlGridUser.pl_grid_dn?(dn)
  end

  ##
  # Returns true if dn parameter matches PL-Grid user's format
  # example of DN: "/C=PL/O=PL-Grid/O=Uzytkownik/O=AGH/CN=Jakub Liput/CN=plgjliput"
  def self.pl_grid_dn?(dn)
    /\/C=PL\/O=PL-Grid\/O=.+\/O=.+\/CN=.+\/CN=.+/ =~ dn
  end

end