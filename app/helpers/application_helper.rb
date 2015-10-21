module ApplicationHelper
  def time_from_string(obj)
    Time.strptime(obj, '%H%M')
  end

  def display_start_time(times)
    format_time_str(times.split('-')[0])
  end

  def display_slot_and_duration(times, glue = ' for ')
    from, to = times.split('-')
    [
      display_start_time(times),
      (time_from_string(to) - time_from_string(from)).duration
    ].join(glue)
  end

  def format_time_str(time)
    I18n.l(time_from_string(time), format: :twelve_hour)
  end

  def format_time_str_24(time)
    I18n.l(time_from_string(time), format: :twentyfour_hour)
  end

  def page_title(header, glue=' - ')
    page_title = [Rails.configuration.app_title]
    page_title.unshift(header) if header.present?
    page_title.join glue
  end

  def conditional_text(variable, prefix = '', suffix = '')
    if variable.present?
      prefix + variable.to_s + suffix
    end
  end

  def prison_estate_name_for_id(nomis_id)
    prison = Prison.find_by_nomis_id(nomis_id)
    return prison.estate if prison && prison.enabled?
  end

  def markdown(source)
    renderer = ::Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
    options = Rails.application.config.redcarpet_markdown_options
    ::Redcarpet::Markdown.new(renderer, options).render(source).html_safe
  end

  def field_error(form, name)
    errors = form.object.errors[name]
    return '' unless errors.any?
    content_tag(:span, class: 'validation-message') { errors.first }
  end

  def error_container(form, name, options = {}, &blk)
    if form.object.errors.include?(name)
      klass = [options[:class], 'validation-error'].compact.join(' ')
    else
      klass = options[:class]
    end
    content_tag(:div, options.merge(class: klass), &blk)
  end

  def group_container(form, name, options = {}, &blk)
    error_container(form, name, options.merge(class: 'group'), &blk)
  end

  def field_container(form, name, options = {}, &blk)
    error_container(form, name, options.merge(class: 'group'), &blk)
  end
end
