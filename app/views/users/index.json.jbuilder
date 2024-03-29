json.array!(@users) do |user|

  # CG - Added :id key to the returned results.
  json.extract! user, :id, :surname, :firstname, :phone, :grad_year, :jobs, :email

  # CG - Extract current user's username from the 'user_details' object of the 'user' object.
  json.extract! user.user_detail, :login

  json.url user_url(user, format: :json)
end
