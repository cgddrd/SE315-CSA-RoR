# CG - Add broadcast ID to returned JSON object.

json.extract! @broadcast, :id, :content, :user_id, :created_at
