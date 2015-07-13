require 'active_resource'

class Organization < ActiveResource::Base
  cached_resource

  cached_resource.ttl = 1000
  cached_resource.ttl_randomization = true
  cached_resource.ttl_randomization_scale = 1..100
  cached_resource.collection_synchronize = false

  self.site = "#{ENV['CORE_URL']}/api/v1"

  def self.all_for_select
    all.map { |u| ["#{u.name} (#{u.short_name})", u.code] }
  end

  def departments_for_select(group = nil)
    if group.blank?
      departments.map { |d| [d.name, d.code] }
    else
      departments.reject { |d| d.group != group }.map { |d| [d.name, d.code] }
    end
  end

  def self.find(*args)
    args[1] ||= {}
    args[1][:params] ||= {}
    args[1][:params].merge!(PARAMS)
    super
  end

  def self.example_cods
    ['NTUST', 'NTU', 'NTHU']
  end

  PARAMS = {
    'fields[department]' => 'code,name,short_name,group,departments'
  }
end
