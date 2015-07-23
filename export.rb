require 'shopify_api'
require 'csv'
require './shopify_extensions'

ShopifyAPI::Base.site = ENV['SHOPIFY_BASE_SITE']

CSV do |csv|
  csv << %w'order_id tracking_number'

  ShopifyAPI::Order.find_all(status: :any) do |order|
    order.fulfillments.each do |fulfillment|
      fulfillment.tracking_numbers.each do |tracking_number|
        csv << [order.order_number, tracking_number]
      end
    end
  end
end