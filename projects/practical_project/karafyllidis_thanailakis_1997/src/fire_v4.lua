Fire = Model{
	finalTime = 80,
	dim = 81,
	init = function(model)
		model.cell = Cell{
			init = function(cell)
                cell.state = 0
                cell.fireSpeed = 0.1

                cell.windN = 1
                cell.windS = 1
                cell.windE = 1.5
                cell.windW = 0.5
                cell.windNe = 1
                cell.windSe = 1
                cell.windNw = 1
                cell.windSw = 1

            end,
            execute = function(cell)

                if cell.state < 1 and cell.fireSpeed > 0then
                    local adjContrib = 0
                    local diaContrib = 0

                    local adjCoeff = cell.fireSpeed
                    local diaCoeff = math.min(cell.fireSpeed ^ 2, (math.sqrt(2) - cell.fireSpeed) ^ 2)

                    forEachNeighbor(cell, "adjacent", function(neighbor)

                        local neighborWeith = adjCoeff
                        if neighbor.y > cell.y then
                            neighborWeith = neighborWeith * cell.windN
                        elseif neighbor.y < cell.y then
                            neighborWeith = neighborWeith * cell.windS
                        elseif neighbor.x < cell.x then
                            neighborWeith = neighborWeith * cell.windE
                        else
                            neighborWeith = neighborWeith * cell.windW
                        end
                        adjContrib = adjContrib + neighborWeith * neighbor.past.state
                    end)

                    forEachNeighbor(cell, "diagonal", function(neighbor)

                        local neighborWeith = diaCoeff
                        if neighbor.y < cell.y and neighbor.x > cell.x then
                            neighborWeith = neighborWeith * cell.windNe
                        elseif neighbor.y < cell.y and neighbor.x < cell.x then
                            neighborWeith = neighborWeith * cell.windNw
                        elseif neighbor.y > cell.x and neighbor.x > cell.x then
                            neighborWeith = neighborWeith * cell.windSe
                        else
                            neighborWeith = neighborWeith * cell.windSw
                        end

                        diaContrib = diaContrib + neighborWeith * neighbor.past.state
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
--            for j=35, 45 do
--                model.cs:get(i,j).fireSpeed = 0
--            end
--        end

		model.cs:createNeighborhood{strategy = "vonneumann", name="adjacent"}
        model.cs:createNeighborhood{strategy = "diagonal", name="diagonal"}

		model.map = Map{
			target = model.cs,
			select = "state",
            min = 0.2,
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