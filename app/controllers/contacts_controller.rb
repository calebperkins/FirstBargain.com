class ContactsController < ApplicationController
  layout 'static'
  set_tab :contact, :sidebar
  set_tab :contact
  
  def show
    @contact = Contact.new
    respond_with @contact
  end
  
  def create
    @contact = Contact.new(params[:contact])
    force_html @contact, location: root_url do
      if verify_recaptcha(model: @contact, private_key: Rails.configuration.recaptcha_private) && @contact.save
        redirect_to root_url, notice: t("flash.contact.created")
      else render "show"
      end
    end
  end

end
