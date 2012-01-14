if FirstBargain::Application.config.cdn_enabled
  ActionController::Base.asset_host = Proc.new do |source, request|
    if source == true || request == false || source =~ /jquery/
      nil
    else
      if request.ssl? then nil
      else "http://cdn%d.firstbargain.com" % (source.hash % 4)
      end
    end
  end
end