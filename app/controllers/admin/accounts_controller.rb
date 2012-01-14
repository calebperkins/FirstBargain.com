class Admin::AccountsController < Admin::AdminController
  cache_sweeper :account_sweeper, only: :adjust

  def index
    respond_to do |wants|
      wants.html {@accounts = Account.search(params[:s]).paginate :page => params[:page], :per_page => 50}
      wants.xml {render :xml => Account.all}
    end
  end

  def show
    @account = Account.find params[:id]
    @orders = @account.orders.order('id DESC')
    @bids = @account.bids.order('id ASC')
    @invites = @account.children.order('id ASC')
    @wins = @account.auctions.latest_ended.includes(:product)
    respond_with [:admin, @account]
  end
  
  def update
    @account = Account.find params[:id]
    @account.notes = params[:account][:notes]
    @account.save
    respond_with [:admin, @account]
  end

  def adjust
    @account = Account.find params[:id]
    flash.notice = "Updated!" if @account.adjust(params[:account])
    respond_with [:admin, @account]
  end

  def destroy
    @account = Account.find params[:id]
    @account.toggle! :active
    respond_with [:admin, @account]
  end
  
  def flag
    @account = Account.find params[:id]
    @account.toggle! :good_email
    respond_with [:admin, @account]
  end
  
  def subscribe
    @account = Account.find params[:id]
    @account.toggle! :subscribed
    respond_with [:admin, @account]
  end
  
  def online
    @accounts = Account.where("last_request_at > ?", 10.minutes.ago).order("current_login_ip ASC")
    respond_with [:admin, @accounts]
  end

end
