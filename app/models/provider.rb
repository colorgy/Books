class Provider < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :lockable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable
end
