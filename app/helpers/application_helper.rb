module ApplicationHelper
  def nav_link_class(path)
    base = "transition"
    if current_page?(path)
      "#{base} text-primary"
    else
      "#{base} text-muted hover:text-text"
    end
  end
end
