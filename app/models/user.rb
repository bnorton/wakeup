class User < ActiveRecord::Base
  include Model

  validates :phone, :presence => true

  before_update :verify, :if => :vcode_changed?
  after_save -> { UserWorker.perform_async(id) }

  private

  def verify
    reset_auth if vcode == code
  end

  def defaults_before_create
    reset_auth
  end

  def reset_auth
    self.code = rand(1_000..9_999).to_s
    self.token = Hat.long
  end
end
