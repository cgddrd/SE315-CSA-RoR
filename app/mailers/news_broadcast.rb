class NewsBroadcast < ActionMailer::Base

    def send_news(user, broadcast, email_list)

        @firstname = user.firstname
        @email = user.email

        # CG - Content is supplied by views/news_broadcast/send_news.html.erb
        mail(to: "clg11@aber.ac.uk", subject: "Aber CS #{email_list} News", from: ADMIN_EMAIL);
    end

end
