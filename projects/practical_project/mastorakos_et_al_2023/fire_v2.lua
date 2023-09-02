-- @delta: size of each cell in meters (m)
-- @deltaT: time interval in seconds (s)
-- @dim: dimension of cellular space
-- @finalTime: number of simulation steps - time is measured in seconds (s)
-- @criticalValue: critical value of burning status for a cell to be ignited - Ylim
-- @noWindPropSpeed: speed of fire propagation without wind (radiative propagation) - Sf,0 (m/s)
-- @highOfRadFire: high of radiation fire - fire without wind - Lr (m)
-- @ignitionTime: time require to a cell to be ignited after receiving a cell with burningStatus > criticalValue (s)

--@cell.ignitionTime: time required for a cell visited by a hot particle to ignite
--@cell.windComponentX|Y: component of wind in the direction x|y (m/s)

--------------------------------------------------------------------------------
-- Auxiliary Functions
--------------------------------------------------------------------------------

Random{seed = 492431}

getPos = function(coordX, coordY, delta) -- CellularSpace -> Geographic Space
    return (coordX + 0.5) * delta, (coordY + 0.5) * delta
end

getCoord = function(posX, posY, delta) -- Geographic Space -> CellularSpace
    return math.floor(posX / delta), math.floor(posY / delta)
end


randUniGen = Random{min = 0, max = 2 * math.pi}
randNormGen = Random{distrib = "normal", mean = 0}



Fire = Model{
    delta = 1,
    deltaT = 10,
    dim = 101,
    finalTime = 50,

    criticalValue = 0.2,
    noWindPropSpeed = 0.1,
    highOfRadFire = 10,
    ignitionTime = 10,
    randCompIgnTime = 0.1,

    init = function(model)

--------------------------------------------------------------------------------
-- Agents and Society
--------------------------------------------------------------------------------

        model.agent = Agent{

            updateSpeed = function(agent)
                local phi = randUniGen:sample()
                local radSpeedX = model.noWindPropSpeed * math.sin(phi)
                local radSpeedY = model.noWindPropSpeed * math.cos(phi)

                local convSpeedX = 0
                local convSpeedY = 0

                agent.speedX = radSpeedX + convSpeedX
                agent.speedY = radSpeedY + convSpeedY
            end,


            updatePosition = function(agent)
                local posX, posY  = agent.posX, agent.posY
                local agentCell = agent:getCell()


                if agent.posX == nil then
                    posX, posY = getPos(agentCell.x, agentCell.y, model.delta)
                end

                agent.posX = posX + agent.speedX * model.deltaT
                agent.posY = posY + agent.speedY * model.deltaT

            end,


            updateBurningStatus = function(agent)
                local decayRate = model.highOfRadFire / model.noWindPropSpeed
                agent.burningStatus = agent.burningStatus * (1 - model.deltaT / decayRate)
            end,

            init = function(agent)
                agent.burningStatus = 1
                agent.speedX = 0
                agent.speedY = 0
                agent.posX = nil
                agent.posY = nil

            end,


            execute = function(agent)
                --local agentCell = agent:getCell()
                agent:updateSpeed()
                agent:updatePosition()
                agent:updateBurningStatus()

                --local newCoordX, local newCoordY = getCoord(agent.posX, agent.posY, model.delta)

                --if agent.burningStatus <= model.criticalValue then
                --    agent:die()
                --    return false
                --end
                --print(agent.speedX, agent.speedY, agent.posX, agent.posY, agent.burningStatus)

                agent:move(model.cs:get(getCoord(agent.posX, agent.posY, model.delta)))

                --agent:walk()
            end
        }

        model.society = Society{
            instance = model.agent,
            quantity = 0
        }

--------------------------------------------------------------------------------
-- Cell and Cellular Space
--------------------------------------------------------------------------------

        model.cell = Cell{
            state = "noninitiated",
            clock = 0,
            burningDensity = 0,
            windComponentX = 0,
            windComponentY = 0,

            updateClock = function(cell) cell.clock = cell.clock + model.deltaT end,
            getBurned = function(cell) cell.state = "burned" end,
            getIgnited = function(cell)
                cell.state = "ignited"
                local newAgent = model.society:add()
                newAgent:enter(cell)
            end,

            getInitiated = function(cell)
                cell.state = "preignited"
                cell:updateClock()
            end,

            getBurningDensity = function(cell)
                local burningTotal = 0
                local countAgents = 0
                forEachAgent(cell, function(agent)
                    burningTotal = burningTotal + agent.burningStatus
                    countAgents = countAgents + 1
                end)

                if countAgents > 0 then cell.burningDensity = burningTotal / countAgents
                    else cell.burningDensity = 0 end
            end,


            init = function(cell)
                cell.ignitionTime = model.ignitionTime * (1 - Random{min = -model.randCompIgnTime, max = model.randCompIgnTime}:sample())


            end,

            execute = function(cell)
--                if cell.burningStatus == 1 then
--                    local phi = randomGenerator:sample()
--                    local dx = model.highOfRadFire * math.cos(randomGenerator:sample())
--                    local dy = model.highOfRadFire * math.sin(randomGenerator:sample())
--
--                    local cellGeoPosX, cellGeoPosY = getPos(cell.x, cell.y, model.delta)
--
--
--
--                    print(cell.ignitionTime, dx, dy, cellGeoPosX, cellGeoPosY)
--                end
                if cell.state == "ignited" then cell:getBurned() end

                if cell.state == "preignited" then
                    if cell.clock >= model.ignitionTime then cell:getIgnited()
                    else cell:updateClock() end
                end

                if cell.state == "noninitiated" then
                    forEachAgent(cell, function(agent)
                        if agent.burningStatus > model.criticalValue then
                            cell:getInitiated()
                            return false
                        end
                    end)
                end

                cell:getBurningDensity()


            end
        }

        model.cs = CellularSpace{
            xdim = model.dim,
            instance = model.cell
        }

        model.cs:createNeighborhood{self=true}

--------------------------------------------------------------------------------
-- Environment
--------------------------------------------------------------------------------

        model.env = Environment{
            model.cs,
            model.society
        }

        model.env:createPlacement{strategy = "void"}

--------------------------------------------------------------------------------
-- Inicialization
--------------------------------------------------------------------------------

        local middle = math.floor(model.dim / 2)
        model.cs:get(middle, middle):getIgnited()
--------------------------------------------------------------------------------
-- Visualizations
--------------------------------------------------------------------------------
--        model.map = Map{
--            target = model.cs,
--            select = "burningStatus",
--            min = 0,
--            max = 1,
--            color = "Oranges",
--            slices = 10,
--            --invert = true,
--            grid = true
--        }

        model.map = Map{
            target = model.cs,
            select = "state",
            value = {"noninitiated", "preignited", "ignited", "burned"},
            color = {"green", "yellow", "orange", "brown"},
            grid = true
        }

--        model.map_2 = Map{
--            target = model.cs,
--            select = "ignitionTime",
--            min = (1 - model.randCompIgnTime) * model.ignitionTime,
--            max = (1 + model.randCompIgnTime) * model.ignitionTime,
--            color = "RdBu",
--            slices = 10,
--            --invert = true,
--            grid = true
--        }

        model.map = Map{
            target = model.society,
            --select = "burningStatus",
            background = model.map,
            color = "red",
            --min = 0,
            --max = 1,
            --slices = 10,
        }

        model.map2 = Map{
            target = model.cs,
            select = "burningDensity",
            max = 1,
            min = 0,
            slices = 10,
            color = "RdBu",
            invert=true,
            grid = true
        }

       --model.chart = Chart{
       --    target = model.cs,
       --    select = "state",
       --    value = {"burned"}
       --}

--------------------------------------------------------------------------------
-- Timer
--------------------------------------------------------------------------------

        model.timer = Timer{
            Event{action = model.map},
            Event{action = model.map2},
            Event{action = model.society, priority="high"},
            Event{action = model.cs}
        }

    end

}

Fire{finalTime = 120, dim = 81, deltaT=10}:run()