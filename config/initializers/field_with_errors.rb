module ActionView
  class Base
    def self.field_error_proc
      Proc.new { |html_tag, instance| html_tag }
    end
  end
end

