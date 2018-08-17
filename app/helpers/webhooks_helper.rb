module WebhooksHelper

  # Custom Error classes for raising 4XX responses
  class Webhooks::Forbidden < StandardError
  end
  class Webhooks::NotFound < StandardError
  end
end
