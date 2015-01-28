class User < ActiveRecord::Base
  devise :trackable, :omniauthable, :omniauth_providers => [:colorgy]
  has_many :book_datas
  has_many :courses

  def self.from_core(auth)
    user = where(:sid => auth.sid).first_or_create! do |new_user|
      new_user.email = auth.info.email
    end

    oauth_params = ActionController::Parameters.new(auth.info)

    attrs = %i(username gender username name avatar_url cover_photo_url gender fbid uid identity organization department)

    user.update!(oauth_params.slice(*attrs).permit(*attrs))

    return user
  end
end
