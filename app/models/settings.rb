class Settings < RailsSettings::CachedSettings
  cache_expire_rate 120

  def self.pickup_point_selections_for(org_code)
    @pickup_point_selections = Settings.pickup_point_selections
    if @pickup_point_selections.is_a? Hash
      @pickup_point_selections[org_code]
    else
      @pickup_point_selections
    end
  end

  def self.pickup_date_selections_for(org_code)
    @pickup_date_selections = Settings.pickup_date_selections
    if @pickup_date_selections.is_a? Hash
      @pickup_date_selections[org_code]
    else
      @pickup_date_selections
    end
  end

  def self.pickup_time_selections_for(org_code)
    @pickup_time_selections = Settings.pickup_time_selections
    if @pickup_time_selections.is_a? Hash
      @pickup_time_selections[org_code]
    else
      @pickup_time_selections
    end
  end
end
