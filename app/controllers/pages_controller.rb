class PagesController < ApplicationController
  def home
    @ctr = CounterJob.perform_now
  end
end
