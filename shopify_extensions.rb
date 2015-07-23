# https://gist.github.com/ianneub/4243115

# Big thank you to Scott Wheeler and BBG in the Shopify API Forums
# http://ecommerce.shopify.com/c/shopify-apis-and-technology/t/paginate-api-results-113066

module ShopifyAPI
  class Base
    RETRY_AFTER = 60

    def self.find_all(params = {}, &block)
      params[:limit] ||= 50
      params[:page] = 1
      retried = false

      begin
        until find(:all, :params => params).each { |value| block.call(value) }.length < params[:limit]
          params[:page] += 1
          retried = false
        end
      rescue ActiveResource::ConnectionError, ActiveResource::ServerError,
        ActiveResource::ClientError => ex
        unless retried
          sleep(((ex.respond_to?(:response) && ex.response['Retry-After']) || RETRY_AFTER).to_i)
          retried = true
          retry
        else
          raise ex
        end
      end
    end
  end
end