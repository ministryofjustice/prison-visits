class MarkdownTemplateHandler
  def self.call(template)
    erb = ActionView::Template.registered_template_handler(:erb)
    source = erb.call(template)
    <<-SOURCE
    renderer = ::Redcarpet::Render::HTML.new(hard_wrap: true)
    options = Rails.application.config.redcarpet_markdown_options
    ::Redcarpet::Markdown.new(renderer, options).
    render(begin;#{source};end).html_safe
    SOURCE
  end
end

ActionView::Template.
  register_template_handler(:md, MarkdownTemplateHandler)
ActionView::Template.
  register_template_handler(:markdown, MarkdownTemplateHandler)
