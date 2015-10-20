module DateHelper
  def date_from_string_or_date(obj)
    obj.class == String ? Date.parse(obj) : obj
  end

  def format_date_of_birth(date)
    I18n.l(date_from_string_or_date(date), format: :date_of_birth)
  end

  def format_date_of_visit(date)
    I18n.l(date_from_string_or_date(date), format: :date_of_visit)
  end
end
