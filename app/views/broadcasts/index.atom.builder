# CG - XML Template for ATOM feeds. Links to 'broadcasts_controller.rb' via '@broadcasts' object.
# CG - Code modified from original source: http://api.rubyonrails.org/classes/ActionView/Helpers/AtomFeedHelper.html

atom_feed do |feed|
  feed.title("CSA_Broadcasts_Atom")
  feed.updated(@broadcasts[0].updated_at) if @broadcasts.length > 0

  @broadcasts.each do |post|
    feed.entry(post) do |entry|
      entry.title(post.content)
      entry.content(post.content, type: 'html')
    end
  end
end
