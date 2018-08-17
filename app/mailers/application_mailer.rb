class ApplicationMailer < ActionMailer::Base
  default from: 'notifications@example.com', bcc: 'sent@example.com'
  layout 'mailer'
end
