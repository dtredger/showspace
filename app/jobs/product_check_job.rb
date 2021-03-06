class ProductCheckJob

  PRODUCT_CHECK_LOGGER = if ENV["PRODUCT_CHECK_LOGGER"].present? then
                           Logger.new(ENV["PRODUCT_CHECK_LOGGER"])
                         else
                           Logger.new(STDOUT)
                         end

  def self.perform(store_name)
    PRODUCT_CHECK_LOGGER.debug "ran at #{Time.now}"
    begin
      price_changed = []
      unchanged = []
      errors = []

      scraper = SiteScraper.where(store_name: store_name).order('updated_at DESC').first
      selector = scraper[:detail_price_cents_selector]
      items = Item.live.where(store_name: store_name)
      items.each do |item|
        result = item.check_price(selector)
        if result.first == :price_change
          price_changed << result.last
        elsif result.first == :unchanged
          unchanged << result.last
        else
          errors << result.last
        end
      end

      PRODUCT_CHECK_LOGGER.info "price_changed:"
      PRODUCT_CHECK_LOGGER.info price_changed
      PRODUCT_CHECK_LOGGER.info "unchanged:"
      PRODUCT_CHECK_LOGGER.info unchanged
      PRODUCT_CHECK_LOGGER.error "errors:"
      PRODUCT_CHECK_LOGGER.error errors

      result = [ price_changed, unchanged, errors ]
      AdminMailer.jobs_notifier(AdminUser.on_notification_list, result)
    rescue Exception => e
      PRODUCT_CHECK_LOGGER.error e
      AdminMailer.error_notifier(AdminUser.on_notification_list, e)
    end
  end


end
