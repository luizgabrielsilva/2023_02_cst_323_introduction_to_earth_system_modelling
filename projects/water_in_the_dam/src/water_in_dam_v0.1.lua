--- Model for project Water in the Dam
--- Version 0.1
--- Luiz Gabriel and Thais

myfile = File("waterDam_v_0.1_sim_5.csv") -- Saving Results

WaterInTheDam = Model{
    nInhab = 1e5,           -- number of inhabitants
    energyCons = 10,        -- energy consumption per inhabitant per month [KWh]
    growthRate = 5e-2,      -- rate of energy consumption growth per year
    waterEnergyRatio = 1e2, -- rate of conversion of water to energy [m3/KWh]
    damCap = 5e9,           -- dam capacity [m3]
    waterVol = 5e9,         -- volume of water in the dam - Initial value is waterCap [m3]
    rain = 3.5e9,           -- cumulated volume of rain in the year [m3]

    coeffRainAfter1970 = 1, -- proportion of rain after 1970 - decimal in interval [0, 1]

    finalTime = 60,

    execute = function(model)
        model.waterVol = model.waterVol - 12 * model.nInhab * model.energyCons * model.waterEnergyRatio + model.rain

        if model.waterVol > model.damCap then
            model.waterVol = model.damCap
        elseif model.waterVol < 0 then
            model.waterVol = 0
        end

        myfile:writeLine({model.waterVol})

    end,

    init = function(model)

        model.timer = Timer{
            Event{start=0, action=model},
            Event{start=1, action=function()
                    model.energyCons = model.energyCons * (1 + model.growthRate)
                end
            },
            Event{start=20, period=model.finalTime, action=function()
                    model.rain = model.coeffRainAfter1970 * model.rain
                end
            },
        }


    end
}

--- Used for saving results
env = Environment{
    WaterInTheDam{
        waterEnergyRatio=8e1,
        growthRate=2.5e-2,
        coeffRainAfter1970=5e-1,
    }
}

env:run(70)


--- Used for verifying results
--env = Environment{
--    sim1 = WaterInTheDam{},
--    sim2 = WaterInTheDam{waterEnergyRatio=8e1},
--    sim3 = WaterInTheDam{growthRate=2.5e-2},
--    sim4 = WaterInTheDam{coeffRainAfter1970=5e-1},
--    sim5 = WaterInTheDam{
--        waterEnergyRatio=8e1,
--        growthRate=2.5e-2,
--        coeffRainAfter1970=5e-1
--    }
--}
--
--clean()
--
--chart1 = Chart{
--    target = env,
--    select = {"waterVol"}
--}
--
--chart2 = Chart{
--    target = env,
--    select = {"energyCons"}
--}
--
--env:add(Event{action = chart1})
--env:add(Event{action = chart2})
--
--
--env:run()