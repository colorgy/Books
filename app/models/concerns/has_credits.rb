module HasCredits
  extend ActiveSupport::Concern

  def add_credit(amount)
    self.credits += amount
  end

  def add_credit!(amount)
    add_credit(amount)
    save!
  end

  def use_credit(amount)
    self.credits -= amount
    raise 'not enough credits' if self.credits < 0
  end

  def use_credit!(amount)
    use_credit(amount)
    save!
  end
end
