class User < ActiveRecord::Base
  devise :trackable, :timeoutable,
         :omniauthable, :omniauth_providers => [:colorgy]

  has_many :identities, class_name: :UserIdentity
  has_many :cart_items, class_name: :UserCartItem

  def self.from_core(auth)
    user = where(:sid => auth.info.id).first_or_create! do |new_user|
      new_user.email = auth.info.email
    end

    oauth_params = ActionController::Parameters.new(auth.info)

    attrs = %i(username gender username name avatar_url cover_photo_url gender fbid uid identity organization_code department_code)

    user_data = oauth_params.slice(*attrs).permit(*attrs)

    user_data['refreshed_at'] = Time.now
    user_data['core_access_token'] = auth.credentials.token

    user.update!(user_data)

    ActiveRecord::Base.transaction do
      user.identities.destroy_all

      identities = auth.info.identities
      identities_inserts = identities.map { |i| "(#{i[:id]}, #{user.id}, '#{i[:organization_code]}', '#{i[:department_code]}', '#{i[:name]}', '#{i[:uid]}', '#{i[:email]}', '#{i[:identity]}')" }
      if identities_inserts.length > 0
        sql = <<-eof
          INSERT INTO user_identities (sid, user_id, organization_code, department_code, name, uid, email, identity)
          VALUES #{identities_inserts.join(', ')}
        eof
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    return user
  end
end
