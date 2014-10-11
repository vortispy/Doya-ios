-- key[1] userId
-- key[2] url
-- arg[1] time
local userId = KEYS[1]
local url = KEYS[2]
local time = ARGV[1]

if redis.call("SISMEMBER", "blacklist", userId) == 1 then
	redis.call("SADD", "delete-list", url)
	return "black"
end

redis.call("ZADD", "fileScores", time, url)
redis.call("ZADD", "doyaScores", 0, url)
redis.call("SADD", "users", userId)
redis.call("SADD", url, userId)
redis.call("SADD", userId, url)

return "OK"
