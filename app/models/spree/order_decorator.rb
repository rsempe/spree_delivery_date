Spree::Order.class_eval do
  require 'date'
  require 'spree/order/checkout'

  after_initialize :set_default_delivery_date

  validate :delivery_date_present, :delivery_date_specific_validation

  def set_default_delivery_date
    if cutoff.past?
      self.delivery_date = is_sunday?(2.days.from_now) ? 3.days.from_now : 2.days.from_now
    else
      self.delivery_date = is_sunday?(1.day.from_now) ? 2.days.from_now : 1.day.from_now
    end
  end

  def delivery_date_present
    if checkout_state? && !self.delivery_date
        errors.add(:delivery_date, I18n.t(:cannot_be_blank))
    end
  end

  def delivery_date_specific_validation
    if checkout_state? && self.delivery_date
      if is_sunday?(self.delivery_date)
        errors.add(:delivery_date, I18n.t(:cannot_be_a_sunday))
      end

      if too_late_for_delivery_tomorrow?
        errors.add(:delivery_date, I18n.t(:too_late_for_delivery))
      end
    end
  end

  private

  def checkout_state?
    ['payment', 'confirm'].include?(state)
  end

  def too_late_for_delivery_tomorrow?
    cutoff.past? && !(self.delivery_date > Date.tomorrow)
  end

  def cutoff
    Time.now.change(hour: 11, min: 00)
  end

  def is_sunday?(date)
    [0, 7].include?(date.wday)
  end

  Spree::PermittedAttributes.checkout_attributes << :delivery_date
end
