require "sinatra"
require_relative "key_cache"

keyCache = KeyCache.new

# E1. There should be one endpoint to generate keys.
post "/keys/generate/:num" do
	if ( params['num'].empty? )
		throw ArgumentError, "Need to enter the number of keys to generate"
	end
	keyCache.generateKeys(params['num'].to_i)
	keyCache.fetchAllAvailable
end

# E2. There should be an endpoint to get an available key. 
# On hitting this endpoint server should serve a random key which is 
# not already being used. This key should be blocked and should not be 
# served again by E2, till it is in this state. 
# If no eligible key is available then it should serve 404.
get "/keys/available" do
	respKey = keyCache.getAvailableKey
	if (respKey.nil? || respKey.empty?)
		status 404
		respKey = "No Key Available"
	end
	respKey
end

# E3. There should be an endpoint to unblock a key. 
# Unblocked keys can be served via E2 again.
put "/keys/unblock/:key" do
	if ( params['key'].empty? )
		status 400
		"Please specify a key to unblock."
	else
		keyCache.unblockKey(params['key'])
	end
end

# E4. There should be an endpoint to delete a key. 
# Deleted keys should be purged.
delete "/keys/:key" do
	if ( params['key'].empty? )
		status 400
		"Please specify a key to delete"
	else
		keyCache.deleteKey(params['key'])
	end
end

# E5. All keys are to be kept alive by clients 
# calling this endpoint every 5 minutes. If a particular key has 
# not received a keep alive in last five minutes then it should be 
# deleted and never used again.
post "/keys/keep-alive/:key" do
	if ( params['key'].empty? )
		status 400
		"Please specify a key to Keep Alive"
	else
		keyCache.keepAliveKey(params['key'])
	end
end


# DEBUG Endpoints
get "/keys/all/available" do
	keyCache.fetchAllAvailable
end

get "/keys/all/blocked" do
	keyCache.fetchAllBlocked
end