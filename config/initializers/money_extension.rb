# This code was not produced by FirstBargain. I found it somewhere on the web, but I cannot find the original author.

require 'money'

module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Money #:nodoc:
      module ClassMethods
        def money(name, options = {})
          allow_nil = options.has_key?(:allow_nil) ? options.delete(:allow_nil) : true
          options = {:cents => "#{name}_in_cents".to_sym }.merge(options)
          mapping = [[options[:cents], 'cents']]
          mapping << [options[:currency].to_s, 'currency'] if options[:currency]
          composed_of name, :class_name => 'Money', :mapping => mapping, :allow_nil => allow_nil,
            :converter => lambda{ |m|
              if !allow_nil && m.nil?
                currency = options[:currency] || ::Money.default_currency
                m = ::Money.new(0, currency)
              end
              m.to_money
            },
            :constructor => lambda{ |*args| 
              cents, currency = args
              cents ||= 0
              currency ||= ::Money.default_currency
              ::Money.new(cents, currency) 
            }

          define_method "#{name}_with_cleanup=" do |amount|
            send "#{name}_without_cleanup=", amount.blank? ? nil : amount.to_money
          end
          alias_method_chain "#{name}=", :cleanup
        end
      end
    end
  end
end

ActiveRecord::Base.extend ActiveRecord::Acts::Money::ClassMethods
