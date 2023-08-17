------------------------------------------------------------------------
--- @file mac.lua
--- @brief (mac) utility.
--- Utility functions for the mac_header structs 
--- Includes:
--- - mac constants
--- - mac header utility
--- - Definition of mac packets
------------------------------------------------------------------------

--[[
-- Use this file as template when implementing a new protocol (to implement all mandatory stuff)
-- Replace all occurrences of PROTO with your protocol (e.g. sctp)
-- Remove unnecessary comments in this file (comments inbetween [[...]]
-- Necessary changes to other files:
-- - packet.lua: if the header has a length member, adapt packetSetLength; 
-- 				 if the packet has a checksum, adapt createStack (loop at end of function) and packetCalculateChecksums
-- - proto/proto.lua: add mac.lua to the list so it gets loaded
--]]
local ffi = require "ffi"
require "proto.template"
local initHeader = initHeader


---------------------------------------------------------------------------
---- MAC constants 
---------------------------------------------------------------------------

--- MAC protocol constants
local mac = {}


---------------------------------------------------------------------------
---- MAC header
---------------------------------------------------------------------------

mac.headerFormat = [[
	uint8_t		lcid;
	uint8_t		elcid;
]]

--- Variable sized member
mac.headerVariableMember = nil

--- Module for mac_address struct
local macHeader = initHeader()
macHeader.__index = macHeader

--[[ for all members of the header with non-standard data type: set, get, getString 
-- for set also specify a suitable default value
--]]
--- Set the lcid.
--- @param int lcid of the mac header as A bit integer.
function macHeader:setLcid(int)
	int = int or 0
	self.lcid = hton(int)
end

--- Retrieve the Lcid.
--- @return Lcid as A bit integer.
function macHeader:getLcid()
	return hton(self.lcid)
end

--- Retrieve the Lcid as string.
--- @return Lcid as string.
function macHeader:getLcidString()
	return self:getLcid()
end

function macHeader:setElcid(int)
	int = int or 0
	self.elcid = hton(int)
end

--- Retrieve the Elcid.
--- @return Elcid as A bit integer.
function macHeader:getElcid()
	return hton(self.elcid)
end

--- Retrieve the Elcid as string.
--- @return Elcid as string.
function macHeader:getElcidString()
	return self:getElcid()
end

--- Set all members of the PROTO header.
--- Per default, all members are set to default values specified in the respective set function.
--- Optional named arguments can be used to set a member to a user-provided value.
--- @param args Table of named arguments. Available arguments: PROTOXYZ
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @code
--- fill() -- only default values
--- fill{ PROTOXYZ=1 } -- all members are set to default values with the exception of PROTOXYZ, ...
--- @endcode
function macHeader:fill(args, pre)
	args = args or {}
	pre = pre or "mac"

	self:setXYZ(args[pre .. "Lcid"])
	self:setXYZ(args[pre .. "Elcid"])
end

--- Retrieve the values of all members.
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @return Table of named arguments. For a list of arguments see "See also".
--- @see macHeader:fill
function macHeader:get(pre)
	pre = pre or "mac"

	local args = {}
	args[pre .. "Lcid"] = self:getLcid() 
	args[pre .. "Elcid"] = self:getElcid() 

	return args
end

--- Retrieve the values of all members.
--- @return Values in string format.
function macHeader:getString()
	return "mac: LCID " .. self:getLcidString() .. "eLCID" .. self:getElcid()
end

--- Resolve which header comes after this one (in a packet)
--- For instance: in tcp/udp based on the ports
--- This function must exist and is only used when get/dump is executed on 
--- an unknown (mbuf not yet casted to e.g. tcpv6 packet) packet (mbuf)
--- @return String next header (e.g. 'eth', 'ip4', nil)
function macHeader:resolveNextHeader()
	return nil
end	

--- Change the default values for namedArguments (for fill/get)
--- This can be used to for instance calculate a length value based on the total packet length
--- See proto/ip4.setDefaultNamedArgs as an example
--- This function must exist and is only used by packet.fill
--- @param pre The prefix used for the namedArgs, e.g. 'PROTO'
--- @param namedArgs Table of named arguments (see See more)
--- @param nextHeader The header following after this header in a packet
--- @param accumulatedLength The so far accumulated length for previous headers in a packet
--- @return Table of namedArgs
--- @see macHeader:fill
function macHeader:setDefaultNamedArgs(pre, namedArgs, nextHeader, accumulatedLength)
	return namedArgs
end


------------------------------------------------------------------------
---- Metatypes
------------------------------------------------------------------------

mac.metatype = macHeader


return mac