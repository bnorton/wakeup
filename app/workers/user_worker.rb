class UserWorker < Worker
  def perform(user_id)
    @user = User.find(user_id)

    Messaging.new(@user).text(message)
  end

  private

  def message
    "up! #{@user.code} verification. enter the code in up! to verify your phone number."
  end
end
