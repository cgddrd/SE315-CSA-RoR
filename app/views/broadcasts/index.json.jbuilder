# CG - Add broadcast ID to returned JSON object.

json.array!(@broadcasts) do |broadcast|
  json.extract! broadcast, :id, :content, :user_id
  json.url broadcast_url(broadcast, format: :json)
end
