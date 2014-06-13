require 'openssl'
require 'base64'

require 'net/ssh'
require 'gsi/ssh'

require 'infrastructure_facades/infrastructure_errors'

class GridCredentials < MongoActiveRecord
  include SSHEnabledRecord

  @@CIPHER_NAME = 'aes-256-cbc'
  @@CIPHER_KEY = "tC\x7F\x9Er\xA6\xAFU\x88\x19\x9B\x0F\xDD\x88O]6\xA0\xAD\x8B\xBF,4\x06<\xC0[\x03\xC7\x11\x90\x10"
  @@CIPHER_IV = "\xA9\x8E\xD0\x031 w0\x1Ed\xEC\xC4\xD4\xEA\x87\e"

  def self.collection_name
    'grid_credentials'
  end

  def password
    if hashed_password
      decipher = GridCredentials::decipher
      password = decipher.update(Base64.strict_decode64(self.hashed_password))
      password << decipher.final

      password
    else
      nil
    end
  end

  def password=(new_password)
    cipher = GridCredentials::cipher
    encrypted_password = cipher.update(new_password)
    encrypted_password << cipher.final
    encrypted_password = Base64.strict_encode64(encrypted_password)

    self.hashed_password = encrypted_password
  end

  def valid?
    begin
      ssh_start {}
      true
    rescue Exception
      false
    end
  end

  # -----------
  private

  def _get_ssh_session
    if proxy
      Gsi::SSH.start(host, login, proxy)
    elsif password
      Net::SSH.start(host, login, password: password)
    else
      raise InfrastructureErrors::NoCredentialsError
    end
  end

  def _get_scp_session
    # TODO: use Gsi::SCP
    Net::SCP.start(host, login, password: password)
  end

  def self.cipher
    cipher = OpenSSL::Cipher::Cipher.new(@@CIPHER_NAME)
    cipher.encrypt
    cipher.padding = 1
    cipher.key = @@CIPHER_KEY
    cipher.iv = @@CIPHER_IV

    cipher
  end

  def self.decipher
    decipher = OpenSSL::Cipher::Cipher.new(@@CIPHER_NAME)
    decipher.decrypt
    decipher.key = @@CIPHER_KEY
    decipher.iv = @@CIPHER_IV

    decipher
  end

end
