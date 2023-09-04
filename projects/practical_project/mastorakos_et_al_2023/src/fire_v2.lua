-- @delta: size of each cell in meters (m)
-- @deltaT: time interval in seconds (s)
-- @dim: dimension of cellular space
-- @finalTime: number of simulation steps - time is measured in seconds (s)
-- @criticalValue: critical value of burning status for a cell to be ignited - Ylim
-- @noWindPropSpeed: speed of fire propagation without wind (radiative propagation) - Sf,0 (m/s)
-- @highOfRadFire: high of radiation fire - fire without wind - Lr (m)
-- @highOfConvFire: high of convection fire - fire with wind - Lt (m)
-- @ignitionTime: time require to a cell to be ignited after receiving a cell with burningStatus > criticalValue (s)

--@cell.ignitionTime: time required for a cell visited by a hot particle to ignite
--@cell.windComponentX|Y: component of wind in the direction x|y (m/s)

--------------------------------------------------------------------------------
-- Auxiliary Functions
--------------------------------------------------------------------------------

getPos = function(coordX, coordY, delta) -- CellularSpace -> Geographic Space
    return (coordX + 0.5) * delta, (coordY + 0.5) * delta
end

getCoord = function(posX, posY, delta) -- Geographic Space -> CellularSpace
    return math.floor(posX / delta), math.floor(posY / delta)
end


randUniGen = Random{min = 0, max = 2 * math.pi}
randNormGen = Random{distrib = "normal", mean = 0}



Fire = Model{
    delta = 2,
    deltaT = 10,
    xDim = 101,
    yDim = 101,
    initialX = 50,
    initialY = 50,
    finalTime = 60,
    criticalValue = 0.2,
    noWindPropSpeed = 0.1,
    highOfRadFire = 10,
    highOfConvFire = 50,
    ignitionTime = 10,
    randCompIgnTime = 0.2,
    scalingFactor = 0.15,
    factorA = 0.3,
    constantC = 1.9,
    windDecayRate = 10,
    windSpeedX = 10,
    windSpeedY = 0,

    init = function(model)

--------------------------------------------------------------------------------
-- Agents and Society
--------------------------------------------------------------------------------

        model.agent = Agent{

            updateWindSpeed = function(agent)
                local agentCell = agent:getCell()
                local normal = randNormGen:sample()
                local windSpeed = math.sqrt(agentCell.windSpeedX ^ 2 + agentCell.windSpeedY ^ 2)
                local u = model.factorA * windSpeed
                local epsilon = u ^ 3 / model.highOfConvFire

                local const = ((2 + 3 * model.constantC) * u / (4 * model.highOfConvFire))
                local turbulentTerm = math.sqrt(model.constantC * epsilon * model.deltaT) * normal

                local dSpeedX = - const * (agent.speedX - agentCell.windSpeedX) * model.deltaT + turbulentTerm
                local dSpeedY = - const * (agent.speedY - agentCell.windSpeedY) * model.deltaT + turbulentTerm

                agent.speedX = agent.speedX + dSpeedX
                agent.speedY = agent.speedY + dSpeedY
            end,

            updatePosition = function(agent)
                local posX, posY  = agent.posX, agent.posY
                local agentCell = agent:getCell()


                if agent.posX == nil then
                    posX, posY = getPos(agentCell.x, agentCell.y, model.delta)
                end

                local phi = randUniGen:sample()

                agent.posX = posX + (model.scalingFactor * agent.speedX + model.noWindPropSpeed * math.sin(phi)) * model.deltaT
                agent.posY = posY + (model.scalingFactor * agent.speedY + model.noWindPropSpeed * math.cos(phi)) * model.deltaT

            end,

            updateBurningStatus = function(agent)
                agent.burningStatus = agent.burningStatus * (1 - model.deltaT / agent.decayRate)
            end,

            init = function(agent)
                agent.burningStatus = 1
                agent.speedX = 0
                agent.speedY = 0
                agent.posX = nil
                agent.posY = nil
            end,

            execute = function(agent)

                if (agent:getCell().windSpeedX > 0) or (agent:getCell().windSpeedY > 0) then
                    agent:updateWindSpeed()
                    agent.decayRate = model.windDecayRate
                else agent.decayRate = model.highOfRadFire / model.noWindPropSpeed
                end

                agent:updatePosition()
                agent:updateBurningStatus()
                agent:move(model.cs:get(getCoord(agent.posX, agent.posY, model.delta)))
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
            burningDensity = -1,
            windSpeedX = model.windSpeedX,
            windSpeedY = model.windSpeedY,

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
                else
                    if cell.state == "burned" then cell.burningDensity = 0 end
                end
            end,


            init = function(cell)
                cell.ignitionTime = model.ignitionTime
            end,

            execute = function(cell)

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
                        else agent:die()
                        end
                    end)
                end
                cell:getBurningDensity()
            end
        }

        model.cs = CellularSpace{
            xdim = model.xDim,
            ydim = model.yDim,
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

        model.cs:get(model.initialX, model.initialY):getIgnited()


--       for i=30, 40 do
--           for j=45, 55 do
--               model.cs:get(i,j).state = "unflamable"
--           end
--        end
--------------------------------------------------------------------------------
-- Visualizations
--------------------------------------------------------------------------------
        model.map = Map{
            target = model.cs,
            select = "state",
            value = {"noninitiated", "unflamable", "preignited", "ignited", "burned"},
            color = {"white", "lightGray", {240, 59, 32}, {254, 178, 56}, {255, 237, 160}},
        }

        model.map2 = Map{
            target = model.cs,
            select = "burningDensity",
            max = 1,
            min = 0,
            slices = 10,
            color = "Reds",
        }

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