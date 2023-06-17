--- Setup a Franken game mixing box contents and faction objects.
-- Must first do normal game setup so all Franken factions are in the factions
-- box (if any are not those factions and abilities, etc, are not included in
-- the Franken setup (e.g. base game only Franken)).
-- @author Darrell
-- #include <~/TI4-TTS/TI4/Franken/FrankenBox>

local _config = false

local DEFAULT_CONFIG = {
    Blue_count = 4,
    Powered_draft = false,
    Speaker_order_draft = false,
    Spage_tech = false,
    Ban_negatives = false,
    Ban_bad = false,
    Replace_components = false,
    Include_Franken_Pack = false,
    Include_Custom_Bans = false,
}

function _setConfig(config)
    _config = config
end

function getHelperClient(helperObjectName)
    local function getHelperObject()
        for _, object in ipairs(getAllObjects()) do
            if object.getName() == helperObjectName then return object end
        end
        error('missing object "' .. helperObjectName .. '"')
    end
    local helperObject = false
    local function getCallWrapper(functionName)
        helperObject = helperObject or getHelperObject()
        if not helperObject.getVar(functionName) then error('missing ' .. helperObjectName .. '.' .. functionName) end
        return function(parameters) return helperObject.call(functionName, parameters) end
    end
    return setmetatable({}, { __index = function(t, k) return getCallWrapper(k) end })
end
local _deckHelper = getHelperClient('TI4_DECK_HELPER')
local _factionHelper = getHelperClient('TI4_FACTION_HELPER')
local _gameDataHelper = getHelperClient('TI4_GAME_DATA_HELPER')
local _setupHelper = getHelperClient('TI4_SETUP_HELPER')
local _systemHelper = getHelperClient('TI4_SYSTEM_HELPER')
local _unitHelper = getHelperClient('TI4_UNIT_HELPER')
local _zoneHelper = getHelperClient('TI4_ZONE_HELPER')

-- Undraftable components are associated with a prerequisite item.  Along with
-- the name store the type to avoid any unexpected name collisions.
local TYPE = {
    ABILITY = 'ability',
    FLAGSHIP = 'flagship',
    HOME_SYSTEM = 'homeSystem',
    MECH = 'mech',
    AGENT = 'agent',
    COMMANDER = 'commander',
    HERO = 'hero'
}

-- 35 "Non Draft Parts"
local UNDRAFTABLE = {
    ['Alpha Wormhole Token'] = {}, -- TODO
    ['Beta Wormhole Token'] = {}, -- TODO
    ['Gamma Wormhole Token'] = {}, -- TODO
    ['Titan Note Token'] = {}, -- TODO
    ['Titan Sleeper Tokens Bag'] = {}, -- TODO
    ['Titan Ultimate Token'] = {}, -- TODO
    ['Tear Token (Cabal)'] = {}, -- TODO
    ['Tear Token (Nekro)'] = {}, -- TODO
    ['Valefar Assimilator X Token'] = {}, -- TODO
    ['Valefar Assimilator Y Token'] = {}, -- TODO
    ['Zero Strategy Token'] = {}, -- TODO
    ['Muaat Supernova Bag'] = {}, -- TODO
    ['Creuss Gate Tile'] = {}, -- TODO
    ['Custodia'] = {}, --TODO

    ['Antivirus'] = {
        prereq = { name = 'Technological Singularity', type = TYPE.ABILITY },
        faction = 'Nekro',
    },
    ['Artuno the Betrayer'] = {
        prereq = { name = 'The Company', type = TYPE.ABILITY },
        faction = 'Nomad',
    },
    ['Blackshade Infiltrator'] = {
        prereq = { name = 'Stall Tactics', type = TYPE.ABILITY },
        faction = 'Yssaril',
    },
    ['Brother Omar'] = {
        prereq = { name = 'Indoctrination', type = TYPE.ABILITY },
        faction = 'Yin',
    },
    ['Creuss Gate'] = {  -- XXX MISSING
        prereq = { name = 'Creuss', type = TYPE.HOME_SYSTEM },
        faction = 'Creuss',
    },
    ['Dark Pact'] = {
        prereq = { name = 'Dark Whispers', type = TYPE.ABILITY },
        faction = 'Empyrean',
    },
    ['Ember Colossus'] = {
        prereq = { name = 'Star Forge', type = TYPE.ABILITY },
        faction = 'Muaat',
    },
    ['Gift of Prescience'] = {
        prereq = { name = 'Telepathic', type = TYPE.ABILITY },
        faction = 'Naalu',
    },
    ['Hil Colish'] = {
        prereq = { name = 'Creuss', type = TYPE.HOME_SYSTEM },
        faction = 'Creuss',
    },
    ['It Feeds on Carrion'] = {
        prereq = { name = 'Dimensional Tear', type = TYPE.ABILITY },
        faction = 'Cabal',
    },
    ['Memoria II'] = {
        prereq = { name = 'Memoria I', type = TYPE.FLAGSHIP },
        faction = 'Nomad',
    },
    ["Moyin's Ashes"] = {
        prereq = { name = 'Indoctrination', type = TYPE.ABILITY },
        faction = 'Yin',
    },
    ['Promise of Protection'] = {
        prereq = { name = 'Pillage', type = TYPE.ABILITY },
        faction = 'Mentak',
    },
    ['Suffi An'] = {
        prereq = { name = 'Pillage', type = TYPE.ABILITY },
        faction = 'Mentak',
    },
    ['That Which Molds Flesh'] = {
        prereq = { name = 'Dimensional Tear', type = TYPE.ABILITY },
        faction = 'Cabal',
    },
    ['The Thundarian'] = {
        prereq = { name = 'The Company', type = TYPE.ABILITY },
        faction = 'Nomad',
    },
    ['Valefar Assimilator X'] = {
        prereq = { name = 'Technological Singularity', type = TYPE.ABILITY },
        faction = 'Nekro',
    },
    ['Valefar Assimilator Y'] = {
        prereq = { name = 'Technological Singularity', type = TYPE.ABILITY },
        faction = 'Nekro',
    },
    ['ZS Thunderbolt M2'] = {
        prereq = { name = 'Orbital Drop', type = TYPE.ABILITY },
        faction = 'Sol',
    },

    -- Discordant Stars
    ['Atropha'] = {},
    ['Auberon Elyrin'] = {},
    ['Autofabricator'] = {},
    ['Automatons Token'] = {},
    ['Axis Order - Carrier'] = {},
    ['Axis Order - Cruiser'] = {},
    ['Axis Order - Destroyers'] = {},
    ['Axis Order - Dreadnought'] = {},
    ['Branch Office - Broadcast Hub Token'] = {},
    ['Branch Office - Broadcast Hub'] = {},
    ['Branch Office - Orbital Shipyard'] = {},
    ['Branch Office - Reserve Bank Token'] = {},
    ['Branch Office - Reserve Bank'] = {},
    ['Branch Office - Tax Haven'] = {},
    ['Branch Office'] = {},
    ['Demi-Queen MdcKssK'] = {},
    ['Designer TckVsk'] = {},
    ['Dume Tathu'] = {},
    ['Heart of Rebellion Token'] = {},
    ['Jarl Vel & Jarl Jotrun'] = {},
    ['Kantrus, The Lord'] = {},
    ['Khaz-Rin Li-Zho'] = {},
    ['Lactarious Indigo'] = {},
    ['Liberator'] = {},
    ['Myko-Mentori Commodity Token'] = {},
    ['Omen Dice'] = {},
    ['Omen Die'] = {},
    ['Oro-Zhin Elite'] = {},
    ['Read the Fates'] = {},
    ['Singularity Point'] = {},
    ['The Lord Flagship Card'] = {},
    ['Trap: Account Siphon'] = {},
    ['Trap: Feint'] = {},
    ['Trap: Gravitic Inhibitor'] = {},
    ['Trap: Interference Grid'] = {},
    ['Trap: Minefields'] = {},
    ['Traps'] = {},
    ['Vera Khage'] = {},
    ['Wound Token'] = {},
    ['Zelian Asteroid Tile'] = {},
    ['Voidflare Warden II'] = {},
    ['Stealth Insertion'] = {},
    ['Paranoia'] = {},
    ['For Glory'] = {},
    ['Binding Debts'] = {},
    ['Ancient Blueprints'] = {},
    ['Jack Hallard'] = {},
    ['Biotic Weapons'] = {},
    ['Silas Deriga'] = {},
    ['Auriga'] = {},
    ['Ghoti Wayfarers Tile'] = {},
}

-- Remove this if/when a faction table supports multiple heroes.
local HACK_OVERRIDE_LEADER_DST = {
    ['Korela, The Lady'] = 'Heroes',
    ['Dannel of the Tenth'] = 'Heroes',
    ['Dannel of the Tenth Ω'] = 'Heroes',
    ['Xxekir Grom'] = 'Heroes',
    ['Xxekir Grom Ω'] = 'Heroes',
    ["M'aban"] = 'Commanders',
    ["M'aban Ω"] = 'Commanders',
    ['Brother Omar'] = 'Commanders',
    ['Brother Omar Ω'] = 'Commanders',
    ["Z'eu Ω"] = 'Agents',
    ['Brother Milor Ω'] = 'Agents',
    ['Iconoclast Ω'] = 'Mechs',
}

-- Removes these items from draft bags after the process.
local COMPONENTS_TO_BAN_ALWAYS = {
    ['Brother Milor'] = {},
    ["Z'eu"] = {},
    ['Keleres ~ Xxcha Tile'] = {},
    ['Keleres ~ Mentak Tile'] = {},
    ['Keleres ~ Argent Tile'] = {},
    ['Pillage'] = {},
}

local COMPONENTS_TO_BAN_NEGATIVE = {
    ['Lithoids'] = {},
    ['Propagation'] = {},
    ['Targeted Acquisition'] = {},
    ['Cybernetic Madness'] = {},
    ['Flotilla'] = {},
    ['Hubris'] = {},
    ['Fragile'] = {},
    ['Mitosis'] = {},
    ['Ghosts of Creuss Tile'] = {},
}

local COMPONENTS_TO_BAN_BAD = {
    ['Mordred'] = {},
    ['Iconoclast'] = {},
    ['Shield Paling'] = {},
    ['Field Marshal Mercer'] = {},
    ['Solis Morden'] = {},
    ['Privateer'] = {},
    ['Sardakk Starting Tech'] = {},
    ['Mori Commodities'] = {},
    ['Khrask Starting Units'] = {},
    ['Free Systems Compact Tile'] = {},
}

local COMPONENTS_TO_BAN_CUSTOM = {}

function setCustomBans(customBans)
    COMPONENTS_TO_BAN_ALWAYS = customBans
end

local function isUndraftable(objectName, dstName)
    assert(type(objectName) == 'string')
    return UNDRAFTABLE[objectName] and true
end

local function isRemoveThis(objectName)
    assert(type(objectName) == 'string')
    if COMPONENTS_TO_BAN_NEGATIVE[objectName] and _config.Ban_negatives then
        return true and true
    elseif COMPONENTS_TO_BAN_BAD[objectName] and _config.Ban_bad then
        return true and true
    elseif COMPONENTS_TO_BAN_CUSTOM[objectName] and _config.Include_Custom_Bans then
        return true and true
    else
        return COMPONENTS_TO_BAN_ALWAYS[objectName] and true
    end
end

local REPLACE_LIST = {}
local REPLACE_LIST_GUIDS = {}
local replace_bag = nil

local function fetch_replacing()
    for _, object in ipairs(getAllObjects()) do
        if object.getName() == 'Replacing Components' then
            replace_bag = object
            for _, object in replace_bag.getObjects() do
                REPLACE_LIST[object.name] = true
                REPLACE_LIST_GUIDS[object.name] = object.guid
            end
        break
        end
    end
end

local function replaceThis(objectName)
    assert(type(objectName) == 'string')
    return REPLACE_LIST[objectName] and true
end

local function moveReplacingComponent(name, dstName)
    local dstAttrs = FrankenBags._nameToBagAttrs[dstName]
    assert(dstAttrs, 'unknown bag "' .. dstName .. '"')
    local dst = dstAttrs.bag
    assert(dst, 'missing bag "' .. dstName .. '"')

    replace_bag.takeObject({
        position          = replace_bag.getPosition() + vector(0, 8, 0),
        callback_function = function(object) dst.putObject(object) end,
        smooth            = false,
        guid              = REPLACE_LIST_GUIDS[name]
    })  
end

local function addBanNegative()
    for item, key in ipairs(COMPONENTS_TO_BAN_NEGATIVE) do
        COMPONENTS_TO_BAN_ALWAYS[key] = item
    end
end

local function addBanBad()
    for item, key in ipairs(COMPONENTS_TO_BAN_BAD) do
        COMPONENTS_TO_BAN_ALWAYS[key] = item
    end
end

local function addBanCustom()
    for item, key in ipairs(COMPONENTS_TO_BAN_CUSTOM) do
        COMPONENTS_TO_BAN_ALWAYS[key] = item
    end
end


-- Unpack items directly to these positions.
local UNPACK_TRANSFORMS = {
    ['A. Draft'] = {
        position = {100, 2, -17},
        rotation = {0, 90, 0},
    },
    ['B. Build Galaxy'] = {
        position = {95, 3, -17},
        rotation = {0, 90, 0},
    },
    ['C. Reveal'] = {
        position = {90, 4, -17},
        rotation = {0, 90, 0},
    },
    ['D. Build Factions'] = {
        position = {85, 5, -17},
        rotation = {0, 90, 0},
    },
}

local CLONE_TO_HIDDEN = {
    'Frankenstein Checklist',
}

local HELP_MESSAGE = [[
WELCOME TO FRANKEN

First, use the game setup tile to choose between base game, PoK, etc.  This Franken tool will create draft pools from available factions.

To use homebrew factions, make sure their factions boxes are inside a container on the table named "(whatever) Faction Pack", as well as their Franken components are present inside the Franken box.  For example, the "Blue Space Faction Pack" is already supported.

Then use the right-click options in order:

1. Gather draft items: creates draft source bags, moving Franken tiles from the Franken box and faction components from faction boxes.  Undraftable items are placed in the "Non Draft Parts" bag.

Before proceeding, remove any "banned" abilities or components from the draft source bags.

2. Build draft bags: creates one bag per player with the correct draft items.  This also removes the draft source bags (stowing them in the Franken box if needed).

3. Remove draft bags: removes draft bags (stowing them in the Franken box) and per-player hidden zones.

Home system planet cards are in the planets deck.]]
local function printHelpMessage()
    local delim = ''
    for _ = 1, 20 do
        delim = delim .. '\u{2550}'
    end
    local message = {
        delim,
        HELP_MESSAGE,
        delim
    }
    message = table.concat(message, '\n')
    printToAll(message, 'Yellow')
end

-------------------------------------------------------------------------------

local _extraDraftBag = false

function onLoad(save_state)
    self.addContextMenuItem('0. HELP', printHelpMessage)
    self.addContextMenuItem('1. Gather draft items', function() startLuaCoroutine(self, 'gatherDraftItemsCoroutine') end)
    self.addContextMenuItem('2. Build draft bags', function() startLuaCoroutine(self, 'buildDraftBagsCoroutine') end)
    self.addContextMenuItem('3. Remove draft bags', function() startLuaCoroutine(self, 'removeDraftBagsCoroutine') end)

    self.addContextMenuItem('Report Factions', function() _factionHelper.reportFactions() end)
    self.addContextMenuItem('Toggle extra bag', toggleExtraDraftBag)

    for _, object in ipairs(self.getObjects()) do
        if object.name == 'Franken Setup Options' then
            object = self.takeObject({
                index = object.index,
                rotation = { x = 0, y = 0, z = 180}
            })

            break
        end
    end

    local box_detected = false
    for _, object in ipairs(getAllObjects()) do
        if object.tag == 'Bag' then
            local name = object.getName()
            if name == 'Franken Box' then
                if box_detected then
                    local _zoneHelper = getHelperClient('TI4_ZONE_HELPER')
                    local color = _zoneHelper.zoneFromPosition(self.getPosition())
                    if not color then
                        color = "general"
                    end
                    printToAll("WARNING, FRANKEN BOX WAS COPIED to " .. color .. " area ", 'Red')

                    break
                end
                box_detected = true
            end
        end
    end

    -- Automatically retrieve setup menu

end

function toggleExtraDraftBag()
    local log = _getLog('Extra draft bag')

    _extraDraftBag = not _extraDraftBag
    local message = {
        _extraDraftBag and 'Enabling' or 'Disabling',
        ' extra draft bag'
    }
    log.i(table.concat(message, ''))
end

local _1_gatherDone = false

function gatherDraftStart()
    startLuaCoroutine(self, 'gatherDraftItemsCoroutine')
end

function gatherDraftItemsCoroutine()
    local log = _getLog('Gather draft items')

    -- Make sure setup is finished and no factions were already unpacked.
    for _, object in ipairs(getAllObjects()) do
        if object.getName() == 'Game Setup Options' and object.tag == 'Generic' then
            log.e('Game Setup Options not done (please select PoK, etc), aborting')
            return 1
        end
    end
    for color, faction in pairs(_factionHelper.allFactions(false)) do
        log.e(color .. ' has already unpacked a faction, aborting')
        return 1
    end
    if _1_gatherDone then
        log.e('already done, aborting')
        return 1
    end
    log.i('starting')

    log.i('telling other tools this is Franken')
    _gameDataHelper.addExtraData({
        name = 'FrankenBox',
        value = true
    })

    Add_speaker()
    coroutine.yield(0)

    if _config.Ban_negatives then
        addBanNegative()
    end
    if _config.Ban_bad then
        addBanBad()
    end

    if _config.Include_Custom_Bans then
        addBanCustom()
    end

    if _config.Replace_components then
        fetch_replacing()
    end
    _sendOnFrankenEnabled(true)
    coroutine.yield(0)

    log.i('unpacking Franken note cards')
    _unpackGlobal()
    coroutine.yield(0)

    log.i('creating draft source bags')
    FrankenBags.createDraftSourceBags()
    coroutine.yield(0)

    log.i('moving Franken tiles')
    FrankenBags.fillSourceBagsFromSelf()
    coroutine.yield(0)

    log.i('moving faction parts')
    FrankenBags.fillSourceBagsFromFactionBoxes()
    coroutine.yield(0)

    if _config.Include_Franken_Pack then
        log.i('moving franken pack')
        FrankbenBags.fillSourceBagsFromCustomBag()
        coroutine.yield(0)
    end

    log.i('moving codex 3 parts')
    FrankenBags.DoCodex3()
    coroutine.yield(0)

    _1_gatherDone = true
    log.i('finished')
    printToAll('FRANKEN: draft candidate bags assembled.  If you wish to remove any items do so now, then select "build draft bags" to proceed', 'Yellow')
    return 1
end

local _2_buildDone = false

function buildDraftStart()
    startLuaCoroutine(self, 'buildDraftBagsCoroutine')
end

function buildDraftBagsCoroutine()
    local log = _getLog('Build draft bags')
    if not _1_gatherDone then
        log.e('must do gather first, aborting')
        return 1
    elseif _2_buildDone then
        log.e('already done, aborting')
        return 1
    elseif not FrankenBags.validateSourceBagsQuantities() then
        log.e('validate failed, aborting')
        return 1
    end
    log.i('starting')

    log.i('creating draft bags')
    FrankenBags.createDraftBags()
    coroutine.yield(0)

    if _extraDraftBag then
        log.i('creating extra draft bag')
        FrankenBags.createExtraDraftBag()
        coroutine.yield(0)
    end

    log.i('creating draft hidden zone')
    HiddenZones.spawnCenter()
    coroutine.yield(0)

    log.i('filling draft bags')
    FrankenBags.fillDraftBags()
    coroutine.yield(0)

    log.i('removing draft hidden zone')
    HiddenZones.removeCenter()
    coroutine.yield(0)

    log.i('placing draft source bags inside Franken box (if want to inspect)')
    FrankenBags.stowDraftSourceBags()
    coroutine.yield(0)

    log.i('creating player hidden zones')
    HiddenZones.spawnPlayers()
    coroutine.yield(0)

    log.i('creating player items')
    HiddenZones.setupPlayerItems()
    coroutine.yield(0)

    _2_buildDone = true
    log.i('finished')
    printToAll('FRANKEN: draft bags assembled.  When the draft is complete select "remove draft bags" to remove draft bags and hidden zones', 'Yellow')
    return 1
end

function finishDraftStart()
    startLuaCoroutine(self, 'removeDraftBagsCoroutine')
end

function removeDraftBagsCoroutine()
    local log = _getLog('Remove draft bags')
    if not _2_buildDone then
        log.e('must do gather/build first, aborting')
        return 1
    end
    log.i('starting')

    log.i('removing player hidden zones')
    HiddenZones.removePlayers()
    coroutine.yield(0)

    log.i('placing draft bags inside Franken box (if want to inspect)')
    FrankenBags.stowDraftBags()
    coroutine.yield(0)

    log.i('finished')
    printToAll('FRANKEN: All set, good luck!', 'Yellow')
    return 1
end

-------------------------------------------------------------------------------

--- Tell other scripts this is Franken.
-- @param value : boolean, is Franken enabled?
function _sendOnFrankenEnabled(value)
    assert(type(value) == 'boolean')
    local listenerFunctionName = 'onFrankenEnabled'
    local listenerGuids = {}
    for _, object in ipairs(getAllObjects()) do
        if object.getVar(listenerFunctionName) then
            table.insert(listenerGuids, object.getGUID())
        end
    end
    for i, listenerGuid in ipairs(listenerGuids) do
        local function callListener()
            local listener = getObjectFromGUID(listenerGuid)
            if listener then
                listener.call(listenerFunctionName, value)
            end
        end
        Wait.frames(callListener, i)
    end
end

function _unpackGlobal()
    for name, transform in pairs(UNPACK_TRANSFORMS) do
        for _, entry in ipairs(self.getObjects()) do
            if entry.name == name then
                self.takeObject({
                    position          = transform.position,
                    rotation          = transform.rotation,
                    smooth            = true,
                    guid              = entry.guid
                })
                coroutine.yield(0)
            end
        end
    end
end

function _getLog(tag)
    assert(type(tag) == 'string')
    local function doLog(level, color)
        return function(message)
            printToAll(tag .. '/' .. level .. ': ' .. message, color)
        end
    end
    return {
        d = doLog('d', 'Grey'),
        i = doLog('i', 'Grey'),
        w = doLog('w', 'Grey'),
        e = doLog('e', 'Grey'),
    }
end

function _safeDelete(object)
    assert(type(object) == 'userdata')
    local deletedItems = _findItemOnTable('TI4 Deleted Items', 'Bag')
    if deletedItems then
        deletedItems.call('ignoreGuid', object.getGUID())
    end
    destroyObject(object)
end

local _findItemOnTableCache = {}
function _findItemOnTable(name, tag)
    assert(type(name) == 'string' and type(tag) == 'string')
    local key = name .. '|' .. tag
    local guid = _findItemOnTableCache[key]
    local object = getObjectFromGUID(guid)
    if object then
        return object
    end
    for _, object in ipairs(getAllObjects()) do
        if object.tag == tag and object.getName() == name then
            _findItemOnTableCache[key] = object.getGUID()
            return object
        end
    end
    error('_findItem: missing "' .. name .. '" with tag "' .. tag .. '"')
end

-------------------------------------------------------------------------------

HiddenZones = {
    ZONE = {
        PLAYER = {
            name = '_franken_player_',
            scale = { x = 20, y = 6, z = 10 },
        },
        CENTER = {
            name = '_franken_center_',
            scale = { x = 30, y = 30, z = 30 },
        }
    }
}

function HiddenZones.getPlayerTransform(color)
    assert(type(color) == 'string')
    local zoneAttributes = _zoneHelper.zoneAttributes(color)
    return {
        position = {
            x = zoneAttributes.center.x,
            y = zoneAttributes.center.y + HiddenZones.ZONE.PLAYER.scale.y / 2,
            z = zoneAttributes.center.z + 9 * (zoneAttributes.center.z > 0 and -1 or 1),
        },
        rotation = {
            x = 0,
            y = zoneAttributes.rotation.y,
            z = 0,
        },
    }
end

function HiddenZones.spawnCenter()
    local hiddenZone = spawnObject({
        type              = 'FogOfWarTrigger',
        position          = { x = 0, y = HiddenZones.ZONE.CENTER.scale.y / 2, z = 0 },
        rotation          = { x = 0, y = 0, z = 0 },
        scale             = HiddenZones.ZONE.CENTER.scale,
        callback_fucntion = nil,
        sound             = false,
        params            = {},
        snap_to_grid      = false,
    })
    hiddenZone.setValue('Teal')
    hiddenZone.setName(HiddenZones.ZONE.CENTER.name)
end

function HiddenZones.removeCenter()
    for _, object in ipairs(getAllObjects()) do
        if object.tag == 'Fog' and object.getName() == HiddenZones.ZONE.CENTER.name then
            _safeDelete(object)
        end
    end
end

function HiddenZones.spawnPlayers()
    for _, color in ipairs(_zoneHelper.zones()) do
        local transform = HiddenZones.getPlayerTransform(color)
        local hiddenZone = spawnObject({
            type              = 'FogOfWarTrigger',
            position          = transform.position,
            rotation          = transform.rotation,
            scale             = HiddenZones.ZONE.PLAYER.scale,
            callback_fucntion = nil,
            sound             = false,
            params            = {},
            snap_to_grid      = false,
        })
        hiddenZone.setValue(color)
        hiddenZone.setName(HiddenZones.ZONE.PLAYER.name)
    end
end

function HiddenZones.setupPlayerItems()
    -- Grab JSON
    local jsonList = {}
    for _, name in ipairs(CLONE_TO_HIDDEN) do
        for _, entry in ipairs(self.getObjects()) do
            if entry.name == name then
                local object = self.takeObject({
                    position          = self.getPosition() + vector(0, 5, 0),
                    smooth            = false,
                    guid              = entry.guid,
                })
                coroutine.yield(0)
                local json = object.getJSON()
                self.putObject(object)
                coroutine.yield(0)
                table.insert(jsonList, json)
            end
        end
    end

    -- Clone CLONE_TO_HIDDEN items.
    for _, color in ipairs(_zoneHelper.zones()) do
        local transform = HiddenZones.getPlayerTransform(color)
        local p = transform.position
        for i, json in ipairs(jsonList) do
            local clone = spawnObjectJSON({
                json = json,
                position = vector(p.x, p.y, p.z) + vector(i - 1 * 3, 3, 0),
                rotation = transform.rotation,
                sound             = false,
                snap_to_grid      = false,
            })
            clone.use_grid = false
            clone.use_snap_points = false
            clone.sticky = false
            coroutine.yield(0)
        end
    end

    -- Create per-player bags.
    for _, color in ipairs(_zoneHelper.zones()) do
        local transform = HiddenZones.getPlayerTransform(color)
        local p = transform.position
        local deltas = {
            { x = 4, y = 3, z = 0 },
            { x = 8, y = 3, z = 0 },
        }
        for _, delta in ipairs(deltas) do
            local bag = spawnObject({
                type = 'Bag',
                position = {
                    x = p.x + delta.x * (p.z < 1 and 1 or -1),
                    y = p.y + delta.y,
                    z = p.z + delta.z,
                },
                rotation = transform.rotation,
                sound = false,
                snap_to_grid = true,
            })
            bag.use_grid = true
            bag.use_snap_points = false
            bag.sticky = false
            coroutine.yield(0)
        end
        coroutine.yield(0)
    end
end

function HiddenZones.removePlayers()
    for _, object in ipairs(getAllObjects()) do
        if object.tag == 'Fog' and object.getName() == HiddenZones.ZONE.PLAYER.name then
            _safeDelete(object)
        end
    end
end

-------------------------------------------------------------------------------

FrankenBags = {
    DRAFT_SRC_RADIUS = 9,
    DRAFT_DST_RADIUS = 12,

    SOURCE_BAGS = {
        -- Franken and faction components.
        {
            name = 'Promissory Notes',
            count = 2,
        },
        {
            name = 'Starting Units',
            count = 2,
        },
        {
            name = 'Starting Techs',
            count = 2,
        },
        {
            name = 'Commodity Tiles',
            count = 2,
        },

        {
            name = 'Flagships',
            count = 2,
        },
        {
            name = 'Faction Techs',
            count = 3,
        },
        {
            name = 'Faction Abilities',
            count = 4,
        },
        {
            name = 'Agents',
            count = 2,
            pok = true,
        },
        {
            name = 'Commanders',
            count = 2,
            pok = true,
        },
        {
            name = 'Heroes',
            count = 2,
            pok = true,
        },
        {
            name = 'Mechs',
            count = 2,
            pok = true,
        },

        {
            name = 'Home Systems',
            count = 2,
        },
        -- External bags already on the table.
        {
            name = 'Blue Planet Tiles',
            count = { -1, 7, 6, 5, 4, 3, 2, 2 },
        },
        {
            name = 'Red Anomaly Tiles',
            count = { -1, 2, 2, 3, 2, 2, 1, 1 },
        },

        -- Keep these around.
        {
            name = 'Non Draft Parts',
            persist = true,
            pos = { x = -2, z = 5 },
            color = 'Pink',
        },
        {
            name = 'Base Unit Tiles',
            persist = true,
            pos = { x = 2, z = 5 },
            color = 'Pink',
        },

        -- Extra bag to manage removed from draft
        {
            name = 'Removed Parts',
            color = 'Grey',
            pos = { x = -2, z = -5},
        },
        {
            name = 'Replaced Parts',
            color = 'Grey',
            pos = { x = 2, z = -5},
        },
    },
    _nameToBagAttrs = false,
}

function Add_speaker()
    if _config.Speaker_order_draft then
        local speaker = {
            name = 'speaker order choice',
            count = 1,
        }
        table.insert(FrankenBags.SOURCE_BAGS, 13, speaker)
    end
end

--- Create (or move) source bags to the center area.
function FrankenBags.createDraftSourceBags()
    assert(not FrankenBags._nameToBagAttrs, 'FrankenBags.createDraftSourceBags: already created')
    local log = _getLog('FrankenBags.getDraftSourceBags')

    FrankenBags._nameToBagAttrs = {}
    local nameToBaseAttrs = {}

    for _, baseAttrs in ipairs(FrankenBags.SOURCE_BAGS) do
        nameToBaseAttrs[assert(baseAttrs.name)] = baseAttrs
    end

    local function addSourceBag(name, baseAttrs, extraAttrs)
        assert(type(name) == 'string' and type(baseAttrs) == 'table' and type(extraAttrs) == 'table')

        -- Validate src data.
        extraAttrs.src = extraAttrs.src or {}
        if extraAttrs.src.object then
            -- On table.
            assert(type(extraAttrs.src.object) == 'userdata')
            assert(type(extraAttrs.src.position) == 'table')
            assert(type(extraAttrs.src.rotation) == 'table')
            assert(type(extraAttrs.src.locked) == 'boolean')
        elseif extraAttrs.src.container then
            -- In bag.
            assert(type(extraAttrs.src.container) == 'userdata')
            assert(type(extraAttrs.src.guid) == 'string')
        end

        -- Only add once.
        assert(not FrankenBags._nameToBagAttrs[name], 'already added "' .. name .. '"')

        local attrs = {}
        for k, v in pairs(baseAttrs) do
            attrs[k] = v
        end
        for k, v in pairs(extraAttrs) do
            attrs[k] = v
        end

        FrankenBags._nameToBagAttrs[name] = attrs
    end

    -- Scan the table to find any existing bags.
    for _, object in ipairs(getAllObjects()) do
        local name = object.getName()
        local baseAttrs = nameToBaseAttrs[name]
        if object.tag == 'Bag' and baseAttrs then
            addSourceBag(name, baseAttrs, {
                src = {
                    object = object,
                    position = object.getPosition(),
                    rotation = object.getRotation(),
                    locked = object.getLock(),
                },
            })
        end
    end
    coroutine.yield(0)

    -- Find any bags inside self (only at the root level).
    for _, entry in ipairs(self.getObjects()) do
        local name = entry.name
        local baseAttrs = nameToBaseAttrs[name]
        if baseAttrs then
            addSourceBag(name, baseAttrs, {
                src = {
                    container = self,
                    guid = entry.guid,
                },
            })
        end
    end
    coroutine.yield(0)

    -- Add missing bags to create.
    for _, baseAttrs in ipairs(FrankenBags.SOURCE_BAGS) do
        local name = baseAttrs.name
        if not FrankenBags._nameToBagAttrs[name] then
            addSourceBag(name, baseAttrs, {})
        end
    end

    -- Move or create bags.
    local numAutoPlacementBags = 0
    for _, bagAttrs in pairs(FrankenBags._nameToBagAttrs) do
        if not bagAttrs.pos then
            numAutoPlacementBags = numAutoPlacementBags + 1
        end
    end
    local i = 0
    for _, baseAttrs in ipairs(FrankenBags.SOURCE_BAGS) do
        local name = baseAttrs.name
        local bagAttrs = assert(FrankenBags._nameToBagAttrs[name])
        i = i + 1
        local radius = FrankenBags.DRAFT_SRC_RADIUS
        local phi = i * math.pi * 2 / numAutoPlacementBags
        local pos = {
            x = (bagAttrs.pos and bagAttrs.pos.x) or math.sin(phi) * radius,
            y = _zoneHelper.getTableY() + 3,
            z = (bagAttrs.pos and bagAttrs.pos.z) or math.cos(phi) * radius
        }
        local rot = {
            x = 0,
            y = 0,
            z = 0
        }
        local bag = false
        assert(bagAttrs.src)
        if bagAttrs.src.object then
            log.d('moving existing "' .. name .. '"')
            bag = bagAttrs.src.object
            bag.setLock(false)
            local collide = false
            local fast = false
            bag.setPositionSmooth(pos, collide, fast)
            bag.setRotationSmooth(rot, collide, fast)
        elseif bagAttrs.src.container then
            log.d('unpacking "' .. name .. '" from self')
            bag = bagAttrs.src.container.takeObject({
                position          = pos,
                rotation          = rot,
                smooth            = false,
                guid              = assert(bagAttrs.src.guid),
            })
        else
            log.d('creating "' .. name .. '"')
            bag = spawnObject({
                type              = 'Bag',
                position          = pos,
                rotation          = rot,
                sound             = false,
                snap_to_grid      = false,
            })
            bag.use_grid = false
            bag.use_snap_points = false
            bag.setName(name)
            bag.setColorTint(bagAttrs.color or 'Yellow')
        end
        assert(bag)
        bagAttrs.bag = bag
        coroutine.yield(0)
    end
end

--- Return any moved draft source bags to their original location.  Pack any
-- created bags into self (in case players want to inspect, make adjustments).
function FrankenBags.stowDraftSourceBags()
    assert(FrankenBags._nameToBagAttrs, 'FrankenBags.stowDraftSourceBags: not created')

    for name, attrs in pairs(FrankenBags._nameToBagAttrs) do
        local bag = assert(attrs.bag, 'missing bag "' .. name .. '"')
        bag.setLock(false)
        assert(attrs.src, 'missing src')
        if attrs.src.object then
            local collide = false
            local fast = false
            bag.setPositionSmooth(attrs.src.position, collide, fast)
            bag.setRotationSmooth(attrs.src.rotation, collide, fast)
            Wait.time(function() bag.setLock(attrs.src.locked) end, 10)
        elseif attrs.src.container then
            attrs.src.container.putObject(bag)
        elseif not attrs.persist then
            -- We spawned this bag.  Do not destroy, stow in self for player inspection.
            self.putObject(bag)
        end
    end
    FrankenBags._nameToBagAttrs = false
end

function FrankenBags.getDraftCandidates()
    local frankenNameSet = {}
    local flagshipSet = {}
    local abilitySet = {}
    local unitSet = {}

    local function processFactionsBox(factionsBox)
        for _, entry in ipairs(factionsBox.getObjects()) do
            local name = string.match(entry.name, '^(.*) Box$')
            local faction = name and _factionHelper.fromTokenName(name)
            if faction then
                frankenNameSet[faction.frankenName or '-'] = true
                frankenNameSet[faction.tokenName or '-'] = true
                frankenNameSet[faction.name or '-'] = true
                flagshipSet[faction.flagship or '-'] = true
                for _, ability in ipairs(faction.abilities or {}) do
                    abilitySet[ability] = true
                end
                for _, unit in ipairs(faction.units) do
                    unitSet[unit] = true
                end
            end
        end
    end

    for _, object in ipairs(getAllObjects()) do
        if object.tag == 'Bag' then
            local name = object.getName()
            if name == 'Factions' then
                processFactionsBox(object)
            elseif string.match(name, ' Faction Pack$') then
                processFactionsBox(object)
            end
        end
    end
    coroutine.yield(0)

    -- There is no list of "base" units, so build the set of faction units
    -- not included above.
    local excludeUnitSet = {}
    for _, faction in pairs(_factionHelper.allFactions(true)) do
        for _, unit in ipairs(faction.units or {}) do
            if not unitSet[unit] then
                excludeUnitSet[unit] = true
            end
        end
    end

    -- Faction Helper has an updated "Jol-Nar" name, but if using with an
    -- old Faction Helper it might still be using "Jol Nar".  In that case,
    -- add the new (used by these objects) version.  Old faction helper will
    -- recognize both, it just advertises the old style.
    -- Also a typo fix for Kjalengard (DS) to avoid needing to wait for update
    if frankenNameSet['Jol Nar'] then
        frankenNameSet['Jol-Nar'] = true
    end

    return {
        frankenNameSet = frankenNameSet,
        flagshipSet = flagshipSet,
        abilitySet = abilitySet,
        excludeUnitSet = excludeUnitSet,
    }
end

function FrankenBags.fillSourceBagsFromSelf()
    local candidates = FrankenBags.getDraftCandidates()
    coroutine.yield(0)

    for _, entry in ipairs(self.getObjects()) do
        local object = self.takeObject({
            position          = self.getPosition() + vector(0, 5, 0),
            smooth            = false,
            guid              = entry.guid
        })
        coroutine.yield(0)
        local name = object.getName()

        local dstNameToAboveSlot = {}
        local function moveTileToDst(name, guid, dstName)
            if _config.Replace_components and replaceThis(name) then
                dstName = 'Replaced Parts'
                -- Also make sure the replacing component shall move
                moveReplacingComponent(name, dstName)
            elseif isUndraftable(name) then
                dstName = 'Non Draft Parts'          
            elseif isRemoveThis(name) then
                dstName = 'Removed Parts'
            end
            local dstAttrs = FrankenBags._nameToBagAttrs[dstName]
            assert(dstAttrs, 'unknown bag "' .. dstName .. '"')
            local dst = dstAttrs.bag
            assert(dst, 'missing bag "' .. dstName .. '"')
            local i = dstNameToAboveSlot[dstName] or 0
            dstNameToAboveSlot[dstName] = i + 1
            object.takeObject({
                position          = object.getPosition() + vector(0, 5 + i * 0.2, 0),
                callback_function = function(object) dst.putObject(object) end,
                smooth            = false,
                guid              = guid
            })
        end

        if object.tag == 'Bag' then
            object.setLock(true)

            -- Does this bag has "$FACTION Starting Tech" style names?
            local isFrankenName = false
            isFrankenName = isFrankenName or string.match(name, '^Starting Units')
            isFrankenName = isFrankenName or string.match(name, '^Starting Tech')
            isFrankenName = isFrankenName or string.match(name, '^Commodity Tiles')
            if isFrankenName then
                for _, entry in ipairs(object.getObjects()) do
                    local frankenName = false
                    frankenName = frankenName or string.match(entry.name, '^(.*) Starting Units$')
                    frankenName = frankenName or string.match(entry.name, '^(.*) Fleet$')
                    frankenName = frankenName or string.match(entry.name, '^(.*) Starting Tech$')
                    frankenName = frankenName or string.match(entry.name, '^(.*) Commodities$')
                    if candidates.frankenNameSet[frankenName] then
                        local dstName = assert(string.match(name, '^(.*) %(.*%)$'))
                        moveTileToDst(entry.name, entry.guid, dstName)
                    end
                end
            end

            if string.match(name, '^Flagships') then
                for _, entry in ipairs(object.getObjects()) do
                    if candidates.flagshipSet[entry.name] then
                        moveTileToDst(entry.name, entry.guid, 'Flagships')
                    end
                end
            end

            if string.match(name, '^Faction Abilities') then
                for _, entry in ipairs(object.getObjects()) do
                    if candidates.abilitySet[entry.name] then
                        moveTileToDst(entry.name, entry.guid, 'Faction Abilities')
                    end
                end
            end

            if string.match(name, '^Base Unit Tiles') then
                for _, entry in ipairs(object.getObjects()) do
                    if not candidates.excludeUnitSet[entry.name] then
                        moveTileToDst(entry.name, entry.guid, 'Base Unit Tiles')
                    end
                end
            end

            if string.match(name, 'speaker order choice') and _config.Speaker_order_draft then
                for _, entry in ipairs(object.getObjects()) do
                    moveTileToDst(entry.name, entry.guid, 'speaker order choice')
                end
            end

            coroutine.yield(0)

            object.setLock(false)
            self.putObject(object)
            coroutine.yield(0)
        end
    end
end

function FrankenBags.fillSourceBagsFromCustomBag()
    -- Find Custom bag
    local custom_bag = nil

    for _, object in ipairs(getAllObjects()) do
        if object.name == 'Custom Franken Expansion' then
            custom_bag = object
            break
        end
    end
    coroutine.yield(0)

    if not custom_bag then
        for _, object in ipairs(self.getObjects()) do 
            if object.name == 'Custom Franken Expansion' then
                custom_bag = self.takeObject({
                    position          = self.getPosition() + vector(0, 5, 0),
                    smooth            = false,
                    guid              = entry.guid
                })
                break
            end
        end
    end
    coroutine.yield(0)

    custom_bag.setPositionSmooth({ x = -5, y = _zoneHelper.getTableY() + 3, z = 0 }, false, true)

    -- Move all of the contents to the source bags
    for _, object in ipairs(custom_bag.getObjects()) do
        local dstBag = FrankenBags._nameToBagAttrs[object.name]
        if dstBag then
            local bag = custom_bag.takeObject({
                position = custom_bag.getPosition() + vector(0, 5, 0),
                smooth = false, 
                guid = object.guid
            })
            local items = takeAll(bag)
            for _, item in ipairs(items) do
                dstBag.putObject(item)
            end
            custom_bag.putObject(bag)
        end
    end
    coroutine.yield(0)
end

function FrankenBags.fillSourceBagsFromFactionBoxes(factionsBox)
    -- If no factions box is given, run again with the default, plus any
    -- "X Faction Pack" bags on the table.
    if not factionsBox then
        local factionsBoxes = {}
        for _, object in ipairs(getAllObjects()) do
            if object.tag == 'Bag' then
                local name = object.getName()
                if name == 'Factions' then
                    table.insert(factionsBoxes, object)
                elseif string.match(name, ' Faction Pack$') then
                    table.insert(factionsBoxes, object)
                end
            end
        end
        coroutine.yield(0)
        assert(#factionsBoxes > 0)
        for _, factionsBox in ipairs(factionsBoxes) do
            FrankenBags.fillSourceBagsFromFactionBoxes(factionsBox)
            coroutine.yield(0)
        end
        return
    end

    -- No need to check if a faction belongs.  If it is in the factions box,
    -- that is signal enough.  (E.g. no PoK factions will be there for base.)
    for _, entry in ipairs(factionsBox.getObjects()) do
        local name = string.match(entry.name, '^(.*) Box$')
        local faction = name and _factionHelper.fromTokenName(name)
        if faction then
            local factionBox = factionsBox.takeObject({
                position          = factionsBox.getPosition() + vector(0, 5, 0),
                smooth            = false,
                guid              = entry.guid
            })
            coroutine.yield(0)
            factionBox.setLock(true)
            FrankenBags._fillSourceBagsFromFactionBox(faction, factionBox)
            factionBox.setLock(false)
            factionsBox.putObject(factionBox)
            coroutine.yield(0)
        end
    end
end

local function takeAll(bag)
    local objects = {}
    for i, entry in ipairs(bag.getObjects()) do
        local object = bag.takeObject({
            position          = bag.getPosition() + vector(0, 5 + i * 3, 0),
            smooth            = false,
            guid              = entry.guid
        })
        table.insert(objects, object)
    end
    return objects
end

-- keleres box should only be unpacked once except their hero
local keleres_done = false

function FrankenBags._fillSourceBagsFromFactionBox(faction, factionBox)
    local function takeBag(pattern, bagIndex)
        for i, entry in ipairs(factionBox.getObjects()) do
            if string.match(entry.name, pattern) then
                local bag = factionBox.takeObject({
                    position          = factionBox.getPosition() + vector(i * 3, 5, bagIndex * 3),
                    smooth            = false,
                    --guid              = entry.guid
                    index             = entry.index -- Boo, blue space has guid collisions
                })
                bag.setLock(true)
                return bag
            end
        end
    end

    local function destroyBag(bag)
        bag.setLock(false)
        _safeDelete(bag)
    end

    -- Try to do a lot in parallel between yields for faster action.
    local bagHandlers = {
        {
            bagNamePattern = 'Promissory Bag$',
            defaultDstBagName = 'Promissory Notes',
        },
        {
            bagNamePattern = 'Tech Bag$',
            defaultDstBagName = 'Faction Techs',
        },
        {
            bagNamePattern = 'Planets Bag$',
            planetCards = true,
            discard = true,
        },
        {
            bagNamePattern = 'Leaders Bag$',
            defaultDstBagName = 'Agents',
            overrideDstBagName = function(object)
                local name = object.getName()
                local overrides = _unitHelper.getUnitOverrides()
                local override = overrides[name]
                if HACK_OVERRIDE_LEADER_DST[name] then
                    local dst = HACK_OVERRIDE_LEADER_DST[name]
                    object.setDescription(dst)
                    return dst
                elseif override and override.override == 'Mech' then
                    return 'Mechs'
                elseif name == faction.commander then
                    object.setDescription('Commander')
                    return 'Commanders'
                elseif name == faction.hero then
                    object.setDescription('Hero')
                    return 'Heroes'
                else
                    object.setDescription('Agent')
                    return 'Agents'
                end
            end,
        },
        {
            bagNamePattern = 'Extras Bag$',
            defaultDstBagName = 'Non Draft Parts',
        },
    }

    -- Take all bags at once.
    for i, bagHandler in ipairs(bagHandlers) do
        bagHandler.bag = takeBag(bagHandler.bagNamePattern, i)
    end
    coroutine.yield(0)

    -- Take all sub-objects at once.
    for _, bagHandler in ipairs(bagHandlers) do
        if bagHandler.bag then
            bagHandler.objects = takeAll(bagHandler.bag)
        end
    end
    coroutine.yield(0)

    -- Homebrew might not have registered planet cards, do so now.
    for _, bagHandler in ipairs(bagHandlers) do
        if bagHandler.planetCards and bagHandler.objects then
            for _, object in ipairs(bagHandler.objects) do
                local cardName = object.getName()
                if not _deckHelper.getDeckName(cardName) then
                    _deckHelper.injectCard({
                        cardName = cardName,
                        deckName = 'Planets'
                    })
                end
            end
        end
    end
    coroutine.yield(0)

    local skip = false
    -- test for keleres
    if string.match(faction.name, '^The Council Keleres') and keleres_done then
        skip = true
    end
    coroutine.yield(0)

    -- Transfer all sub-objects at once.
    for _, bagHandler in ipairs(bagHandlers) do
        for i, object in ipairs(bagHandler.objects or {}) do
            local name = object.getName()
            if bagHandler.discard then
                local success = _deckHelper.discardCard({
                    guid = object.getGUID(),
                    name = name,
                    index = i
                })
                assert(success, 'error discarding "' .. name .. '"')
            else
                local dstName = bagHandler.defaultDstBagName
                if bagHandler.overrideDstBagName then
                    dstName = bagHandler.overrideDstBagName(object) or dstName
                end

                if _config.Replace_components and replaceThis(name) then
                    dstName = 'Replaced Parts'
                    -- Also make sure the replacing component shall move
                    moveReplacingComponent(name, dstName)
                elseif isUndraftable(name, dstName) then
                    dstName = 'Non Draft Parts'          
                elseif isRemoveThis(name) or (skip and not ((dstName == 'Heroes'))) then
                    dstName = 'Removed Parts'
                end

                local dstAttrs = FrankenBags._nameToBagAttrs[dstName]
                assert(dstAttrs, 'unknown bag "' .. dstName .. '"')
                local dst = dstAttrs.bag
                assert(dst, 'missing bag "' .. dstName .. '"')
                dst.putObject(object)
            end
        end
    end
    coroutine.yield(0)

    -- Wait a beat, make sure moving things have time to move.
    for _ = 1, 10 do
        coroutine.yield(0)
    end

    -- Destroy all handled bags at once.
    for _, bagHandler in ipairs(bagHandlers) do
        if bagHandler.bag then
            destroyBag(bagHandler.bag)
        end
    end
    coroutine.yield(0)

    -- Move home system tile, and any other undraftable items.
    for _, entry in ipairs(factionBox.getObjects()) do
        if isUndraftable(entry.name) and (not skip) then
            local object = factionBox.takeObject({
                smooth            = false,
                guid              = entry.guid,
            })
            FrankenBags._nameToBagAttrs['Non Draft Parts'].bag.putObject(object)
        elseif isRemoveThis(entry.name) or skip then
            local object = factionBox.takeObject({
                smooth            = false,
                guid              = entry.guid,
            })
            FrankenBags._nameToBagAttrs['Removed Parts'].bag.putObject(object)
        elseif entry.name == faction.tokenName .. ' Tile' then
            local homeSystem = factionBox.takeObject({
                smooth            = false,
                guid              = entry.guid,
            })
            FrankenBags._nameToBagAttrs['Home Systems'].bag.putObject(homeSystem)
        end
    end
    coroutine.yield(0)

    if string.match(faction.name, 'The Council Keleres') then
        keleres_done = true
    end
end

function FrankenBags.createDraftBags()
    assert(not FrankenBags._colorToDraftBag, 'FrankenBags.createDraftBags: already created')

    FrankenBags._colorToDraftBag = {}
    local numZones = #_zoneHelper.zones()
    for i, zoneAttributes in ipairs(_zoneHelper.zonesAttributes()) do
        assert(zoneAttributes.color)
        local p = zoneAttributes.center
        local magnitude = math.sqrt(p.x ^ 2 + p.z ^2)
        local normalized = { x = p.x / magnitude, y = p.y, z = p.z / magnitude }
        p = {
            x = normalized.x * FrankenBags.DRAFT_DST_RADIUS,
            y = _zoneHelper.getTableY() + 3,
            z = normalized.z * FrankenBags.DRAFT_DST_RADIUS
        }
        local bag = spawnObject({
            type              = 'Bag',
            position          = p,
            sound             = false,
            snap_to_grid      = false,
        })
        bag.use_grid = true
        bag.use_snap_points = false
        bag.setColorTint(zoneAttributes.color or 'White')
        bag.setName('Franken Draft Bag ' .. i .. '/' .. numZones)
        FrankenBags._colorToDraftBag[zoneAttributes.color] = bag
    end
end

function FrankenBags.createExtraDraftBag()
    local p = {
        x = 0,
        y = _zoneHelper.getTableY() + 3,
        z = 0
    }
    local bag = spawnObject({
        type              = 'Bag',
        position          = p,
        sound             = false,
        snap_to_grid      = false,
    })
    bag.use_grid = true
    bag.use_snap_points = false
    bag.setColorTint('Teal')
    bag.setName('EXTRA Franken Draft Bag')
    FrankenBags._colorToDraftBag['EXTRA'] = bag
end

function FrankenBags.stowDraftBags()
    assert(FrankenBags._colorToDraftBag, 'FrankenBags.stowDraftBags: dst bags not created')

    for color, bag in pairs(FrankenBags._colorToDraftBag) do
        self.putObject(bag)
        coroutine.yield(0)
    end
    FrankenBags._colorToDraftBag = false
end

--- Make sure there are enough items in source bags.
function FrankenBags.validateSourceBagsQuantities()
    assert(FrankenBags._nameToBagAttrs, 'FrankenBags.validateSourceBagsQuantities: src bags not created')

    local errors = false
    local numPlayers = #_zoneHelper.zones()
    for srcBagName, bagAttrs in pairs(FrankenBags._nameToBagAttrs) do
        local srcBag = assert(bagAttrs.bag)
        local count = bagAttrs.count
        if count and type(count) == 'table' then
            count = count[numPlayers]
        end

        if bagAttrs.pok and not _setupHelper.getPoK() then
            count = false
        end

        if count then
            local have = srcBag.getQuantity()
            local need = count * numPlayers
            if have < need then
                errors = errors or {}
                table.insert(errors, srcBagName .. ' has ' .. have .. ' needs ' .. need )
            end
        end
    end

    if errors then
        local message = 'FrankbenBags.validateSourceBagsQuantities: ' .. table.concat(errors, ', ')
        printToAll(message, 'Red')
        return false
    end

    return true
end

function FrankenBags.fillDraftBags()
    assert(FrankenBags._nameToBagAttrs, 'FrankenBags.fillDraftBags: src bags not created')
    assert(FrankenBags._colorToDraftBag, 'FrankenBags.fillDraftBags: dst bags not created')
    local log = _getLog('FrankenBags.fillDraftBags')

    local numPlayers = #_zoneHelper.zones()
    for _, baseAttrs in ipairs(FrankenBags.SOURCE_BAGS) do
        local srcBagName = assert(baseAttrs.name)
        local bagAttrs = assert(FrankenBags._nameToBagAttrs[srcBagName])
        local srcBag = assert(bagAttrs.bag)

        local count = bagAttrs.count
        if count and type(count) == 'table' then
            count = count[numPlayers]
        end

        -- adapt count for setting
        if srcBagName == 'Blue Planet Tiles' and (_config.Blue_count != 0) then
            count = _config.Blue_count
        end
        if srcBagName == 'Faction Abilities' and _config.Powered_draft then
            count = count + 1
        end
        if srcBagName == 'Faction Techs' and _config.Powered_draft then
            count = count + 1
        end
        if bagAttrs.pok and not _setupHelper.getPoK() then
            count = false
        end

        if count and count > 0 then
            log.i('adding ' .. count .. ' ' .. srcBagName)
            srcBag.shuffle()
            coroutine.yield(0)
            assert(srcBag.getQuantity() >= count * numPlayers, 'too few ' .. srcBagName)
            for _, dstBag in pairs(FrankenBags._colorToDraftBag) do
                for i = 1, count do
                    local object = srcBag.takeObject({
                        position          = dstBag.getPosition() + vector(0, 5 + i * 0.1, 0),
                        smooth            = false,
                        top               = true,
                    })
                    coroutine.yield(0)
                    dstBag.putObject(object)
                    coroutine.yield(0)
                end
            end
        end
    end
end

function FrankenBags.DoCodex3()
    local codex3 = {}

    for _, object in ipairs(getAllObjects()) do
        if object.tag == 'Bag' then
            local name = object.getName()
            if name == 'Codex 3: Vigil' then
                codex3 = object
            end  
        end

    end
    coroutine.yield(0)

    for i, entry in ipairs(codex3.getObjects()) do
        -- check if object is codex 3 leader
        local dstName = nil
        if HACK_OVERRIDE_LEADER_DST[entry.name] then
            dstName = HACK_OVERRIDE_LEADER_DST[entry.name]
        end 

        if dstName then
            local object = codex3.takeObject({
                position          = codex3.getPosition() + vector(0, 5 + i * 3, 0),
                smooth            = false,
                guid              = entry.guid
            })
            object.setDescription(dstName)

            if isUndraftable(entry.name) then
                dstName = 'Non Draft Parts'
            elseif isRemoveThis(entry.name) then
                dstName = 'Removed Parts'
            end

            local dstAttrs = FrankenBags._nameToBagAttrs[dstName]
            assert(dstAttrs, 'unknown bag "' .. dstName .. '"')
            local dst = dstAttrs.bag
            assert(dst, 'missing bag "' .. dstName .. '"')
            dst.putObject(object)
        end        
        
    end
    coroutine.yield(0)

end

-------------------------------------------------------------------------------
-- Index is only called when the key does not already exist.
local _lockGlobalsMetaTable = {}
function _lockGlobalsMetaTable.__index(table, key)
    error('Accessing missing global "' .. tostring(key or '<nil>') .. '", typo?', 2)
end
function _lockGlobalsMetaTable.__newindex(table, key, value)
    error('Globals are locked, cannot create global variable "' .. tostring(key or '<nil>') .. '"', 2)
end
setmetatable(_G, _lockGlobalsMetaTable)