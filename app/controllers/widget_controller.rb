# Handles widget initialization and updates.
class WidgetController < ActionController::Metal
  
  def show
    t, data = Rails.cache.fetch("auction/-#{params[:id]}-/promo") do
      a = Auction.find(params[:id])
      [a.ending_at, a.serializable_hash]
    end
    data[:no] = (Time.now.to_f*1000 - params[:t].to_i)
    data[:nt] = params[:t]
    Rails.cache.delete("auction/-#{params[:id]}-/promo") if t.past?
    self.response_body = "#{params[:callback]}(#{data.to_json})"
    self.content_type = Mime::JS
  rescue
    self.status = :bad_request
  end

  def index
    p = Auction.widgety(params[:widgets], params[:auctions]).map! {|a| a.as_product(request)}.to_json
    self.response_body = "#{params[:callback]}(#{p})"
    self.content_type = Mime::JS
  rescue
    self.status = :bad_request
  end
  
end