dofile("fire_v2.lua")

Random{seed = 110989}

Fire{
    finalTime = 140,
    yDim=61,
    xDim=101,
    initialY = 30,
    initialX = 1,
    deltaT=1.15,
    windDecayRate=30,

}:run()
