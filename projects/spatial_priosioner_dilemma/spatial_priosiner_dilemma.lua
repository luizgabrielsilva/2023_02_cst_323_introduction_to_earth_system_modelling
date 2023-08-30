Random{seed = 230556}

payOff = {
    cooperative = {cooperative = 1, noncooperative = 0},
    noncooperative = {cooperative = 1.9, noncooperative = 0}
}

spatialPD = Model{
    finalTime = 100,
    dim = 100,
    includeSelf = true,
    neighborhood = "moore",
    propOfCooperatives = 0.9,
    init = function(model)

--------------------------------------------------------------------------------
--- Creating cells, cellular space and neighborhood
--------------------------------------------------------------------------------

        model.cell = Cell{
            state = function(cell)
                local agent = cell:getAgent()
                local status = agent.strategy
                if status == "cooperative" and agent.newstrategy then status = "newcooperative" end
                if status == "noncooperative" and agent.newstrategy then status = "newnoncooperative" end
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
            --strategy = Random{cooperative = model.propOfCooperatives,
            --                  noncooperative = 1 - model.propOfCooperatives},
            strategy = "cooperative",
            newstrategy = false,
            play = function(agent)
                agent.score = 0
                forEachNeighbor(agent:getCell(), function(neighbor)
                    agent.score = agent.score + payOff[agent.strategy][neighbor:getAgent().strategy]
                end)
            end,

            test = function(agent)
                forEachNeighbor(agent:getCell(), function(neighbor)
                    local agentNeighbor = neighbor:getAgent()
                    if agent:getCell().x == 3 and agent:getCell().y == 5 then
                        print(agent:getCell().x, agent:getCell().y, agent.score, agent.strategy,
                              agentNeighbor:getCell().x, agentNeighbor:getCell().y, agentNeighbor.score, agentNeighbor.strategy) end
                end)
            end,


            updateStrategy = function(agent)
                local bestScore = agent.score
                local bestStrategy = agent.strategy


                forEachNeighbor(agent:getCell(), function(neighbor)
                    local agentNeighbor = neighbor:getAgent()

                    if agentNeighbor.score > bestScore then


                        if agent:getCell().x == 3 and agent:getCell().y == 5 then
                            print("CANDIDATE:", agentNeighbor:getCell().x,agentNeighbor:getCell().y, agentNeighbor.score, agentNeighbor.strategy, agentNeighbor.newstrategy) end


                        bestScore = agentNeighbor.score
                        --if agentNeighbor.newstrategy then
                        --    if agentNeighbor.strategy == "cooperative" then bestStrategy = "noncooperative"
                        --    else bestStrategy = "cooperative" end
                        --end

                        bestStrategy = agentNeighbor.strategy
                    end
                end)



                if bestStrategy ~= agent.strategy then

                    agent.strategy = bestStrategy
                    agent.newstrategy = true
                else
                    agent.newstrategy = false
                end

                if agent:getCell().x == 3 and agent:getCell().y == 5 then
                    print(agent:getCell().x, agent:getCell().y, agent.score, agent.strategy, agent.newstrategy,
                          bestScore, bestStrategy) end

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
        model.cs:get(5, 5):getAgent().strategy = "noncooperative"

--------------------------------------------------------------------------------
--- Creating map
--------------------------------------------------------------------------------

        model.map = Map{
            target = model.cs,
            select = "state",
            value = {"cooperative", "noncooperative",
                     "newcooperative", "newnoncooperative"},
            color = {"blue", "red", "yellow", "green"},
            grid = true
        }

        model.chart = Chart{
            target = model.society,
            select = "strategy",
            value = {"cooperative"}
        }

--------------------------------------------------------------------------------
--- Creating timer
--------------------------------------------------------------------------------

        model.timer = Timer{
            Event{action=model.map},
            Event{action=model.chart},
            Event{action=function()
                model.society:play()
                model.society:test()
                model.society:updateStrategy()
            end}
        }

    end

}

spatialPD{dim = 11, finalTime=3}:run()