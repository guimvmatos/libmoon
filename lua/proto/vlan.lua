------------------------------------------------------------------------
--- @file vlan.lua
--- @brief VLAN utility.
--- Utility functions for the PROTO_header structs 
--- Includes:
--- - Vlan constants
--- - Vlan header utility
--- - Definition of VLAN packets
------------------------------------------------------------------------

--[[
-- Use this file as template when implementing a new protocol (to implement all mandatory stuff)
-- Replace all occurrences of PROTO with your protocol (e.g. sctp)
-- Remove unnecessary comments in this file (comments inbetween [[...]])
-- Necessary changes to other files:
-- - packet.lua: if the header has a length member, adapt packetSetLength; 
-- 				 if the packet has a checksum, adapt createStack (loop at end of function) and packetCalculateChecksums
-- - proto/proto.lua: add PROTO.lua to the list so it gets loaded
--]]
local ffi = require "ffi"

require "utils"
require "vlan.template"
local initHeader = initHeader


---------------------------------------------------------------------------
---- VLAN constants 
---------------------------------------------------------------------------

--- vlan protocol constants
local vlan = {}


---------------------------------------------------------------------------
---- VLAN header
---------------------------------------------------------------------------

vlan.headerFormat = [[
	uint16_t	tci;
	uint16_t	ether_type;
]]

--- Variable sized member
vlan.headerVariableMember = nil

--- Module for PROTO_address struct
local vlanHeader = initHeader()
vlanHeader.__index = vlanHeader

--[[ for all members of the header with non-standard data type: set, get, getString 
-- for set also specify a suitable default value
--]]
--- Set the TCI
--- @param int TCI of the Vlan header as 16 bit integer.
function vlanHeader:setTci(int)
	int = int or 4095
	self.tci = hton1t(int)
end

--- Retrieve the TCI.
--- @return TCI as 16 bit integer.
function vlanHeader:getTci()
	return hton16(self.tci)
end

--- Retrieve the TCI as string.
--- @return TCI as string.
function vlanHeader:getTciString()
	return self:getTci()
end

--- Set the Ether_type
--- @param int Ether_type of the Vlan header as 16 bit integer.
function vlanHeader:setEtherType(int)
	int = int or 8100
	self.ether_type = hton1t(int)

--- Retrieve the Ether_type.
--- @return Ether_type as 16 bit integer.
function vlanHeader:getEtherType()
	return hton16(self.ether_type)
end

--- Retrieve the Ether_type as string.
--- @return Ether_type as string.
function vlanHeader:getEtherTypeString()
	return self:getEtherType()
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
function vlanHeader:fill(args, pre)
	args = args or {}
	pre = pre or "vlan"

	self:setTci(args[pre .. "Tci"])
	self:setEtherType(args[pre .. "Ether_type"])
end

--- Retrieve the values of all members.
--- @param pre prefix for namedArgs. Default 'vlan'.
--- @return Table of named arguments. For a list of arguments see "See also".
--- @see vlanHeader:fill
function vlanHeader:get(pre)
	pre = pre or "vlan"

	local args = {}
	args[pre .. "Tci"] = self:getTci()
	args[pre .. "Ether_type"] = self:getEtherType() 

	return args
end

--- Retrieve the values of all members.
--- @return Values in string format.
function vlanHeader:getString()
	return "VLAN TCI" .. self:getTciString() .. " Vlan EtherType " .. self:getEtherTypeString()
end

--- Resolve which header comes after this one (in a packet)
--- For instance: in tcp/udp based on the ports
--- This function must exist and is only used when get/dump is executed on 
--- an unknown (mbuf not yet casted to e.g. tcpv6 packet) packet (mbuf)
--- @return String next header (e.g. 'eth', 'ip4', nil)
function PROTOHeader:resolveNextHeader()
	return nil
end	

--- Change the default values for namedArguments (for fill/get)
--- This can be used to for instance calculate a length value based on the total packet length
--- See proto/ip4.setDefaultNamedArgs as an example
--- This function must exist and is only used by packet.fill
--- @param pre The prefix used for the namedArgs, e.g. 'vlan'
--- @param namedArgs Table of named arguments (see See more)
--- @param nextHeader The header following after this header in a packet
--- @param accumulatedLength The so far accumulated length for previous headers in a packet
--- @return Table of namedArgs
--- @see PROTOHeader:fill
function vlanHeader:setDefaultNamedArgs(pre, namedArgs, nextHeader, accumulatedLength)
	return namedArgs
end


------------------------------------------------------------------------
---- Metatypes
------------------------------------------------------------------------

vlan.metatype = vlanHeader


return vlan
