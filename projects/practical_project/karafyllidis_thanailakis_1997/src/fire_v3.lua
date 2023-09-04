Fire = Model{
	finalTime = 100,
	dim = 81,
	init = function(model)
		model.cell = Cell{
			init = function(cell)
                cell.state = 0
                cell.fireSpeed = 0.1
            end,

            execute = function(cell)
                if cell.state < 1 and cell.fireSpeed > 0then
                    local adjContrib = 0
                    local diaContrib = 0

                    adjCoeff = cell.fireSpeed
                    diaCoeff = math.min(cell.fireSpeed ^ 2, (math.sqrt(2) - cell.fireSpeed) ^ 2)

                    forEachNeighbor(cell, "adjacent", function(neighbor)
                        adjContrib = adjContrib + adjCoeff * neighbor.past.state
                    end)

                    forEachNeighbor(cell, "diagonal", function(neighbor)
                        diaContrib = diaContrib + diaCoeff * neighbor.past.state
                    end)

                    cell.state = math.min(1, cell.state + adjContrib + diaContrib)
                end
            end
		}

		model.cs = CellularSpace{
			xdim = model.dim,
			instance = model.cell
		}

		model.cs:get(40,40).state = 1

--        for i=25, 35 do
--            for j=40, 50 do
--                model.cs:get(i,j).fire_speed = 0.01
--            end
--        end

		model.cs:createNeighborhood{strategy = "vonneumann", name="adjacent"}
        model.cs:createNeighborhood{strategy = "diagonal", name="diagonal"}

		model.map = Map{
			target = model.cs,
			select = "state",
            min = 0,
            max = 1,
			slices = 10,
			color = "YlOrBr",
		}

		model.timer = Timer{
			Event{action = model.cs},
			Event{action = model.map}
		}
	end
}

Fire:run()