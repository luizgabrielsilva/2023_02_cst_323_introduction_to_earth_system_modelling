--- Model for project Water in the Dam
--- Version 1.0

--- Luiz Gabriel and Thais

-- myfile = File("waterDam_v_1.0_sim_1.csv") -- Saving Results


local round = function(a)
    return math.floor(a + 0.5)
end


WaterInTheDam = Model{
    nInhab = 1e5,           -- number of inhabitants
    energyCons = 10,        -- energy consumption per inhabitant per month [KWh]
    growthRate = 5e-2,      -- rate of energy consumption growth per year
    waterEnergyRatio = 1e2, -- rate of conversion of water to energy [m3/KWh]
    damCap = 5e9,           -- dam capacity [m3]
    waterVol = 5e9,         -- volume of water in the dam - Initial value is waterCap [m3]
    rain = 3.5e9,           -- cumulated volume of rain in the year [m3]
    coeffRainAfter1970 = 1, -- proportion of rain after 1970 - decimal in interval [0, 1]
    finalTime = 100,

    execute = function(model)
        model.waterVol = model.waterVol - model.nInhab * model.energyCons * model.waterEnergyRatio + model.seasonRain

        if model.waterVol > model.damCap then
            model.waterVol = model.damCap
        elseif model.waterVol < 0 then
            model.waterVol = 0

        end
        --myfile:writeLine({model.waterVol})
    end,

    init = function(model)

        model.timer = Timer{
            Event{start=1, action=function()
                    model.energyCons = model.energyCons * (1 + model.growthRate)
                end
            },
            Event{start=0, period=1/12, action=function(event)

                    local monthlyRainCoeffs = {
                        1.76e-1,     -- proportion of rain in January
                        1.55e-1,     -- proportion of rain in February
                        1.38e-1,     -- proportion of rain in March
                        5.2e-2,      -- proportion of rain in April
                        4.0e-2,      -- proportion of rain in May
                        3.6e-2,      -- proportion of rain in June
                        2.9e-2,      -- proportion of rain in July
                        1.9e-2,      -- proportion of rain in August
                        5.0e-2,      -- proportion of rain in September
                        7.7e-2,      -- proportion of rain in October
                        8.7e-2,      -- proportion of rain in November
                        1.39e-1,     -- proportion of rain in December
                    }

                    local month = round(((event:getTime() * 12) % 12) + 1)
                    model.seasonRain = monthlyRainCoeffs[month] * model.rain
                end
            },

            Event{start=20, period = model.finalTime, action=function()
                    model.rain = model.coeffRainAfter1970 * model.rain
                end
            },

            Event{period = 1/12, start=0, action = model},
        }

    end
}

--- Used for saving results
env = Environment{
    WaterInTheDam{
--        waterEnergyRatio=8e1,
--        growthRate=2.5e-2,
--        coeffRainAfter1970=5e-1,
    }
}

--env:run()
--
--
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
chart1 = Chart{
    target = env,
    select = {"waterVol"}
}
--
--chart2 = Chart{
--    target = env,
--    select = {"energyCons"}
--}
--
env:add(Event{period=1/12, action = chart1})
--env:add(Event{action = chart2})
--
--
env:run(50)