# CG - Added ':id' to returned JSON entry. 
json.extract! @user, :id, :surname, :firstname, :phone, :grad_year, :jobs, :email, :created_at, :updated_at
