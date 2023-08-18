
Fire = Model{
	finalTime = 32,
	--empty = Choice{min = 0, max = 1, default = 0.1},
	dim = 65,
	--random = true,
	init = function(model)
		model.cell = Cell{
			init = function(cell) cell.state = 0 end,

            execute = function(cell)
                --print("Cell: ")
                --print(cell)
                --print("Neighbors: ")
                if cell.state < 1 then


                    forEachNeighbor(cell, function(neighbor)
                        local neighborWeight = 1
                        if neighbor.x ~= cell.x and neighbor.y ~= cell.y then
                            neighborWeight = 0.83
                        end

                        cell.state = math.min(1, cell.state + neighborWeight * neighbor.past.state)
                    end)
                end
                print(cell)
            end
		}

		model.cs = CellularSpace{
			xdim = model.dim,
			instance = model.cell
		}

		model.cs:get(32,32).state = 1
		model.cs:createNeighborhood{strategy = "moore"}

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
			Event{period=8, action = model.map}
		}
	end
}

Fire:run()