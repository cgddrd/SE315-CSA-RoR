# CG - Custom "search results" template for use by the client application.

json.array!(@users) do |user|

  json.extract! user, :id, :surname, :firstname, :phone, :grad_year, :jobs, :email

  # CG - Extract current user's username from the 'user_details' object of the 'user' object.
  json.extract! user.user_detail, :login

end
