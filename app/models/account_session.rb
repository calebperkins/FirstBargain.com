class AccountSession < Authlogic::Session::Base
  self.last_request_at_threshold = 1.minute
end