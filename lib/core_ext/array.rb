class Array
  def save
    each(&:save)
  end

  def save!
    each(&:save!)
  end
end
