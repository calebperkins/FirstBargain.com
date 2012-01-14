class InvitationsController < ApplicationController
  layout 'accounts'
  before_filter :require_user
  set_tab :invitations, :sidebar
  
  def index
    @invitation = Invitation.new current_user
    respond_with @invitation
  end

  def create
    @invitation = Invitation.new current_user, params[:invitation]
    force_html @invitation do
      if @invitation.save then redirect_to invitations_url, notice: t("flash.invitations.created")
      else render 'index'
      end
    end
  end

end
