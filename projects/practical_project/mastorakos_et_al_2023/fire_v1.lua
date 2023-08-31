-- @delta: size of each cell in meters (m)
-- @dim: dimension of cellular space
-- @finalTime: number of simulation steps - time is measured in seconds (s)
-- @criticalValue: critical value of burning status for a cell to be ignited - Ylim
-- @noWindPropSpeed: speed of fire propagation without wind (radiative propagation) - Sf,0 (m/s)
-- @highOfRadFire: high of radiation fire - fire without wind - Lr (m)
-- @ignitionTime: time require to a cell to be ignited after receiving a cell with burningStatus > criticalValue (s)

--------------------------------------------------------------------------------
-- Auxiliary Functions
--------------------------------------------------------------------------------

getPos = function(coordX, coordY, delta) -- CellularSpace -> Geographic Space
    return (coordX + 0.5) * delta, (coordY + 0.5) * delta
end

getCoord = function(posX, posY, delta) -- Geographic Space -> CellularSpace
    return math.floor(posX / delta), math.floor(posY / delta)
end


randomGenerator = Random{min = 0, max = 2 * math.pi}



Fire = Model{
    delta = 2,
    dim = 11,
    finalTime = 300,

    criticalValue = 0.2,
    noWindPropSpeed = 0.1,
    highOfRadFire = 10,
    ignitionTime = 10,
    randCompIgnTime = 0.1,

    init = function(model)
        model.cell = Cell{
            burningStatus = -1,
            clock = 0,
            init = function(cell)
                cell.ignitionTime = model.ignitionTime * (1 - Random{min = -model.randCompIgnTime, max = model.randCompIgnTime}:sample())


            end,

            execute = function(cell)
                if cell.burningStatus == 1 then
                    --local phi = randomGenerator:sample()
                    local dx = model.highOfRadFire * math.cos(randomGenerator:sample())
                    local dy = model.highOfRadFire * math.sin(randomGenerator:sample())

                    local cellGeoPosX, cellGeoPosY = getPos(cell.x, cell.y, model.delta)



                    print(cell.ignitionTime, dx, dy, cellGeoPosX, cellGeoPosY)
                end



            end
        }

        model.cs = CellularSpace{
            xdim = model.dim,
            instance = model.cell
        }

        local middle = math.floor(model.dim / 2)
        model.cs:get(middle, middle).burningStatus = 1


        print(model.cs:get(0, 0).ignitionTime)

        model.map = Map{
            target = model.cs,
            select = "burningStatus",
            min = 0,
            max = 1,
            color = "Oranges",
            slices = 10,
            --invert = true,
            grid = true
        }

        model.map_2 = Map{
            target = model.cs,
            select = "ignitionTime",
            min = (1 - model.randCompIgnTime) * model.ignitionTime,
            max = (1 + model.randCompIgnTime) * model.ignitionTime,
            color = "RdBu",
            slices = 10,
            --invert = true,
            grid = true
        }

        model.timer = Timer{
            Event{action = model.map},
            Event{action = model.map_2},
            Event{action = model.cs}
        }

    end

}

Fire{finalTime = 1}:run()