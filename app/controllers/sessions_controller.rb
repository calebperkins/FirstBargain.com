class SessionsController < ApplicationController
  before_filter :require_no_user, only: [:new, :create]
  before_filter :require_user, only: :destroy
  ssl_required :new, :create
  ssl_allowed :destroy

  def new
    @session = AccountSession.new
    respond_with @session
  end

  def create
    @session = AccountSession.new params[:account_session]
    force_html @session do
      if @session.save then redirect_back_or root_url(:beginner => @session.record.beginner?)
      else render "new"
      end
    end
  end

  def destroy
    current_user_session.destroy
    reset_session
    flash.notice = t("flash.session.deleted")
    respond_with current_user_session, location: new_session_url
  end

end
