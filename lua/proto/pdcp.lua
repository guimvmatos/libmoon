------------------------------------------------------------------------
--- @file pdcp.lua
--- @brief (pdcp) utility.
--- Utility functions for the pdcp_header structs 
--- Includes:
--- - PDCP constants
--- - PDCP header utility
--- - Definition of PDCP packets
------------------------------------------------------------------------

--[[
-- Use this file as template when implementing a new protocol (to implement all mandatory stuff)
-- Replace all occurrences of PROTO with your protocol (e.g. sctp)
-- Remove unnecessary comments in this file (comments inbetween [[...]]
-- Necessary changes to other files:
-- - packet.lua: if the header has a length member, adapt packetSetLength; 
-- 				 if the packet has a checksum, adapt createStack (loop at end of function) and packetCalculateChecksums
-- - proto/proto.lua: add pdcp.lua to the list so it gets loaded
--]]
local ffi = require "ffi"
require "proto.template"
local initHeader = initHeader


---------------------------------------------------------------------------
---- PDCP constants 
---------------------------------------------------------------------------

--- PDCP protocol constants
local pdcp = {}


---------------------------------------------------------------------------
---- PDCP header
---------------------------------------------------------------------------

pdcp.headerFormat = [[
	uint8_t		oct; 
    uint8_t		pdcp_sn;
]]
--oct = R1, R2, R3, R4 e pdcp_sn1 (4 bits for R's and 4 for pdcp_sn1)

--- Variable sized member
pcdp.headerVariableMember = nil

--- Module for pcdp_address struct
local pcdpHeader = initHeader()
pcdpHeader.__index = pcdpHeader

--[[ for all members of the header with non-standard data type: set, get, getString 
-- for set also specify a suitable default value
--]]
--- Set the oct.
--- @param int oct of the PDCP header as A bit integer.
function pcdpHeader:setOct(int)
	int = int or 0
    self.oct = hton(int)
end

--- Retrieve the oct.
--- @return oct as A bit integer.
function pcdpHeader:getOct()
	return hton(self.oct)
end

--- Retrieve the oct as string.
--- @return oct as string.
function pcdpHeader:getOctString()
	return self.getOct()
end

--- @param int pdcp_sn of the PDCP header as A bit integer.
function pcdpHeader:setPdcp_sn(int)
	int = int or 0
    self.pdcp_sn = hton(int)
end

--- Retrieve the oct.
--- @return oct as A bit integer.
function pcdpHeader:getPdcp_sn()
	return hton(self.pdcp_sn)
end

--- Retrieve the oct as string.
--- @return oct as string.
function pcdpHeader:getPdcp_snString()
	return self.getPdcp_sn()
end

--- Set all members of the pdcp header.
--- Per default, all members are set to default values specified in the respective set function.
--- Optional named arguments can be used to set a member to a user-provided value.
--- @param args Table of named arguments. Available arguments: PROTOXYZ
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @code
--- fill() -- only default values
--- fill{ PROTOXYZ=1 } -- all members are set to default values with the exception of PROTOXYZ, ...
--- @endcode
function pdcpHeader:fill(args, pre)
	args = args or {}
	pre = pre or "pdcp"

	self:setOct(args[pre .. "Oct"])
    self:setPdcp_sn(args[pre .. "Pdcp_sn"])
end

--- Retrieve the values of all members.
--- @param pre prefix for namedArgs. Default 'PROTO'.
--- @return Table of named arguments. For a list of arguments see "See also".
--- @see pdcpHeader:fill
function pdcpHeader:get(pre)
	pre = pre or "pdcp"

	local args = {}
	args[pre .. "Oct"] = self:getOct() 
    args[pre .. "Pdcp_sn"] = self:getPdcp_sn() 

	return args
end

--- Retrieve the values of all members.
--- @return Values in string format.
function pdcpHeader:getString()
	return "PDCP 1th octeto" .. self:getOctString() .. "PDCP_SN " .. self:getPdcp_snString()
end

--- Resolve which header comes after this one (in a packet)
--- For instance: in tcp/udp based on the ports
--- This function must exist and is only used when get/dump is executed on 
--- an unknown (mbuf not yet casted to e.g. tcpv6 packet) packet (mbuf)
--- @return String next header (e.g. 'eth', 'ip4', nil)
function pdcpHeader:resolveNextHeader()
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
function pdcpHeader:setDefaultNamedArgs(pre, namedArgs, nextHeader, accumulatedLength)
	return namedArgs
end


------------------------------------------------------------------------
---- Metatypes
------------------------------------------------------------------------

pdcp.metatype = pdcpHeader


return pdcp