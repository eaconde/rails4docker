class CounterJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    rand(10) + rand(10)
  end
end
