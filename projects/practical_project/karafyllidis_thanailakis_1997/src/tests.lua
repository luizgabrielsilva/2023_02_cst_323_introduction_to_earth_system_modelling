


--n = Neighborhood()
--c1 = Cell{name="1"}
--c2 = Cell{name="2"}
--n:add(c1)
--
--c2:addNeighborhood(n)
--
--forEachNeighbor(c2, function(cell)
--    print(cell.name)
--end)

--n = Neighborhood()
--
cell = Cell{
    init = function(cell)
        cell.state = 0
        cell.fire_speed = 0.1
    end,

    n = Neighborhood()

    execute = function(cell) end
}
--
--cs = CellularSpace{xdim = 5, instance = cell}
--
--
--cs:createNeighborhood{name="diagonal", strategy="diagonal"}
--cs:createNeighborhood{name="adjacent", strategy="vonneumann"}
--
--
--c = cs:get(2, 2)
--
--print(c:getNeighborhood("diagonal"))

speed = 0.5

test = function() if speed <= 0.4 then return 1 else return 2 end end

print(test())