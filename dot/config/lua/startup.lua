-----------------------------------------------------------------
-- Aliases.
-----------------------------------------------------------------
local format = string.format
local getenv = os.getenv

-----------------------------------------------------------------
-- Constants.
-----------------------------------------------------------------
local HOME = getenv( 'HOME' )

-----------------------------------------------------------------
-- Helpers.
-----------------------------------------------------------------
local function ls( tbl )
  for k, v in pairs( tbl ) do print( k, v ) end
end

-----------------------------------------------------------------
-- Package path.
-----------------------------------------------------------------
local function path_add( fmt, ... )
  local what = format( fmt, ... )
  package.path = format( '%s;%s', package.path, what )
end

local function cpath_add( fmt, ... )
  local what = format( fmt, ... )
  package.cpath = format( '%s;%s', package.cpath, what )
end

path_add(  '%s%s', HOME, '/dev/moonlib/?.lua' )
cpath_add( '%s%s', HOME, '/.local/lib/lua/5.4/?.so' )

-----------------------------------------------------------------
-- Globals.
-----------------------------------------------------------------
_G.ls = ls