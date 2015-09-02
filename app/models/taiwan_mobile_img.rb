class TaiwanMobileImg < ActiveRecord::Base
	belongs_to :user
	has_attached_file :image_url, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
	validates_attachment_content_type :image_url, content_type: /\Aimage\/.*\Z/
	validates :image_url, attachment_presence: true
	validates_with AttachmentPresenceValidator, attributes: :image_url
	validates_with AttachmentSizeValidator, attributes: :image_url, less_than: 1.megabytes
end
