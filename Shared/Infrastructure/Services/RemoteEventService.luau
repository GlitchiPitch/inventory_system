local RunService = game:GetService("RunService")
---@class RemoteEventService : IRemoteEventService
---@field _connections table<string, RBXScriptConnection>
---@field remoteEvent RemoteEvent
local RemoteEventService = {}
RemoteEventService.__index = RemoteEventService

---@param remoteEvent RemoteEvent
---@param logger LoggerService
---@return RemoteEventService
function RemoteEventService.new(remoteEvent, logger)
	local self = setmetatable({}, RemoteEventService)
	self._isServer = RunService:IsServer()
	self.remoteEvent = remoteEvent
	self._connections = {}
	self.logger = logger

	return self
end

---@param event string
---@param callback fun(...) -> ()
function RemoteEventService:connectToEvent(event, callback)
	self.logger:debug("RemoteEventService", "Connecting to event:", event)
	if self._isServer then
		self._connections[event] = self.remoteEvent.OnServerEvent:Connect(function(player, _event, args)
			if event == _event then
				self.logger:debug("RemoteEventService", "Received server event:", event, "from player:", player.Name)
				callback(player, args)
			end
		end)
	else
		self._connections[event] = self.remoteEvent.OnClientEvent:Connect(function(_event, args)
			if event == _event then
				self.logger:debug("RemoteEventService", "Received client event:", event)
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
	self.logger:debug("RemoteEventService", "Firing server event:", event)
	self.remoteEvent:FireServer(event, args)
end

---@param event string
---@param player Player
---@param args any[]
function RemoteEventService:fireClient(player, event, args)
	self.logger:debug("RemoteEventService", "Firing client event:", event, "to player:", player.Name)
	self.remoteEvent:FireClient(player, event, args)
end

---@param event string
---@param args any[]
function RemoteEventService:fireAll(event, args)
	self.logger:debug("RemoteEventService", "Firing event to all clients:", event)
	self.remoteEvent:FireAllClients(event, args)
end

return RemoteEventService
