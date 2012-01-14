# Handles all XHR auction updates.
class PollerController < ActionController::Metal

  def show
    offset
    a = Auction.find(params[:id])
    u = Account.find_by_single_access_token(params[:u])
    self.response_body = Rails.cache.fetch([a, u]) do
      a.as_detailed(u).to_json
    end
    self.content_type = Mime::JSON
  rescue
    self.status = :bad_request
  end

  def index
    offset
    u = Account.find_by_single_access_token(params[:u])
    self.response_body = Rails.cache.fetch(["homepage", Rails.cache.read('bids', raw: true), Rails.cache.read('finished', raw: true), params[:ids], u]) do
      ids = params[:ids].split('-')
      Auction.summaries(u, ids).to_json
    end
    self.content_type = Mime::JSON
  rescue
    self.status = :bad_request
  end

  private

  # Expects a UTC timestamp in milliseconds. Returns time offset in milliseconds and original timestamp.
  def offset
    headers["NTP-Offset"] = (Time.now.to_f*1000 - params[:t].to_i).to_s
    headers["NTP-Time"] = params[:t]
    headers["Cache-Control"] = "no-cache, must-revalidate"
  end

end