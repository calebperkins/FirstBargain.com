class MenuTabBuilder < TabsOnRails::Tabs::TabsBuilder
  
  def tab_for(tab, name, options, item_options = {})
    # Adds "current" to the li tag
    item_options[:class] = item_options[:class].to_s.split(" ").push("current").join(" ") if current_tab?(tab)
    #content = @context.link_to_unless(current_tab?(tab), name, options) do
    #  @context.link_to @context.content_tag(:span, name), options
    #end
    #title = current_tab?(tab) ? "<span>#{name}</span>".html_safe : name
    content = @context.link_to(name, options) # goes inside li
    @context.content_tag(:li, content, item_options)
  end
  
end