local RunService = game:GetService("RunService")
---@class RemoteEventService : IRemoteEventService
---@field _connections table<string, RBXScriptConnection>
---@field remoteEvent RemoteEvent
local RemoteEventService = {}
RemoteEventService.__index = RemoteEventService

---@param remoteEvent RemoteEvent
---@return RemoteEventService
function RemoteEventService.new(remoteEvent)
	local self = setmetatable({}, RemoteEventService)
	self._isServer = RunService:IsServer()
	self.remoteEvent = remoteEvent
	self._connections = {}

	return self
end

---@param event string
---@param callback fun(...) -> ()
function RemoteEventService:connectToEvent(event, callback)
	if self._isServer then
		self._connections[event] = self.remoteEvent.OnServerEvent:Connect(function(player, _event, args)
			if event == _event then
				callback(player, args)
			end
		end)
	else
		self._connections[event] = self.remoteEvent.OnClientEvent:Connect(function(_event, args)
			if event == _event then
				callback(args)
			end
		end)
	end
end

---@param event string
function RemoteEventService:disconnectFromEvent(event)
	self._connections[event]:Disconnect()
	self._connections[event] = nil
end

---@param event string
---@param args any[]
function RemoteEventService:fireServer(event, args)
	self.remoteEvent:FireServer(event, args)
end

---@param event string
---@param player Player
---@param args any[]
function RemoteEventService:fireClient(player, event, args)
	self.remoteEvent:FireClient(player, event, args)
end

---@param event string
---@param args any[]
function RemoteEventService:fireAll(event, args)
	self.remoteEvent:FireAllClients(event, args)
end

return RemoteEventService
