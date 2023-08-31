Random{seed = 230556}

payOff = {
    cooperate = {cooperate = 1, noncooperate = 0},
    noncooperate = {cooperate = 1.88, noncooperate = 0}
}

spatialPD = Model{
    finalTime = 100,
    dim = 101,
    includeSelf = true,
    neighborhood = "moore",
    propOfCooperate = 0.9,
    init = function(model)

--------------------------------------------------------------------------------
--- Creating cells, cellular space and neighborhood
--------------------------------------------------------------------------------

        model.cell = Cell{
            state = function(cell)
                local agent = cell:getAgent()
                local status = agent.strategy
                if status == "cooperate" and agent.newstrategy then status = "newcooperate" end
                if status == "noncooperate" and agent.newstrategy then status = "newnoncooperate" end
                return status
            end
        }

        model.cs = CellularSpace{
            instance = model.cell,
            xdim = model.dim
        }

        model.cs:createNeighborhood{strategy = model.neighborhood,
                                    self = model.includeSelf}


--------------------------------------------------------------------------------
--- Creating agent and society
--------------------------------------------------------------------------------

        model.agent = Agent{
            strategy = "cooperate",
            --strategy = Random{cooperate = model.propOfCooperate,
            --                  noncooperate = 1 - model.propOfCooperate},
            newstrategy = false,
            result = nil,
            play = function(agent)
                agent.score = 0
                forEachNeighbor(agent:getCell(), function(neighbor)
                    agent.score = agent.score + payOff[agent.strategy][neighbor:getAgent().strategy]
                end)
            end,

            getResults = function(agent)

                local bestScore = agent.score
                local bestStrategy = agent.strategy

                forEachNeighbor(agent:getCell(), function(neighbor)
                    local agentNeighbor = neighbor:getAgent()

                    if agentNeighbor.score > bestScore then
                        bestScore = agentNeighbor.score
                        bestStrategy = agentNeighbor.strategy
                    end
                end)

                agent.result = bestStrategy
            end,

            updateStrategy = function(agent)
                if agent.result ~= agent.strategy then
                    agent.strategy = agent.result
                    agent.newstrategy = true
                else
                    agent.newstrategy = false
                end
            end
        }

        model.society = Society{
            instance = model.agent,
            quantity = model.dim ^ 2
        }

        model.env = Environment{
            model.cs,
            model.society,
        }

        model.env:createPlacement{strategy = "uniform"}

        local middle = math.floor(model.dim / 2)
        model.cs:get(middle, middle):getAgent().strategy = "noncooperate"

--------------------------------------------------------------------------------
--- Creating map
--------------------------------------------------------------------------------

        model.map = Map{
            target = model.cs,
            select = "state",
            value = {"cooperate", "noncooperate",
                     "newcooperate", "newnoncooperate"},
            color = {"blue", "red", "yellow", "green"},
            grid = true
        }

        model.chart = Chart{
            target = model.society,
            select = "strategy",
            value = {"cooperate"}
        }

--------------------------------------------------------------------------------
--- Creating timer
--------------------------------------------------------------------------------

        model.timer = Timer{
            Event{action=model.map},
            Event{action=model.chart},
            Event{action=function()
                model.society:play()
                model.society:getResults()
                model.society:updateStrategy()
            end}
        }

    end

}

spatialPD{}:run()