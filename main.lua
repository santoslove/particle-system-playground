--[[

buttonSettings = {
    {
        name = 'LinearDamping'
        clickable = false,
        minmax = true,
        change = 0.1,
        limits = {lower = 0, upper = 1},
    },
}

actualButtons = {
    {
        name = buttonSetting.name,
        buttons = {
            {
                value = value,
                disabled = boolean,
                action = function, -- when clicked
                x = number,
                y = number,
                width = number,
                height = number,
                textX = number,
            }
        }
    }
}

hovering = {
    name = actualButton.name,
    index = buttonIndex,
    button = button,
}

dragging = {
    name = actualButton.name,
    index = buttonIndex,
    initialX = x,
    initialY = y,
    value = 0,
    initial = button.value,
}

]]--


function love.load()
    images = {}

    for imageNameIndex, imageName in ipairs({
        'square.png',
        'ball.png',
        'arrow.png',
    }) do
        table.insert(images, {
            name = imageName,
            image = love.graphics.newImage(imageName),
        })
    end

    imageIndex = 1

    ps = love.graphics.newParticleSystem(images[imageIndex].image)
    ps:setEmissionRate(5)
    ps:setParticleLifetime(2)
    ps:setSpeed(50)
    ps:setColors({1, 1, 1, 1}, {1, 1, 1, 0})
    ps:setPosition(200, 300)
    ps:start()

    cursor = {
        sizewe = love.mouse.getSystemCursor('sizewe'),
        hand = love.mouse.getSystemCursor('hand'),
        crosshair = love.mouse.getSystemCursor('crosshair'),
    }

    -- minmax means that increasing the minimum value past the maximum value with increase the maximum value as well, and vice versa.
    buttonSettings = {
        {
            name = 'Texture',
            clickable = true,
        },
        {
            name = 'BufferSize',
            limits = {lower = 1},
        },
        {
            name = 'Count',
        },
        {
            name = 'EmissionRate',
            limits = {lower = 0},
        },
        {
            name = 'EmissionArea',
        },
        {
            name = 'InsertMode',
            clickable = true,
        },
        {
            name = 'ParticleLifetime',
            limits = {lower = 0},
            minmax = true,
            change = 0.01,
        },

        {
            name = 'Sizes',
            change = 0.01,
        },
        {
            name = 'SizeVariation',
            limits = {lower = 0, upper = 1},
            change = 0.002,
        },

        {
            name = 'Speed',
            minmax = true,
        },
        {
            name = 'Direction',
            change = 0.01,
        },
        {
            name = 'Spread',
            change = 0.01,
        },

        {
            name = 'RadialAcceleration',
            minmax = true,
        },
        {
            name = 'TangentialAcceleration',
            minmax = true,
        },
        {
            name = 'LinearAcceleration',
        },
        {
            name = 'LinearDamping',
            minmax = true,
            change = 0.1,
        },

        {
            name = 'Rotation',
            minmax = true,
            change = 0.01,
        },
        {
            name = 'RelativeRotation',
            clickable = true,
        },
        {
            name = 'Spin',
            change = 0.01,
            minmax = true,
        },
        {
            name = 'SpinVariation',
            change = 0.01,
        },
        {
            name = 'Offset',
        },

        {
            name = 'Colors',
            limits = {lower = 0, upper = 1},
            change = 0.002,
        },
        {
            name = 'Background',
            clickable = true,
        },
        {
            name = 'love.graphics.setBlendMode',
            clickable = true,
        },
    }

    function getButtonSetting(name)
        for buttonSettingIndex, buttonSetting in ipairs(buttonSettings) do
            if buttonSetting.name == name then
                return buttonSetting
            end
        end
        return {}
    end

    position = {}
    position.panelX = 430
    position.panelWidth = 800 - position.panelX
    position.startX = position.panelX + 210
    position.startY = 10

    blendMode = 'alpha'
        
    backgroundColor = 'black'

    dragging = {}
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function isMouseIn(x, y, width, height)
    return love.mouse.getX() >= x
    and love.mouse.getX() < x + width
    and love.mouse.getY() >= y
    and love.mouse.getY() < y + height
end

function getActualButtons()
    local actualButtons = {}

    local offsetY = 0
    local function increaseOffsetY()
        offsetY = offsetY + love.graphics.getFont():getHeight() + 2
    end

    for buttonSettingIndex, buttonSetting in ipairs(buttonSettings) do
        if not (buttonSetting.name == 'love.graphics.setBlendMode' and backgroundColor == 'white') then
            
            local paddingX = 2
            local actualButton = {
                name = buttonSetting.name,
                buttons = {},
            }
            
            local offsetX = 0
            local function increaseOffsetX(value)
                offsetX = offsetX + love.graphics.getFont():getWidth(tostring(value)) + 10
            end

            local function newButton(value)
                return {
                    x = position.startX + offsetX - paddingX,
                    y = position.startY + offsetY,
                    width = love.graphics.getFont():getWidth(tostring(value)) + paddingX * 2,
                    height = love.graphics.getFont():getHeight() - 1,
                    textX = position.startX + offsetX,
                    value = value,
                }
            end

            if buttonSetting.name == 'love.graphics.setBlendMode' and backgroundColor == 'black' then
                table.insert(actualButton.buttons, newButton(blendMode))
            end
            
            if buttonSetting.name == 'Background' then
                table.insert(actualButton.buttons, newButton(backgroundColor))
            end

            if buttonSetting.name == 'Colors' then
                offsetX = 0

                local add = newButton('add')
                local colors = {ps:getColors()}
                add.disabled = #colors == 8
                add.action = function()
                    local colors = {ps:getColors()}
                    if #colors < 8 then
                        table.insert(colors, {unpack(colors[#colors])})
                        ps:setColors(unpack(colors))
                    end
                end
                table.insert(actualButton.buttons, add)

                increaseOffsetX('add')

                local remove = newButton('remove')
                remove.disabled = #colors == 1
                remove.action = function()
                    local colors = {ps:getColors()}
                    if #colors > 1 then
                        table.remove(colors)
                        ps:setColors(unpack(colors))
                    end
                end
                table.insert(actualButton.buttons, remove)

                offsetX = 0
                increaseOffsetY()
                
            elseif buttonSetting.name == 'Sizes' then
                offsetX = 0

                local add = newButton('add')
                local sizes = {ps:getSizes()}
                add.disabled = #sizes == 8
                add.action = function()
                    local sizes = {ps:getSizes()}
                    if #sizes < 8 then
                        table.insert(sizes, sizes[#sizes])
                        ps:setSizes(unpack(sizes))
                    end
                end
                table.insert(actualButton.buttons, add)

                increaseOffsetX('add')

                local remove = newButton('remove')
                remove.disabled = #sizes == 1
                remove.action = function()
                    local sizes = {ps:getSizes()}
                    if #sizes > 1 then
                        table.remove(sizes)
                        ps:setSizes(unpack(sizes))
                    end
                end
                table.insert(actualButton.buttons, remove)

                offsetX = 0
                increaseOffsetY()
            end
            
            if buttonSetting.name == 'EmissionArea' then
                local distribution, dx, dy, angle, directionRelativeToCenter = ps:getEmissionArea()
                table.insert(actualButton.buttons, newButton(distribution))
                if distribution ~= 'none' then
                    increaseOffsetY()
                    table.insert(actualButton.buttons, newButton(dx))
                    increaseOffsetX(dx)
                    table.insert(actualButton.buttons, newButton(dy))
                    increaseOffsetX(dy)
                    table.insert(actualButton.buttons, newButton(round(angle, 1)))
                    increaseOffsetX(round(angle, 1))
                    table.insert(actualButton.buttons, newButton(directionRelativeToCenter))
                    increaseOffsetX(tostring(directionRelativeToCenter))
                end            
            else
                local got = (ps['get'..buttonSetting.name] and {ps['get'..buttonSetting.name](ps)}) or (ps['has'..buttonSetting.name] and {ps['has'..buttonSetting.name](ps)})
                for gotIndex, gotValue in ipairs(got or {}) do
                    local value
                    if buttonSetting.name == 'Texture' then
                        value = images[imageIndex].name
                    elseif buttonSetting.name == 'InsertMode'
                    or buttonSetting.name == 'love.graphics.setBlendMode' then
                        value = gotValue
                    elseif buttonSetting.name == 'RelativeRotation' then
                        value = tostring(gotValue)
                    elseif buttonSetting.name ~= 'Colors' and buttonSetting.name ~= 'Sizes' then
                        value = round(gotValue, 1)
                    end

                    if buttonSetting.name == 'Colors' then
                        for componentIndex, component in ipairs(gotValue) do
                            local value = round(component, 2)
                            table.insert(actualButton.buttons, newButton(value))
                            if componentIndex % 4 == 0 and gotIndex < #got then
                                increaseOffsetY()
                                offsetX = 0
                            else
                                increaseOffsetX(value)
                            end
                        end
                    elseif buttonSetting.name == 'Sizes' then
                        local value = round(gotValue, 1)
                        table.insert(actualButton.buttons, newButton(value))
                        if gotIndex % 4 == 0 and gotIndex < #got then
                            increaseOffsetY()
                            offsetX = 0
                        else
                            increaseOffsetX(value)
                        end
                    else
                        table.insert(actualButton.buttons, newButton(value))
                        increaseOffsetX(value)
                    end
                end
            end

            table.insert(actualButtons, actualButton)

            increaseOffsetY()
        end
    end

    return actualButtons
end

function love.update(dt)
    -- Move the ParticleSystem to the mouse position if the mouse is down and it's not dragging something or in the panel area
    if not love.mouse.getRelativeMode() and love.mouse.isDown(1) and not isMouseIn(position.panelX, 0, position.panelWidth, love.graphics.getHeight()) then
        ps:moveTo(love.mouse.getPosition())
    end

    ps:update(dt)

    hovering = {}
    if not love.mouse.getRelativeMode() then -- Prevents hovering when already dragging
        for actualButtonIndex, actualButton in ipairs(getActualButtons()) do
            for buttonIndex, button in ipairs(actualButton.buttons) do
                if isMouseIn(button.x, button.y, button.width, button.height) then
                    hovering = {
                        name = actualButton.name,
                        index = buttonIndex,
                        button = button,
                    }
                end
            end
        end
    end

    -- Cursor is crosshair if not in panel
    if not isMouseIn(position.panelX, 0, position.panelWidth, love.graphics.getHeight()) then
        love.mouse.setCursor(cursor.crosshair)

    -- Cursor is hand if clickable
    elseif getButtonSetting(hovering.name).clickable
    or (hovering.button and hovering.button.action and not hovering.button.disabled)
    or (hovering.name == 'EmissionArea' and (hovering.index == 1 or hovering.index == 5))  then
        love.mouse.setCursor(cursor.hand)
    
    -- Cursor is arrow if not hovering or buttton is disabled
    elseif not hovering.name
    or hovering.name == 'Count'
    or (hovering.button and hovering.button.disabled) then
        love.mouse.setCursor()

    -- Cursor is sizewe if draggable
    elseif hovering.name then
        love.mouse.setCursor(cursor.sizewe)
    end

    -- If button is being dragged...
    if dragging.name then
        local got = {ps['get'..dragging.name](ps)}
        if dragging.name == 'Colors' then
            local setColorTables = {}
            for colorTableIndex, colorTable in ipairs(got) do
                setColorTables[colorTableIndex] = {}
                for componentIndex, component in ipairs(colorTable) do
                    -- If this component is being dragged... (componentIndex is offset by 2 because of the add/remove buttons)
                    if (#colorTable*(colorTableIndex-1)) + componentIndex + 2 == dragging.index then
                        local value = dragging.initial + dragging.value*getButtonSetting('Colors').change
                        value = math.max(math.min(value, 1), 0)
                        setColorTables[colorTableIndex][componentIndex] = value
                    else
                        setColorTables[colorTableIndex][componentIndex] = component
                    end
                end
            end
            ps:setColors(unpack(setColorTables))
        else -- If not dragging Colors...
            
            local limits = getButtonSetting(dragging.name).limits            
            local change = getButtonSetting(dragging.name).change or 1
            
            if dragging.name == 'EmissionArea' then
                if dragging.index == 2 or dragging.index == 3 then
                    limits = {lower = 0}
                end
                if dragging.index == 4 then
                    change = 0.01
                end
            end
            
            got[dragging.index] = dragging.initial + dragging.value*change
            
            
            if limits then
                if limits.lower and got[dragging.index] < limits.lower then
                    got[dragging.index] = limits.lower
                elseif limits.upper and got[dragging.index] > limits.upper then
                    got[dragging.index] = limits.upper
                end
            end
            if dragging.name == 'LinearAcceleration' then
                if dragging.index == 1 then
                    got[3] = math.max(got[1], got[3])
                elseif dragging.index == 2 then
                    got[4] = math.max(got[2], got[4])
                elseif dragging.index == 3 then
                    got[1] = math.min(got[1], got[3])
                elseif dragging.index == 4 then
                    got[2] = math.min(got[2], got[4])
                end
            end
            if getButtonSetting(dragging.name).minmax then
                if dragging.index == 1 then
                    got[2] = math.max(got[dragging.index], got[2])
                elseif dragging.index == 2 then
                    got[1] = math.min(got[dragging.index], got[1])
                end
            end

            ps['set'..dragging.name](ps, unpack(got))
        end
    end
end

function love.draw()
    if backgroundColor == 'black' then
        love.graphics.setBackgroundColor(0, 0, 0)
    else
        love.graphics.setBackgroundColor(1, 1, 1)
    end
    
    love.graphics.setColor(1, 1, 1)
    if backgroundColor == 'black' then
        love.graphics.setBlendMode(blendMode)
    else
        love.graphics.setBlendMode('alpha')
    end
    love.graphics.draw(ps)
    love.graphics.setBlendMode('alpha')

    love.graphics.setColor(.2, .2, .2, .7)
    love.graphics.rectangle('fill', position.panelX, 0, position.panelWidth, love.graphics.getHeight())

    for actualButtonIndex, actualButton in ipairs(getActualButtons()) do
        love.graphics.setColor(.8, .8, .8)
        love.graphics.printf(actualButton.name, actualButton.buttons[1].x - 1000 - 10, actualButton.buttons[1].y, 1000, 'right')

        for buttonIndex, button in ipairs(actualButton.buttons) do
            local boxColor
            local textColor
            if not button.disabled and actualButton.name ~= 'Count' and (
                (hovering.name == actualButton.name and hovering.index == buttonIndex) or
                (dragging.name == actualButton.name and (
                    -- dragging.index is offset by 2 because of the add/remove buttons
                    (dragging.name == 'Sizes' and dragging.index + 2 == buttonIndex) or
                    (dragging.name ~= 'Sizes' and dragging.index == buttonIndex)
                ))
            ) then
                boxColor = {.9, .34, .62}
                textColor = {1, 1, 1}
            elseif button.disabled then
                boxColor = {.3, .3, .3, .5}
                textColor = {.6, .6, .6}
            else
                boxColor = {.3, .3, .3}
                textColor = {.8, .8, .8}
            end
            if actualButton.name ~= 'Count' then
                love.graphics.setColor(boxColor)
                love.graphics.rectangle('fill', button.x, button.y, button.width, button.height, 3)
            end

            love.graphics.setColor(textColor)
            love.graphics.print(tostring(button.value), button.textX, button.y)
        end
    end
end

function love.mousepressed(x, y, mouseButton, isTouch, clickCount)
    if mouseButton == 1 then
        for actualButtonIndex, actualButton in ipairs(getActualButtons()) do
            for buttonIndex, button in ipairs(actualButton.buttons) do
                if isMouseIn(button.x, button.y, button.width, button.height) then
                    if actualButton.name == 'Texture' then
                        imageIndex = imageIndex + 1
                        if imageIndex > #images then
                            imageIndex = 1
                        end
                        ps:setTexture(images[imageIndex].image)

                    elseif actualButton.name == 'InsertMode' then
                        local mode, x, y = ps:getInsertMode()
                        ps:setInsertMode(({
                            top = 'bottom',
                            bottom = 'random',
                            random = 'top',
                        })[mode], x, y)
                        
                    elseif actualButton.name == 'love.graphics.setBlendMode' then
                        blendMode = ({
                            alpha = 'add',
                            add = 'alpha',
                        })[blendMode]
                        
                    elseif actualButton.name == 'Background' then
                        backgroundColor = ({
                            black = 'white',
                            white = 'black',
                        })[backgroundColor]

                    elseif actualButton.name == 'RelativeRotation' then
                        ps:setRelativeRotation(not ps:hasRelativeRotation())
                    
                    elseif actualButton.name == 'EmissionArea' and buttonIndex == 1 then
                        local distribution, dx, dy, angle, directionRelativeToCenter = ps:getEmissionArea()
                        distribution = ({
                            none = 'uniform',
                            uniform = 'normal',
                            normal = 'ellipse',
                            ellipse = 'borderellipse',
                            borderellipse = 'borderrectangle',
                            borderrectangle = 'none',
                        })[distribution]
                        ps:setEmissionArea(distribution, dx, dy, angle, directionRelativeToCenter)
                        
                    
                    elseif actualButton.name == 'EmissionArea' and buttonIndex == 5 then
                        local distribution, dx, dy, angle, directionRelativeToCenter = ps:getEmissionArea()
                        ps:setEmissionArea(distribution, dx, dy, angle, not directionRelativeToCenter)

                    elseif button.action then
                        button.action()

                    elseif actualButton.name ~= 'Count' then
                        dragging = {
                            name = actualButton.name,
                            index = buttonIndex,
                            initialX = x,
                            initialY = y,
                            value = 0,
                            initial = button.value,
                        }
                        if actualButton.name == 'Sizes' then
                            -- dragging.index is offset by 2 because of the add/remove buttons
                            dragging.index = dragging.index - 2
                        end
                        love.mouse.setRelativeMode(true)
                    end
                end
            end
        end
    elseif mouseButton == 2 then
        for actualButtonIndex, actualButton in ipairs(getActualButtons()) do
            for buttonIndex, button in ipairs(actualButton.buttons) do
                if isMouseIn(button.x, button.y, button.width, button.height) then
                    if actualButton.name == 'Sizes' then
                        local got = {ps:getSizes()}
                        -- buttonIndex is offset by 2 because of the add/remove buttons
                        got[buttonIndex - 2] = 0
                        ps:setSizes(unpack(got))
                    elseif actualButton.name == 'EmissionArea' then
                        if buttonIndex == 2 or buttonIndex == 3 or buttonIndex == 4 then
                            local got = {ps:getEmissionArea()}
                            got[buttonIndex] = 0
                            ps:setEmissionArea(unpack(got))
                        end
                    elseif actualButton.name ~= 'Colors'
                    and actualButton.name ~= 'BufferSize'
                    and actualButton.name ~= 'Count'
                    and actualButton.name ~= 'InsertMode'
                    and actualButton.name ~= 'RelativeRotation'
                    and actualButton.name ~= 'Background'
                    and actualButton.name ~= 'love.graphics.setBlendMode'
                    and actualButton.name ~= 'Texture' then
                        ps['set'..actualButton.name](ps, 0, 0, 0, 0)
                    end
                end
            end
        end
    end
end

function love.mousereleased(x, y, mouseButton)
    if mouseButton == 1 then
        if love.mouse.getRelativeMode() then
            love.mouse.setRelativeMode(false)
            love.mouse.setPosition(dragging.initialX, dragging.initialY)
        end
        dragging = {}
    end
end

function love.mousemoved(x, y, dx, dy)
    if love.mouse.getRelativeMode() then
        -- Prevent further increasing/decreasing dragging.value when the value is already beyond limits
        local value = dragging.initial + dragging.value*(getButtonSetting(dragging.name).change or 1)
        local limits = getButtonSetting(dragging.name).limits
        if not (limits and limits.lower and value < limits.lower and dx < 0)
        and not (limits and limits.upper and value > limits.upper and dx > 0) then
            dragging.value = dragging.value + dx
        end
    end
end

function love.filedropped(file)
    pcall(function()
        ps:setTexture(love.graphics.newImage(file))
    end)
end
