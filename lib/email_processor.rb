class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    userName = @email.from[:email].scan( /#([^@]*)@/).last.first

    user = User.find_by_nick(userName)
    notification = Notification.create!(
      user_id: user.id, 
      message: @email.body
      subject: @email.subject
    )
  end
end