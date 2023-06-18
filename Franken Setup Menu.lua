-- @author Darrell for UI generation scripting
-- @author Leary for Franken Setup (Enhancement to Franken Box)

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

local _frankenBox = getHelperClient('Franken Box')
local _zoneHelper = getHelperClient('TI4_ZONE_HELPER')
-------

function onLoad(saveState)
    _config = DEFAULT_CONFIG
    if saveState and string.len(saveState) > 0 then
        _config = JSON.decode(saveState) or _config
    end

    Wait.frames(_createUI, 2)
    scheduleUpdateUiFromConfig(4)

    self.setDescription([[
        Use this tool to pre-curate most of the Franken setup. 
        Click 'Gather Draft Items' only if the Franken Box is out on the table.

        Extra Blue Tile: Adds 1 Extra blue tile to the draft bags. Players discard 1 blue tile before building their slice.

        Draft Speaker Order: Adds the numbers 1-6 to the draft. Players can only draft 1 of these. If not playing 6 players, make sure to remove the other numbers before Building bags. 

        Powered: This adds 1 extra faction tech and ability to each players' draft bags. Players may keep 3 faction techs and 4 faction abilities, instead of 2/3.

        Ban negatives: This removes negative abilities, like Fragile or Mitosis.

        Ban low-value: This removes components with low to near-0 value, like Sardakk Starting Tech or Shield Paling.

        Replace Components: This will look for a bag named 'Replacing Components' to add alternative versions of components to the draft. Make sure there is only 1 such bag, and that each component to replace is named exactly as the original.

        Include custom Franken pack: This is a custom add-on with loose components that did not fit in any DS factions but can be used for Franken Draft.

        **Pillage is auto-removed (you may put it back in from the 'Removed' bag)
    ]])

    local pos = {
        x = 40,
        y = _zoneHelper.getTableY() + 3,
        z = 0
    }
    self.setPositionSmooth(pos, false, false)

    self.addContextMenuItem('Toggle Ban input', toggleCustomBans)
end

function onSave()
    return JSON.encode(_config)
end

function onPlayerConnect(playerId)
    -- UI does not seem to appear for new players, recreating it fixes.
    Wait.frames(_createUI, 2)
    scheduleUpdateUiFromConfig(4)
end

function _createUI()
    local scale = self.getScale()
    local uiScale = (4 / scale.x) .. ' ' .. (4 / scale.z) .. ' ' .. (1 / scale.y)

    local function text(class, text)
        return {
            tag = 'Text',
            attributes = {
                class = class
            },
            value = text
        }
    end

    local function toggle(id, text, isOn, tooltip)
        return {
            tag = 'Toggle',
            attributes = {
                id = id,
                isOn = isOn or nil
            },
            value = text,
            tooltip = tooltip
        }
    end
    local function toggleGroup(idPrefix, values)
        local height = math.ceil(#values / 4) * 50
        local toggles = {}
        for _, value in ipairs(values) do
            table.insert(toggles, {
                tag = 'ToggleButton',
                attributes = {
                    id = idPrefix .. string.gsub(tostring(value), ' ', '_'),
                },
                value = value
            })
        end
        return {
            tag = 'ToggleGroup',
            attributes = {
                preferredHeight = height,
            },
            children = {
                {
                    tag = 'GridLayout',
                    children = toggles
                }
            }
        }
    end

    local function slider(label, id, minValue, maxValue)
        assert(type(id) == 'string' and type(minValue) == 'number' and type(maxValue) == 'number')
        assert(maxValue > minValue)

        local height = 20
        return {
            tag = 'HorizontalLayout',
            attributes = {
                childForceExpandWidth = true,
                childForceExpandHeight = false,
            },
            children = {
                {
                    tag = 'Text',
                    attributes = {
                        fontSize = 16,
                        color = 'White',
                        alignment = 'MiddleRight',
                        minWidth = 110,
                        minHeight = height,
                    },
                    value = label
                },
                {
                    tag = 'Slider',
                    attributes = {
                        id = id,
                        minValue = minValue,
                        maxValue = maxValue,
                        wholeNumbers = true,
                        onValueChanged = 'onSliderValueChanged',
                        minWidth = 100,
                        minHeight = height,
                        rectAlignment = 'MiddleCenter'
                    },
                    value = minValue,
                },
                {
                    tag = 'Text',
                    attributes = {
                        id = id .. 'Value',
                        fontSize = 16,
                        color = 'White',
                        alignment = 'MiddleLeft',
                        horizontalOverflow = 'Overflow',
                        verticalOverflow = 'Overflow',
                        minWidth = 20,
                        minHeight = height,
                    },
                    value = minValue,
                },

            }
        }
    end

    local function spacer()
        return { tag = 'Text', attributes = { fontSize = 8 }}
    end

    local defaultColorBlock = '#FFFFFF|#1F45FC|#38ACEC|rgba(0.78,0.78,0.78,0.5)'
    local defaults = {
        tag = 'Defaults',
        children = {
            {
                tag = 'VerticalLayout',
                attributes = {
                    spacing = 10,
                    childForceExpandHeight = false,
                }
            },
            {
                tag = 'HorizontalLayout',
                attributes = {
                    spacing = 10,
                }
            },
            {
                tag = 'GridLayout',
                attributes = {
                    spacing = '10 10',
                    cellSize = '62 40', -- 86 40 for three columns
                },
            },
            {
                tag = 'ToggleGroup',
                attributes = {
                    toggleBackgroundColor = '#FF0000',
                    toggleSelectedColor = '#38ACEC',
                }
            },
            {
                tag = 'Toggle',
                attributes = {
                    fontSize = 14,
                    textColor = 'White',
                    horizontalOverflow = 'Wrap',
                    onValueChanged = 'onToggleValueChanged',
                }
            },
            {
                tag = 'ToggleButton',
                attributes = {
                    fontSize = 14,
                    onValueChanged = 'onToggleValueChanged',
                    colors = defaultColorBlock
                }
                -- ToggleGroup.toggleSelectedColor does not seem to apply to ToggleButton?
            },
            {
                tag = 'Button',
                attributes = {
                    onClick = 'onButtonClick'
                }
            },
            {
                tag = 'Text',
                attributes = {
                    class = 'title',
                    fontSize = 20,
                    fontStyle = 'Bold',
                    color = 'White',
                    alignment = 'MiddleCenter',
                }
            },
            {
                tag = 'Text',
                attributes = {
                    class = 'heading',
                    fontSize = 14,
                    color = 'White',
                    alignment = 'MiddleCenter'
                }
            },
        }
    }
    local top = {
        tag = 'Panel',
        attributes = {
            position = '0 0 2',
            rotation = '0 180 0',
            width = 300,
            height = 500,
            scale = uiScale,
        },
        children = {
            {
                tag = 'VerticalLayout',
                attributes = {
                    padding = '10 10 18 70',
                },
                children = {
                    text('title', 'Franken Setup Options'),

                    spacer(),

                    slider('Amount of blue tiles', 'Blue_count', 2, 8),

                    toggle('Speaker_order_draft','Draft Speaker Order', ''),
                    toggle('Powered_draft','Powered (+1 faction tech & ability)', ''),
                    toggle('Ban_negatives','Remove negative abilities', ''),
                    toggle('Ban_bad','Remove low value components', ''),
                    toggle('Include_Custom_Bans', 'Include custom bans', 'Toggle the input for this in the context menu (right click this menu).'),
                    toggle('Replace_components','Replace components', ''),
                    toggle('Include_Franken_Pack', 'Include custom Franken pack', '')
                }
            },
            {
                tag = 'Panel',
                attributes = {
                    height = 210,
                    padding = '10 10 10 150',
                    rectAlignment = 'LowerCenter',
                },
                children = {
                    {
                        tag = 'Button',
                        attributes = {
                            id = 'gatherDraft',
                            fontSize = 24,
                        },
                        value = '1. Gather Draft Items'
                    },
                }
            },
            {
                tag = 'Panel',
                attributes = {
                    height = 140,
                    padding = '10 10 10 80',
                    rectAlignment = 'LowerCenter',
                },
                children = {
                    {
                        tag = 'Button',
                        attributes = {
                            id = 'buildDraft',
                            fontSize = 24,
                        },
                        value = '2. Build Draft Bags'
                    },
                }
            },
            {
                tag = 'Panel',
                attributes = {
                    height = 70,
                    padding = '10 10 10 10',
                    rectAlignment = 'LowerCenter',
                },
                children = {
                    {
                        tag = 'Button',
                        attributes = {
                            id = 'finishDraft',
                            fontSize = 24,
                        },
                        value = '3. Remove Draft Bags'
                    },
                }
            },
        }
    }
    local bottom = {
        tag = 'Panel',
        attributes = {
            position = '0 0 -22',
            rotation = '0 0 0',
            width = 300,
            height = 500,
            padding = '20 20 20 20',
            scale = uiScale,
            color = '#000000e0'
        },
        children = {
        }
    }

    self.UI.setXmlTable({ defaults, top, bottom })
end

function updateUiFromConfig()
    self.UI.setAttribute('Blue_count','value', _config.Blue_count)
    self.UI.setValue('Blue_countValue', _config.Blue_count)
    self.UI.setAttribute('Speaker_order_draft', 'isOn', _config.Speaker_order_draft)
    self.UI.setAttribute('Powered_draft', 'isOn', _config.Powered_draft)
    self.UI.setAttribute('Ban_negatives', 'isOn', _config.Ban_negatives)
    self.UI.setAttribute('Ban_bad', 'isOn', _config.Ban_bad)
    self.UI.setAttribute('Replace_components', 'isOn', _config.Replace_components)
    self.UI.setAttribute('Include_Franken_Pack', 'isOn', _config.Include_Franken_Pack)
    self.UI.setAttribute('Include_Custom_Bans', 'isOn', _config.Include_Custom_Bans)
end

function scheduleUpdateUiFromConfig(delayFrameCount)
    if _updateUiFromConfigWaitId then
        Wait.stop(_updateUiFromConfigWaitId)
        _updateUiFromConfigWaitId = false
    end
    _updateUiFromConfigWaitId = Wait.frames(updateUiFromConfig, delayFrameCount or 2)
end

--------

local customBanInput = nil

function _onCustomBan() 
end

function isCustomBansVisible()
    return getInputIndex() and true or false
end

function getInputIndex()
    for _, input in ipairs(self.getInputs() or {}) do
        if input.input_function == '_onCustomBan' then
            return input.index
        end
    end
end

function toggleCustomBans()
    if isCustomBansVisible() then
        printToAll("Hiding bans")
        hideCustomBans()
    else
        printToAll("Showing bans")
        showCustomBans()
    end
end

function showCustomBans()
    assert(not isCustomBansVisible())
    local hint = 'Enter bans as "# ; # ; # ..." seperating the component names with semicolons."'
        self.createInput({
            input_function = '_onCustomBan',
            function_owner = self,
            label          = hint,
            alignment      = 2, -- left
            position       = { x = 0, y = 0, z = 0 },
            rotation       = { x = 0, y = 180, z = 180 },
            scale          = { x = 1, y = 1, z = 1 },
            width          = 5500,
            height         = 9000,
            font_size      = 300,
            tooltip        = hint,
            value          = customBanInput, -- Show label as "hint"
        })
end

function hideCustomBans()
    assert(isCustomBansVisible())
    local index = assert(getInputIndex())
    local input = assert(self.getInputs()[index + 1]) -- index is 0 based, lua is 1
    local value = assert(input.value)
    customBanInput = value
    self.removeInput(index)
end

function setCustomBans()
    local COMPONENTS_TO_BAN_CUSTOM = {

    }

    for component in string.gmatch(customBanInput, "([^%s;%s]+)") do
        COMPONENTS_TO_BAN_CUSTOM[component] = {}
    end

    _frankenBox.setCustomBans(COMPONENTS_TO_BAN_CUSTOM)
end
--------
local RIGHT_CLICK = '-2'

function onButtonClick(player, inputType, id)
    local isRightClick = inputType == RIGHT_CLICK and true or false
    if id == 'gatherDraft' then
        self.setLock(false)
        gatherDraft(isRightClick)
    elseif id == 'buildDraft' then
        self.setLock(false)
        buildDraft(isRightClick)
    elseif id == 'finishDraft' then
        self.setLock(false)
        finishDraft(isRightClick)    
    else
        error('onButtonClick: unknown button "' .. id .. '"')
    end
end

function onToggleValueChanged(player, value, id)
    local valueAsBool = string.lower(value) == 'true' and true or false
    assert(type(valueAsBool) == 'boolean')

    if id == 'Speaker_order_draft' then
        _config.Speaker_order_draft = valueAsBool
    elseif id == 'Powered_draft' then
        _config.Powered_draft = valueAsBool
    elseif id == 'Ban_negatives' then
        _config.Ban_negatives = valueAsBool
    elseif id == 'Ban_bad' then
        _config.Ban_bad = valueAsBool
    elseif id == 'Include_Custom_Bans' then
        _config.Include_Custom_Bans = valueAsBool
    elseif id == 'Replace_components' then
        _config.Replace_components = valueAsBool
    elseif id == 'Include_Franken_Pack' then
        _config.Include_Franken_Pack = valueAsBool

    else
        error('onToggleValueChanged: unknown toggle "' .. id .. '"')
    end
    scheduleUpdateUiFromConfig()
end

function onSliderValueChanged(player, value, id)
    value = tonumber(value)
    if id == 'Blue_count' then
        _config.Blue_count = value
    end
    scheduleUpdateUiFromConfig()
end

------

function gatherDraft()
    local pos = {
        x = 40,
        y = _zoneHelper.getTableY() + 3,
        z = 0
    }
    self.setPositionSmooth(pos, false, false)

    _frankenBox._setConfig(_config)
    
    if _config.Include_Custom_Bans then
        setCustomBans()
    end

    _frankenBox.gatherDraftStart()
end

function buildDraft()
    local pos = {
        x = 40,
        y = _zoneHelper.getTableY() + 3,
        z = 0
    }
    self.setPositionSmooth(pos, false, false)

    _frankenBox.buildDraftStart()
end

function finishDraft()
    _frankenBox.finishDraftStart()

    function _getObj(name)
        for _, object in ipairs(getAllObjects()) do
            if object.getName() == name then
                return object
            end
        end
    end

    local _franken_obj =  _getObj('Franken Box')

    _franken_obj.putObject(self)
end