require 'thread'
require 'securerandom'

class Key
	attr_reader   :key
	attr_reader   :lastKeepAlive # Time in seconds since epoch
	attr_accessor :blockedAt # Time in seconds since epoch

	def initialize(key)
		@key = key
		@lastKeepAlive = Time.now
		@blockedAt = nil
	end

	def block
		@blockedAt = Time.now
	end

	def unblock
		@blockedAt = nil
	end

	def keepAlive
		@lastKeepAlive = Time.now
	end

	def to_s
		"Key:: #{@key} Last-Keep-Alive:: #{@lastKeepAlive} Blocked At:: #{@blockedAt}\n"
	end

	def to_str
		to_s
	end
end

class KeyCache
	attr_reader :availableKeys
	attr_reader :blockedKeys
	attr_reader :unBlockKeysTask
	attr_reader :deleteKeepAliveKeysTask

	def initialize
		@availableKeys = {}
		@blockedKeys = {}
		@avlKeysMutex   = Mutex.new
		@blckdKeysMutex = Mutex.new

		@unBlockKeysTask = Thread.new {
			while true do
				unblockKeys()
			end
		}

		@deleteKeepAliveKeysTask = Thread.new {
			while true do
				purgeExpiredKeys()
			end
		}
	end

	def generateKeys(num)
		LOG_MSG("Generating #{num} keys.")
		@avlKeysMutex.synchronize {
			num.times do |idx|
				keyStr = SecureRandom.uuid
				key = Key.new(keyStr)
				@availableKeys[keyStr] = key
			end
		}
	end

	def fetchAllAvailable
		availableKeys = []
		@avlKeysMutex.synchronize {
			@availableKeys.each_pair do |keyStr, key|
				availableKeys << key.to_s
			end
		}
		availableKeys
	end

	def fetchAllBlocked
		blockedKeys = []
		@blckdKeysMutex.synchronize {
			@blockedKeys.each_pair do |keyStr, key|
				blockedKeys << key.to_s
			end
		}
		blockedKeys
	end

	def getAvailableKey
		avlKeyStr = nil
		avlKey = nil
		@avlKeysMutex.synchronize {
			avlKeyStr, avlKey  = @availableKeys.shift
			if ( ! avlKeyStr.nil? )
				@blckdKeysMutex.synchronize {
					avlKey.block
					@blockedKeys[avlKeyStr] = avlKey
				}
			end
		}
		avlKeyStr
	end

	def unblockKey(keyStr)
		key = nil
		@blckdKeysMutex.synchronize {
			key = @blockedKeys.delete(keyStr)
			if ( ! key.nil? )
				key.unblock
				@avlKeysMutex.synchronize {
					@availableKeys[key.key] = key
				}
			end
		}
		"UNBLOCKED #{key.to_s}"
	end

	def deleteKey(keyStr)
		keyDeleted = false
		@blckdKeysMutex.synchronize {
			if (@blockedKeys.has_key?(keyStr))
				@blockedKeys.delete(keyStr)
				keyDeleted = true
			end
		}

		if ( !keyDeleted )
			@avlKeysMutex.synchronize {
				if (@availableKeys.has_key?(keyStr))
					@availableKeys.delete(keyStr)
				end
			}
		end
	end

	def keepAliveKey(keyStr)
		keyKeptAlive = false
		@blckdKeysMutex.synchronize {
			if (@blockedKeys.has_key?(keyStr))
				@blockedKeys[keyStr].keepAlive
				keyKeptAlive = true
			end
		}

		if ( !keyKeptAlive )
			@avlKeysMutex.synchronize {
				if (@availableKeys.has_key?(keyStr))
					@availableKeys[keyStr].keepAlive
				end
			}
		end
	end

	def purgeExpiredKeys
		sleep 120
		now = Time.now
		keepAliveTime = 60 * 5 # 5 minutes
		
		LOG_MSG ("Purging Keys")
		@avlKeysMutex.synchronize {
			@availableKeys.each_pair do |keyStr, key|
				if ( (now - key.lastKeepAlive) >= keepAliveTime )
					@availableKeys.delete(keyStr)
				end
			end
		}

		@blckdKeysMutex.synchronize {
			@blockedKeys.each_pair do |keyStr, key|
				if ( (now.to_i - key.lastKeepAlive.to_i) >= keepAliveTime )
					@blockedKeys.delete(keyStr)
				end
			end
		}
	end

	def unblockKeys
		sleep 60
		now = Time.now
		unblockedKeys = Array.new

        LOG_MSG ("Unblocking Keys")
		# Unblock the keys and save locally
		@blckdKeysMutex.synchronize {
			@blockedKeys.each_pair do |keyStr, key|
				if ( (now.to_i - key.blockedAt.to_i) >= 60)
					key.unblock
					@blockedKeys.delete(keyStr)
					unblockedKeys << key
				end
			end
		}

		# add all the unblocked keys to the list of available keys
		@avlKeysMutex.synchronize {
			unblockedKeys.each do |key|
				@availableKeys[key.key] = key
			end
		}
	end

end

def LOG_MSG(msg)
	time = Time.now
	puts "LOG :: #{time} :: #{msg}"
end