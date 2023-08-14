-- @example Fire in the forest example using  multiple runs repeateated strategy.
if not isLoaded("ca") then
   import("ca")
end

dofile("fire-modified.lua")

Random{seed = 70374981}
import("calibration")

local m = MultipleRuns{
	model = Fire,
	repetition = 50,
	parameters = {
        finalTime=1000,
		empty = Choice{min = 0.4, max = 0.6, step = 0.01},--0.4,
		dim = 50,
        neighborhood = "vonneumann",
        burningStepThreshold = 1,
        burningProbability = 1,
        stepsForEvaluation = 150,
        periodOfEvaluation = 10
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
}


local basePath = "C:\\Users\\PC-INPE\\Documents\\pgser\\2023_02\\2023_02_cst_323_introduction_to_earth_system_modelling\\projects\\fire_in_the_forest\\data\\"
local fileName = "experiment-1-tests-04-06.csv"

file = File(basePath .. fileName) -- resultado de cada uma das simulacoes
file:write(m.output, ";")