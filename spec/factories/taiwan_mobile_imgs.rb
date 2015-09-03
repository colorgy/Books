# http://stackoverflow.com/questions/24355501/using-factorygirls-attributes-for-with-paperclip-attachment

FactoryGirl.define do
  factory :taiwan_mobile_img do
    image_url Rack::Test::UploadedFile.new(Rails.root.join('spec', 'images', 'test.png'), "image/png")
    user nil
  end

end
