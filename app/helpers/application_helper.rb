module ApplicationHelper
  
  def yield_for(sym, default)
    content_for?(sym) ? content_for(sym) : default
  end
  
  def user_login
    current_user.try(:username).to_json
  end
  
  def user_id
    current_user.try(:single_access_token).to_json
  end
  
  def captcha
    recaptcha_tags(:display => {:theme => 'clean'}, :public_key => Rails.configuration.recaptcha_public).html_safe
  end
  
  def supported_browser?
    (request.user_agent =~ /MSIE (6|5)/).nil? 
  end
  
  def load_affiliate_stylesheet
    include_stylesheets(cookies[:affiliate].to_sym) if cookies[:affiliate].present?
  rescue Jammit::PackageNotFound
  end
  
  def link_to_affiliate
    url = if request.ssl? || cookies[:affiliate_url].blank? then root_path
    else cookies[:affiliate_url]
    end
    link_to "First Bargain", url
  end
  
  def pagination(collection)
    will_paginate collection, :previous_label => "&laquo; Previous", :next_label => "Next &raquo;"
  end
  
  def fill_grid(collection, kind, per_row)
    n = per_row - collection.size.modulo(per_row)
    return if n == per_row
    x = ""
    n.times do |i|
      x << if i == n - 1 then "<td class='#{kind}-listing last'></td>"
      else "<td class='#{kind}-listing'></td>"
      end
    end
    x.html_safe
  end
  
end
