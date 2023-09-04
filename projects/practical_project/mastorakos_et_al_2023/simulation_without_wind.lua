dofile("fire_v2.lua")

Random{seed = 110989}

Fire{
    delta=1,
    xDim=201,
    yDim=201,
    initialX=100,
    initialY=100,
    finalTime = 120,
    windSpeedX = 0
}:run()