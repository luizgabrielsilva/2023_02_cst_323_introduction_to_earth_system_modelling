--- A Model to simulate fire in the forest.

-- @arg data.finalTime A number with the final simulation time.
-- @arg data.dim A number with the x and y size of space.
-- @arg data.neighborhood The neighborhood to be used, default is vonneumann.
-- @arg data.burningStepThreshold Number of steps a cell will burn util it is
-- burned - default is 1.
-- @arg data.burningProbability The probability a cell will burn if it finds a
-- burning neighbor - default is 1.
-- @arg data.empty The probability of empty cells in the beginning of the
-- simulation. It must be a value between 0 and 1, with default 0.1.
-- @image fire.bmp

import("ca")

Fire = Model{
	finalTime = 100,
	empty = Choice{min = 0, max = 1, default = 0.1},
	dim = 60,
    neighborhood="vonneumann",
    burningStepThreshold = 1,
    burningProbability = 1,
	random = true,
	init = function(model)
		model.cell = Cell{
            burningStep = 0,
			init = function(cell)
				if Random():number() > model.empty then
					cell.state = "forest"
				else
					cell.state = "empty"
				end
			end,
			execute = function(cell)
                if cell.past.state == "burning" and cell.past.burningStep < model.burningStepThreshold  then
                    cell.burningStep = cell.burningStep + 1
				elseif cell.past.burningStep == model.burningStepThreshold then
					cell.state = "burned"
				elseif cell.past.state == "forest" then
					local burning = countNeighbors(cell, "burning")

					if burning > 0 and Random():number() < model.burningProbability then
						cell.state = "burning"
                        cell.burningStep = cell.burningStep + 1
					end
				end
			end
		}

		model.cs = CellularSpace{
			xdim = model.dim,
			instance = model.cell
		}

		local initialCell = model.cs:sample()
        initialCell.state = "burning"
        initialCell.burningStep = 1

		model.cs:createNeighborhood{strategy = model.neighborhood}

		model.chart = Chart{
			target = model.cs,
			select = "state",
			value = {"forest", "burning", "burned"},
			color = {"green", "red", "brown"}
		}

		model.map = Map{
			target = model.cs,
			select = "state",
			value = {"forest", "burning", "burned", "empty"},
			color = {"green", "red", "brown", "white"}
		}

		model.timer = Timer{
			Event{action = model.cs},
			Event{action = model.chart},
			Event{action = model.map}
		}
	end
}
