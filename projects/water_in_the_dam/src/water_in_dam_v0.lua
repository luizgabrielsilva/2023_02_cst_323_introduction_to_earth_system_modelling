--- Model for project Water in the Dam
--- Luiz Gabriel and Thais


WaterInTheDam = Model{
    initialYear = 1950,
    inhabitants = 1e5,
    inhabitantEnergyConsumption = 10,
    energyConsumptionGrowthRate = 0.05,
    energyProductionEfficiency = 1e2,
    damCapacity = 5e9,
    damWaterVolume = 5e9,
    finalTime = 100,

    execute = function(model)
        model.damWaterVolume = model.damWaterVolume - 12 * model.inhabitants * model.inhabitantEnergyConsumption * model.energyProductionEfficiency + 3.5e9

        if model.damWaterVolume > model.damCapacity then
            model.damWaterVolume = model.damCapacity
        elseif model.damWaterVolume < 0 then
            model.damWaterVolume = 0

            end

        model.inhabitantEnergyConsumption = model.inhabitantEnergyConsumption * (1 + model.energyConsumptionGrowthRate)

    end,

    init = function(model)
        --model.chart = Chart{
        --    target = model,
        --    select = "damWaterVolume"
        --}

        model.timer = Timer{
            Event{time = 1950, action = model},

        --    Event{action = model.chart}
        }

    end
}



env = Environment{
    sim1 = WaterInTheDam{},
    sim2 = WaterInTheDam{energyConsumptionGrowthRate=0.025},
    --sim3 = WaterInTheDam{energyProductionEfficiency=8e1},
    --sim4 = WaterInTheDam{
    --    energyProductionEfficiency=8e1,
    --    energyConsumptionGrowthRate=0.025
    --}
}

clean()

chart1 = Chart{
    target = env,
    select = {"damWaterVolume"}
}

chart2 = Chart{
    target = env,
    select = {"inhabitantEnergyConsumption"}
}

env:add(Event{action = chart1})
env:add(Event{action = chart2})


env:run(60)