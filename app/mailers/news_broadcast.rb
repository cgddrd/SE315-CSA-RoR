class NewsBroadcast < ActionMailer::Base
    def send_news(user, broadcast, email_list)
        @firstname = user.firstname
        @content = broadcast.content
        
        # mail (to: user.email, subject: "Aber CS #{email_list} News", from: ADMIN_EMAIL);
        mail (to: "clg11@aber.ac.uk", subject: "Aber CS #{email_list} News", from: ADMIN_EMAIL);
    end
end
