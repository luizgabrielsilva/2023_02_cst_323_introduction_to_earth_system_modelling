-- @example Fire in the forest example using  multiple runs repeateated strategy.
if not isLoaded("ca") then
   import("ca")
end

Random{seed = 70374981}
import("calibration")

local m = MultipleRuns{
	model = Fire,
	repetition = 50,
	parameters = {
		empty = Choice{min = 0.1, max = 0.9, step = 0.05},--0.4,
		dim = 50
	},
	forest = function(model)
		return model.cs:state().forest or 0
	end,
	burned = function(model)
		return model.cs:state().burned or 0
	end,
    eob = function(model)
        return model.endOfBurning
    end,
--	summary = function(result)
--        local sum = 0
--        local simulation_time = 0
--        local max = -math.huge
--        local min = math.huge
--
--        forEachElement(result.eob, function(_, value)
--           simulation_time = simulation_time + value
--        end)
--
--        simulation_time = simulation_time / #result.eob
--
--        forEachElement(result.forest, function(_, value)
--            sum = sum + value
--
--            if max < value then
--                max = value
--            end
--
--            if min > value then
--                min = value
--            end
--        end)
--
--        return {
--            average = sum / #result.forest,
--            simulation_time = simulation_time,
--            max = max,
--            min = min
--        }
--    end
}


local basePath = "C:\\Users\\PC-INPE\\Documents\\pgser\\2023_02\\2023_02_cst_323_introduction_to_earth_system_modelling\\projects\\fire_in_the_forest\\data\\"
local fileName = "resultado_teste_dim50_rep50_step005.csv"

file = File(basePath .. fileName) -- resultado de cada uma das simulacoes
file:write(m.output, ";")

--file = File("resultado-medias.csv") -- resultado agregado das repeticoes
--file:write(m.summary, ";")

--local sum = 0
--forEachElement(m.output, function(_, value)
--	sum = sum + value.forest
--end)
--
--average = sum / #m.output
--
--print("Average forest in the end of "..#m.output.." simulations: "..average)
--
--m.summary.expected = {}
--forEachElement(m.summary, function(_, result)
--	table.insert(m.summary.expected, result.dim * result.dim * (1-result.empty))
--end)

--c = Chart{
--    target = m.summary,
--    select = {"average", "expected"},
--    xAxis = "empty",
--	color = {"red", "green"}
--}
--
--c:save("resultado.png")
--
--Chart{
--    target = m.summary,
--    select = "simulation_time",
--    xAxis = "empty"
--}
