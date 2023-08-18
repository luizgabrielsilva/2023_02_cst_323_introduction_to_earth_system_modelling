Fire = Model{
	finalTime = 100,
	--empty = Choice{min = 0, max = 1, default = 0.1},
	dim = 81,
	--random = true,
	init = function(model)
		model.cell = Cell{
			init = function(cell)
                cell.state = 0
                cell.fire_speed = 0.1
            end,

            execute = function(cell)
                --print("Cell: ")
                --print(cell)
                --print("Neighbors: ")
                if cell.state < 1 and cell.fire_speed > 0then
                    forEachNeighbor(cell, function(neighbor)
                        local neighborWeight = cell.fire_speed
                        if neighbor.x ~= cell.x and neighbor.y ~= cell.y then
                            if cell.fire_speed <= math.sqrt(2) / 2 then
                                neighborWeight = cell.fire_speed ^ 2
                            else
                                neighborWeight = 2 * cell.fire_speed * math.sqrt(2) - (1 + cell.fire_speed ^ 2)
                            end
                        end
                        cell.state = math.min(1, cell.state + neighborWeight * neighbor.past.state)
                    end)
                end
                --print(cell)
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
			Event{action = model.map}
		}
	end
}

Fire:run()