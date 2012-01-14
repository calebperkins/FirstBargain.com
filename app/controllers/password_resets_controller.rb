class PasswordResetsController < ApplicationController
	before_filter :require_no_user
	before_filter :load_user, only: [:edit, :update]

	def new
	  respond_with
	end

	def edit
	  respond_with
	end

	def update
	  flash.notice = t("flash.password_reset.success") if @account.update_attributes(params[:account])
	  respond_with @account, location: root_url
	end

	def create
		@account = Account.find_by_email params[:email]
		if @account
		  @account.deliver_password_reset_instructions
		  redirect_to root_url, notice: t("flash.password_reset.sent")
		else
		  flash.now.alert = t("flash.password_reset.no_account")
		  render "new"
	  end
	end

	private

	def load_user
		@account = Account.find_using_perishable_token params[:code], 1.week
		redirect_to(root_url, alert: t("flash.password_reset.expired")) unless @account
	end

end
