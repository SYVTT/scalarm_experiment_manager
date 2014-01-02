# Fields:
# user_id: ScalarmUser id who has this secrets
# experiment_id: id of an experiment, which can be run with this AMI
# template_id: id of an PLCloud instance template
# login: user login who can access this ami
# password: actually stored as hash_password

class PLCloudImage < MongoActiveRecord
  Encryptor.default_options.merge!(:key => Digest::SHA256.hexdigest('QjqjFK}7|Xw8DDMUP-O$yp'))

  def self.collection_name
    'plcloud_images'
  end

  def password
    Base64.decode64(self.hashed_password).decrypt
  end

  def password=(new_password)
    self.hashed_password = Base64.encode64(new_password.encrypt)
  end

end