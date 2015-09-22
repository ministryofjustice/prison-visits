module ApplicationHelper
  def format_date(date)
    date = Date.parse(date) if date.class == String
    date.strftime("%e %B %Y").strip
  end

  def format_date_nomis(date)
    date = Date.parse(date) if date.class == String
    date.strftime("%d/%m/%Y").strip
  end

  def format_day(date)
    date = Date.parse(date) if date.class == String
    date.strftime("%A %-e %B")
  end

  def display_start_time(times)
    format_time_str(times.split('-')[0])
  end

  def display_time_slot(times, glue = ' to ')
    from, to = times.split('-')
    [format_time_str(from).strip, format_time_str(to).strip].join(glue)
  end

  def display_slot_and_duration(times, glue = ', ')
    from, to = times.split('-')
    [
      format_time_str(from).strip,
      (time_from_str(to)-time_from_str(from)).duration
    ].join(glue)
  end

  def format_time_str(time)
    time_from_str(time).strftime("%l:%M%P").strip
  end

  def format_time_str_24(time)
    time_from_str(time).strftime("%H:%M").strip
  end

  def time_from_str(str)
    Time.strptime(str, '%H%M')
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

  def prison_name_for_id(nomis_id)
    @nomis_id_to_prison ||= Hash[
      Rails.configuration.prison_data.
        select { |_, data| data['enabled'] }.
        map { |name, data| [data['nomis_id'], name] }
    ]
    @nomis_id_to_prison[nomis_id]
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
