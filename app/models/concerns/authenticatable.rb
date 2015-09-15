module Authenticatable
  extend ActiveSupport::Concern

  module ClassMethods
    def from_core(auth)
      # find or create the user
      user = where(:sid => auth.info.id).first_or_create! do |new_user|
        new_user.uuid = auth.info.uuid
        new_user.email = auth.info.email
      end

      # sync the user's infomation from core
      oauth_params = ActionController::Parameters.new(auth.info)

      attrs = %i(uuid username gender name avatar_url cover_photo_url gender fbid uid identity organization_code department_code)

      user_data = oauth_params.slice(*attrs).permit(*attrs)

      user_data['refreshed_at'] = Time.now
      user_data['core_access_token'] = auth.credentials.token

      # permit possible access
      user_data['organization_code'] = oauth_params[:possible_organization_code]
      user_data['department_code'] = oauth_params[:possible_department_code] if oauth_params[:possible_department_code].present?

      user.update!(user_data)

      # sync the user's identities from core
      ActiveRecord::Base.transaction do
        user.identities.destroy_all

        identities = auth.info.identities
        identities_inserts = identities.map { |i| "(#{i[:id]}, #{i[:id]}, #{user.id}, '#{i[:organization_code]}', '#{i[:department_code]}', '#{i[:name]}', '#{i[:uid]}', '#{i[:email]}', '#{i[:identity]}')" }
        if identities_inserts.length > 0
          sql = <<-eof
            INSERT INTO user_identities (id, sid, user_id, organization_code, department_code, name, uid, email, identity)
            VALUES #{identities_inserts.join(', ')}
          eof
          ActiveRecord::Base.connection.execute(sql)
        end
      end

      return user
    end
  end
end
