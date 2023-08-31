-- @delta: size of each cell in meters (m)
-- @dim: dimension of cellular space
-- @finalTime: number of simulation steps - time is measured in seconds (s)
-- @criticalValue: critical value of burning status for a cell to be ignited - Ylim
-- @noWindPropSpeed: speed of fire propagation without wind (radiative propagation) - Sf,0 (m/s)
-- @highOfRadFire: high of radiation fire - fire without wind - Lr (m)
-- @ignitionTime: time require to a cell to be ignited after receiving a cell with burningStatus > criticalValue (s)

Fire = Model{
    delta = 2,
    dim = 11,
    finalTime = 300,

    criticalValue = 0.2,
    noWindPropSpeed = 0.1,
    highOfRadFire = 10,
    ignitionTime = 10,

    init = function(model)
        model.cell = Cell{
            burningStatus = 2,
            clock = 0,
            init = function(cell)


            end,

            execute = function(cell)


            end
        }

        model.cs = CellularSpace{
            xdim = model.dim,
            instance = model.cell
        }

        local middle = math.floor(model.dim / 2)
        model.cs:get(middle, middle).burningStatus = 1

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

        model.timer = Timer{
            Event{action = model.map}
        }

    end

}

Fire{finalTime = 1}:run()