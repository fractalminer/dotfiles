-----------------------------------------------------------------
-- Lua snippets.
-----------------------------------------------------------------
local ls = require( 'luasnip' )
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require( 'luasnip.extras.fmt' ).fmt

local up = 'unpack';
local unpack = _G[up] -- fool the linter.

local S = {} -- Will hold result.

local function add_s( tbl ) table.insert( S, s( unpack( tbl ) ) ) end

-- Normally the supplied function in a function node takes a list
-- of arguments; this will unpack them so that our function can
-- just take normal arguments.
local function wrapf( func )
  return function( args ) return func( unpack( args ) ) end
end

-----------------------------------------------------------------
-- Snippets.
-----------------------------------------------------------------
local function center_offset( node )
  local text = node[1]
  local len = #text
  local preamble_len = 3 -- "-- "
  -- We could get the 65 from vim.o.textwidth, but that's prob-
  -- ably fancier than we need here.
  local max_len = 65 - preamble_len
  if len >= max_len then return '' end
  len = math.floor( (max_len - len) / 2 )
  return string.rep( ' ', math.max( 0, len - preamble_len ) )
end

-- This is a section header where the text entered will be cen-
-- tered in real time as the user types.
add_s{
  '=csection', fmt( [[
      -----------------------------------------------------------------
      -- {}{}
      -----------------------------------------------------------------
      {}
    ]], { f( wrapf( center_offset ), { 1 } ), i( 1 ), i( 0 ) } ),
}

local function required_last( node )
  local text = node[1]
  local last = text:match( '.*%.(.*)' )
  last = last or text
  last = last:gsub( '-', '_' )
  return last or '???'
end

-- This is a smart require statement that will extract the last
-- component of the module being required and will use it to name
-- the local variable holding the module.
add_s{
  '=req', fmt( 'local {} = require( \'{}\' )',
               { f( wrapf( required_last ), { 1 } ), i( 1 ) } ),
}

-- This is a smart alias statement that will extract the last
-- component of the thing being aliased and will use it to name
-- the alias.
add_s{
  '=ali', fmt( 'local {} = assert( {} )',
               { f( wrapf( required_last ), { 1 } ), i( 1 ) } ),
}

-----------------------------------------------------------------
-- Finished
-----------------------------------------------------------------
return {}, S
