import lenientops
import nimraylib_now

##  Initialization
## --------------------------------------------------------------------------------------
var screenWidth = 360
var screenHeight = 640
setConfigFlags(ConfigFlags.WINDOW_RESIZABLE)
initWindow(screenWidth, screenHeight, "Run Retry 2")
# Variables
const
  HORIZONTAL_SPEED = 12
  ROTATION_SPEED = 16
  WORLD_SPEED = 500

type
  TransformObj {.bycopy.} = object
    position: Vector2
    rotation: float
    scale: Vector2
  Transform = ref TransformObj

  SpriteObj {.bycopy.} = object
    texture: Texture2D
    anchor: Vector2
  Sprite = ref SpriteObj

  PlayerObj {.bycopy.} = object
    transform: Transform
    sprite: Sprite
  Player = ref PlayerObj

var player: Player = new Player
player.sprite = new Sprite
player.transform = new Transform
player.sprite.texture = loadTexture("resources/player.png")
player.sprite.anchor = (0.5, 0.5)
player.transform.position.y = 200
player.transform.scale = (1.0, 1.0)

var playerTargetPos = Vector2(x: player.transform.position.x, y: player.transform.position.y)
var lastMousePos: Vector2

var camera: Camera2D = Camera2D(target: (0.0, 0.0),
                                offset: (getScreenWidth() * 0.5, getScreenHeight() * 0.5),
                                rotation: 0,
                                zoom: 1.0)

setTargetFPS(60)
##  Set our game to run at 60 frames-per-second
## --------------------------------------------------------------------------------------
##  Main game loop
while not windowShouldClose(): ##  Detect window close button or ESC key
  ##  Update
  ## ----------------------------------------------------------------------------------
  camera.offset = (getScreenWidth() * 0.5, getScreenHeight() * 0.5)
  camera.zoom = min(getScreenWidth() / 1080.0, getScreenHeight() / 1920.0)

  if isMouseButtonPressed(0):
    lastMousePos = getScreenToWorld2D(getMousePosition(), camera)
  elif isMouseButtonDown(0):
    var mpos = getScreenToWorld2D(getMousePosition(), camera)
    playerTargetPos.x += mpos.x - lastMousePos.x
    lastMousePos = mpos
  player.transform.position.x = lerp(player.transform.position.x, playerTargetPos.x, HORIZONTAL_SPEED * getFrameTime())
  player.transform.rotation = lerp(player.transform.rotation, clamp(playerTargetPos.x - player.transform.position.x, -90, 90), ROTATION_SPEED * getFrameTime())
  ## ----------------------------------------------------------------------------------
  ##  Draw
  ## ----------------------------------------------------------------------------------
  beginDrawing:
    clearBackground(Raywhite);
    
    beginMode2D(camera):
      drawTexturePro(player.sprite.texture,
        (0.0, 0.0, player.sprite.texture.width.float, player.sprite.texture.height.float),
        (
          player.transform.position.x.float, 
          player.transform.position.y.float, 
          player.sprite.texture.width.float * player.transform.scale.x, 
          player.sprite.texture.height.float * player.transform.scale.y
        ),
        (
          player.sprite.texture.width.float * player.sprite.anchor.x * player.transform.scale.x, 
          player.sprite.texture.height.float * player.sprite.anchor.y * player.transform.scale.y
        ),
        player.transform.rotation,
        Blue)
    drawFPS(10, 10)
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(player.sprite.texture)
closeWindow()

