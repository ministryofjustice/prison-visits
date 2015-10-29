module ApplicationHelper
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
