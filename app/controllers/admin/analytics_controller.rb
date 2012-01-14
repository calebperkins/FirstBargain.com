class Admin::AnalyticsController < Admin::AdminController
  
  @medium_opts   = [:any, :cpc, :email, :cpm]
  @source_opts   = [:any, :google, :yahoo, :newsletter, :tv, :radio, :affiliate]
  @campaign_opts = [:any]
  @term_opts     = [:any]
  @content_opts  = [:any]
  
  def index
    @mediums = Set.new
    @sources = Set.new
    @campaigns = Set.new
    @terms = Set.new
    @contents = Set.new
    Account.find_each do |a|
      @mediums.add(a.utm_medium) if a.utm_medium
      @sources.add(a.utm_source) if a.utm_source
      @campaigns.add(a.utm_campaign) if a.utm_campaign
      @terms.add(a.utm_term) if a.utm_term
      @contents.add(a.utm_content) if a.utm_content
    end
    
    from = DateTime.strptime("#{params[:start]} 00:00:00", "%m/%d/%Y %H:%M:%S") + 7.hours
    to = DateTime.strptime("#{params[:end]} 23:59:59", "%m/%d/%Y %H:%M:%S") + 7.hours
    @accounts = Account.where(:created_at => from..to)
    @accounts = @accounts.where(:utm_medium => params[:medium]) if params[:medium] and params[:medium] != 'All Mediums'
    @accounts = @accounts.where(:utm_source => params[:source]) if params[:source] and params[:source] != 'All Sources'
    @accounts = @accounts.where(:utm_campaign => params[:campaign]) if params[:campaign] and params[:campaign] != 'All Campaigns'
    @accounts = @accounts.where(:utm_term => params[:term]) if params[:term] and params[:term] != 'All Terms'
    @accounts = @accounts.where(:utm_content => params[:content]) if params[:content] and params[:content] != 'All Content'

    data = [Hash.new(0), Hash.new(0), Hash.new(0)]
    @accounts.each do |a|
      d = a.created_at
      data[2][d] += 1
      data[1][d] += 1 if a.cumulative_credits > 0
      total_revenue = 0
      a.orders.each do |o|
        total_revenue += o.subtotal_in_cents if o.complete?
      end
      data[0][d] += total_revenue
    end
    keys = data[0].keys.sort
    tdiff = keys[-1] - keys[0] unless keys.empty?
    t_init = keys[0]
    dt = 1.days
    if tdiff > 2.months then
      t_init = t_init.beginning_of_month
      dt = 1.months
    elsif tdiff > 2.years then
      t_init = t_init.beginning_of_year
      dt = 1.years
    end
    @graph_data = [Hash.new(0), Hash.new(0), Hash.new(0), Hash.new(0)]
    keys.each do |k|
      nk = case dt
        when 1.days
          k.beginning_of_day
        when 1.months
          k.beginning_of_month
        when 1.years
          k.beginning_of_year
        end
      @graph_data[0][nk] += data[0][k]
      @graph_data[1][nk] += data[1][k]
      @graph_data[2][nk] += data[2][k]
    end
    @graph_data[0].keys.each do |k|
      @graph_data[3][k] = @graph_data[1][k] * 100.0 / @graph_data[2][k]
    end
  rescue
    @graph_data = [{},{},{}]
  end
  
end
