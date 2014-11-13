# CG - Added ':id' to returned JSON entry. 
json.array!(@users) do |user|
  json.extract! user, :id, :surname, :firstname, :phone, :grad_year, :jobs, :email
  json.url user_url(user, format: :json)
end
