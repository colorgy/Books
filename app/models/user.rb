class User < ActiveRecord::Base
  devise :trackable, :timeoutable,
         :omniauthable, :omniauth_providers => [:colorgy]
  include Authenticatable
  include HasCredits
  include CanPurchase
  include CanLeadGroups

  has_many :identities, class_name: :UserIdentity
  has_many :feedbacks
  has_many :taiwan_mobile_imgs
  after_create :add_initial_credits

  # has_many :groups, through: :orders

  def generate_uuid(core_url)
    base = Digest::MD5.digest("#{core_url}#{sid}")
    ary = base.unpack("NnnnnN")
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    self.uuid = "%08x-%04x-%04x-%04x-%04x%08x" % ary
  end

  def add_initial_credits
    user_credits.create(name: '贊助商折扣金', credits: 50, expires_at: '2015/9/6 23:59:59')
  end
end
