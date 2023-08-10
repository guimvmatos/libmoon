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
	int = int or 0 --determinar todo
	self.tci = hton1t(int)

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

todo, fazer o mesmo esqueme acima, set, get, getstring para o ether_type

--- Set all members of the PROTO header.
--- Per default, all members are set to default values specified in the respective set function.
--- Optional named arguments can be used to set a member to a user-provided value.
--- @param args Table of named arguments. Available arguments: PROTOXYZ
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @code
--- fill() -- only default values
--- fill{ PROTOXYZ=1 } -- all members are set to default values with the exception of PROTOXYZ, ...
--- @endcode
function PROTOHeader:fill(args, pre)
	args = args or {}
	pre = pre or "PROTO"

	self:setXYZ(args[pre .. "PROTOXYZ"])
end

--- Retrieve the values of all members.
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @return Table of named arguments. For a list of arguments see "See also".
--- @see PROTOHeader:fill
function PROTOHeader:get(pre)
	pre = pre or "PROTO"

	local args = {}
	args[pre .. "PROTOXYZ"] = self:getXYZ() 

	return args
end

--- Retrieve the values of all members.
--- @return Values in string format.
function PROTOHeader:getString()
	return "PROTO " .. self:getXYZString()
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
--- @param pre The prefix used for the namedArgs, e.g. 'PROTO'
--- @param namedArgs Table of named arguments (see See more)
--- @param nextHeader The header following after this header in a packet
--- @param accumulatedLength The so far accumulated length for previous headers in a packet
--- @return Table of namedArgs
--- @see PROTOHeader:fill
function PROTOHeader:setDefaultNamedArgs(pre, namedArgs, nextHeader, accumulatedLength)
	return namedArgs
end


------------------------------------------------------------------------
---- Metatypes
------------------------------------------------------------------------

PROTO.metatype = PROTOHeader


return PROTO
