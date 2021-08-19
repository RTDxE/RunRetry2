import lenientops
import nimraylib_now

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
setConfigFlags(ConfigFlags.WINDOW_RESIZABLE)
initWindow(screenWidth, screenHeight, "Run Retry 2")
setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing:
    drawFPS(10, 10)
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------

closeWindow()

