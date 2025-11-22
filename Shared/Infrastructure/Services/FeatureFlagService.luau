local RunService = game:GetService("RunService")

---@class FeatureFlagService
---@field _flags table<string, boolean> Текущие значения флагов
---@field _defaultFlags table<string, boolean> Значения по умолчанию
---@field _isServer boolean
local FeatureFlagService = {}
FeatureFlagService.__index = FeatureFlagService

---@param defaultFlags table<string, boolean>
---@return FeatureFlagService
function FeatureFlagService.new(defaultFlags)
	local self = setmetatable({}, FeatureFlagService)
	self._isServer = RunService:IsServer()
	self._defaultFlags = defaultFlags or {}
	self._flags = {}

	-- Копируем значения по умолчанию
	for flagName, value in pairs(self._defaultFlags) do
		self._flags[flagName] = value
	end

	return self
end

---@param flagName string
---@return boolean
function FeatureFlagService:isEnabled(flagName)
	return self._flags[flagName] == true
end

---@param flagName string
---@param enabled boolean
function FeatureFlagService:setFlag(flagName, enabled)
	if not self._isServer then
		return
	end

	self._flags[flagName] = enabled
end

---@param flagName string
---@return boolean
function FeatureFlagService:getDefaultValue(flagName)
	return self._defaultFlags[flagName] or false
end

---Сбросить флаг к значению по умолчанию
---@param flagName string
function FeatureFlagService:resetFlag(flagName)
	if not self._isServer then
		return
	end

	self._flags[flagName] = self._defaultFlags[flagName]
end

---Получить все активные флаги
---@return table<string, boolean>
function FeatureFlagService:getAllFlags()
	return table.clone(self._flags)
end

---Получить флаги для клиента (только включенные)
---@return table<string, boolean>
function FeatureFlagService:getClientFlags()
	local result = {}
	for flagName, value in pairs(self._flags) do
		if value then
			result[flagName] = true
		end
	end
	return result
end

return FeatureFlagService
