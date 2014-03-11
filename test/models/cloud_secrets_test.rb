require 'test/unit'

# Tests usage of EncryptedMongoActiveRecord with CloudSecrets
class CloudSecretsTest < Test::Unit::TestCase

  def test_encryption
    # -- given
    su = ScalarmUser.new('login'=>'user')
    su.save

    su2 = ScalarmUser.new('login'=>'user2')
    su2.save

    # -- when
    cs = CloudSecrets.new('login'=>'cloud_user', 'user_id'=>su.id, 'info'=>5)
    cs.secret_password = 'my_password'
    cs.other_info = 3
    cs.other_user_id = su2.id
    cs.save

    puts "csid: #{cs.id}, #{cs}"
    saved_cs = CloudSecrets.find_by_id(cs.id)

    # -- then
    assert_equal(saved_cs.login, 'cloud_user')
    assert_equal(saved_cs.secret_password, 'my_password')

    assert_equal(saved_cs.info, 5)
    assert_equal(saved_cs.other_info, 3)

    assert_no_match(/my_password/, saved_cs.to_s, "CloudSecrets secret_password is stored as plain text: #{saved_cs.to_s}")

    assert_equal(saved_cs.user_id, su.id)
    assert_equal(saved_cs.other_user_id, su2.id)

    assert_equal(saved_cs.id, cs.id)
    assert_equal(saved_cs.login, cs.login)

    # -- clean up
    su.destroy
    su2.destroy
    cs.destroy

  end

end