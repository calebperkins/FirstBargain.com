class CcbillController < ActionController::Metal
  
  def create
    o = Order.from_ccbill(params)
    if o.save
      Rails.cache.delete_matched("homepage/*/#{o.account_id}") # OPTIMIZE: pessimistic cache expiration
      response = o.process_postback(params)
      o.process_response response
    else Rails.logger.warn "CCBill postback at #{Time.current} not saved: #{params.inspect}"
    end
    self.content_type = Mime::TEXT
    self.response_body = params.inspect
  end
  
end