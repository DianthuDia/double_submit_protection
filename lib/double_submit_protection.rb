require "double_submit_protection/version"

module DoubleSubmitProtection

  DEFAULT_TOKEN_NAME = 'submit_token'

  module View
    def double_submit_token(token_name=nil, keep=false)
      token_name ||= DEFAULT_TOKEN_NAME
      if keep
        flash.keep token_name
      else
        flash[token_name] = Digest::MD5.hexdigest(rand.to_s)
      end
      hidden_field_tag(token_name, flash[token_name])
    end
  end

  module Controller
    def double_submit?(token_name=nil)
      token_name ||= DEFAULT_TOKEN_NAME
      token = flash[token_name]
      token.nil? || ( (request.post? || request.put?) && (token != params[token_name]) )
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  ActionController::Base.class_eval do
    include DoubleSubmitProtection::Controller
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Base.class_eval do
    include DoubleSubmitProtection::View
  end
end
