dofile("fire-modified.lua")


Random{seed = 60374981}

Fire{finalTime=100, dim=50, burningStepThreshold=1, burningProbability=1, empty=0.37}:run()
