class SeedsController < ApplicationController
  skip_before_filter :authenticate!

  def check
    if Sidekiq.redis {|r| r.setnx(CHECK, true) }
      Sidekiq.redis  {|r| r.expireat(CHECK, 2.minutes.from_now.to_i) }

      SeedWorker.perform_async
    end

    render :json => { :code => 200, :message => 'ok' }
  end
end

SeedsController::CHECK = "SeedsController:check:SeedWorker:perform_async"
