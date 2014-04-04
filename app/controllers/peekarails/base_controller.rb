module Peekarails
  class BaseController < ::ApplicationController

    before_filter :authorize
    before_filter :set_granularity

    layout 'peekarails/application'

    if self.respond_to? :skip_authorization_check
      skip_authorization_check
    end


    private

    def authorize
      send(Peekarails.authentication_method.to_sym)
    end

    def set_granularity
      @granularity_key = :five_minutes

      if params[:granularity]
        if Metrics::GRANULARITIES.keys.include? params[:granularity].to_sym
          @granularity_key = params[:granularity].to_sym
        end
      end

      @granularity = Metrics::GRANULARITIES[@granularity_key]

      @from = Time.now.to_i - @granularity[:ttl] / 2
      @to = Time.now.to_i
    end
  end
end
