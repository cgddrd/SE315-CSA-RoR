# CG - XML Template for RSS feeds. Links to 'broadcasts_controller.rb' via '@broadcasts' object.
# CG - Code modified from original source: http://techoctave.com/c7/posts/32-create-an-rss-feed-in-rails

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "CSA_Broadcasts"
    xml.description "CSA Description"

    for post in @broadcasts
      xml.item do
        xml.title post.content
        xml.description post.content
        xml.pubDate post.updated_at.to_s(:rfc822)
      end
    end
  end
end
