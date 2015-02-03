require "factory_girl"

namespace :dev do
  desc "Seed data for development environment"
  task prime: "db:setup" do

    if Rails.env.development?
      include FactoryGirl::Syntax::Methods

      FactoryGirl.create_list(:book_data, 100)
    end
  end
end
