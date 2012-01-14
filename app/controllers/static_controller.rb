class StaticController < ApplicationController
  
  set_tab :faq
  set_tab :tutorial, only: %w(tutorial rewards guarantee tips)
  set_tab :faq, :sidebar, only: %w(faq_new_user faq_auctions faq_account faq_shipping faq_payment faq about)
  set_tab :about, :sidebar, only: :about
  set_tab :rules, :sidebar, only: :rules
  set_tab :tos, :sidebar, only: :tos
  set_tab :privacy, :sidebar, only: :privacy
  set_tab :returns, :sidebar, only: :sidebar
  set_tab :play, :sidebar, only: :tutorial
  set_tab :rewards, :sidebar, only: :rewards
  set_tab :guarantee, :sidebar, only: :guarantee
  layout :choose_layout
  
  caches_action :faq_new_user, :faq_auctions, :faq_account, :faq_shipping, :faq_payment, :faq, :about, :rules, :tos, :privacy, :returns, :tutorial, :rewards, :guarantee, :tips, :layout => false
  
  def faq_new_user
    render "faq_new_user.html"
  end

  def faq_auctions
    render "faq_auctions.html"
  end
  
  def faq_account
    render "faq_account.html"
  end
  
  def faq_shipping
    render "faq_shipping.html"
  end
  
  def faq_payment
    render "faq_payment.html"
  end
  
  def faq
    render "faq.html"
  end
  
  def about
    render "about.html"
  end
  
  def rules
    render "rules.html"
  end
    
  def tos
    render "tos.html"
  end
  
  def privacy
    render "privacy.html"
  end
  
  def returns
    render "returns.html"
  end
  
  def tutorial
    render "tutorial.html"
  end
  
  def rewards
    render "rewards.html"
  end
  
  def guarantee
    render "guarantee.html"
  end
  
  def tips
    render "tips.html"
  end
  
  private
  
  def choose_layout
    return "basic" if params[:popup].present?
    case action_name
    when "tutorial", "rewards", "guarantee"
      "howtoplay"
    when "tips"
      "application"
    else
      "static"
    end
  end
  
end
