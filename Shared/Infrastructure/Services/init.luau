local RemoteEventService = require(script.RemoteEventService)
local FeatureFlagService = require(script.FeatureFlagService)
local LoggerService = require(script.LoggerService)

---@class SharedInfrastructureServices
---@field remoteEvent RemoteEvent
---@field diContainer DIContainer
local Services = {}
Services.__index = Services

---@param diContainer DIContainer
---@param remoteEvent RemoteEvent
---@return SharedInfrastructureServices
function Services.new(diContainer, remoteEvent)
	local self = setmetatable({}, Services)
	self.diContainer = diContainer
	self.remoteEvent = remoteEvent
	self:_registerServices()
	return self
end

function Services:_registerServices()
	self.diContainer:singleton("RemoteEventService", function()
		return RemoteEventService.new(self.remoteEvent)
	end)

	-- Регистрируем LoggerService
	self.diContainer:singleton("Logger", function()
		return LoggerService.new(LoggerService.LEVELS.INFO)
	end)

	-- Регистрируем FeatureFlagService с зависимостью от констант
	self.diContainer:singleton("FeatureFlagService", function()
		local constants = self.diContainer:resolve("Constants")
		return FeatureFlagService.new(constants.FeatureFlags)
	end)

end

return Services
