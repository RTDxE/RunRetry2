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
  HORIZONTAL_SPEED = 10
  ROTATION_SPEED = 8
  WORLD_SPEED = 1000

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

  ObstacleObj {.bycopy.} = object
    transform: Transform
    color: Color
  Obstacle = ref ObstacleObj

var obstacles: array[32, Obstacle]
for obstacle in obstacles.mitems:
  obstacle = new Obstacle
  obstacle.transform = new Transform
  obstacle.transform.position.y = -1000 # bugfix?
  obstacle.color = Black
var obstaclesCount = 0
var spawnTime = 0.8
var currentSpawnTime = 0.0

var worldPos = 0

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

proc cameraUpdate() =
  camera.offset = (getScreenWidth() * 0.5, getScreenHeight() * 0.5)
  camera.zoom = min(getScreenWidth() / 1080.0, getScreenHeight() / 1920.0)

proc checkMouseMovement() =
  if isMouseButtonPressed(0):
    lastMousePos = getScreenToWorld2D(getMousePosition(), camera)
  elif isMouseButtonDown(0):
    var mpos = getScreenToWorld2D(getMousePosition(), camera)
    playerTargetPos.x += mpos.x - lastMousePos.x
    lastMousePos = mpos

proc playerUpdate() = 
  player.transform.position.x = lerp(
    player.transform.position.x, 
    playerTargetPos.x, 
    HORIZONTAL_SPEED * getFrameTime()
  )
  player.transform.rotation = lerp(
    player.transform.rotation, 
    clamp(
      (playerTargetPos.x - player.transform.position.x) / 2, 
      -60, 60
    ), 
    ROTATION_SPEED * getFrameTime()
  )

proc spawnObstacle(): Obstacle =
  
  if obstaclesCount < obstacles.len - 1:
    inc obstaclesCount
    obstacles[obstaclesCount].color = Black
  return obstacles[obstaclesCount]

proc getFreeObstacle(): Obstacle =
  return spawnObstacle()

proc obstaclesUpdate() = 
  if currentSpawnTime > spawnTime:
    currentSpawnTime -= spawnTime
    var obs = getFreeObstacle()
    obs.transform.position = (x: getRandomValue(-400, 400).float, y: -1000.0)
  
  currentSpawnTime += getFrameTime()

  for i in 0..<obstaclesCount:
    obstacles[i].transform.position.y += WORLD_SPEED * getFrameTime()

proc update() =
  cameraUpdate()
  checkMouseMovement()
  playerUpdate()
  obstaclesUpdate()

  worldPos += (WORLD_SPEED * getFrameTime()).cint

proc draw() =
  beginDrawing:
    clearBackground(Green);
    
    beginMode2D(camera):
      drawRectangle(-450, -2000 + worldPos, 900, 4000, Raywhite)
      drawRectangle(-300, -6000 + worldPos, 600, 4000, Raywhite)
      drawRectangle(-450, -10000 + worldPos, 900, 4000, Raywhite)
      drawRectangle(-300, -14000 + worldPos, 600, 4000, Raywhite)

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
      
      for i in 0..<obstaclesCount:
        drawRectanglePro(Rectangle(x: obstacles[i].transform.position.x, y: obstacles[i].transform.position.y,
          width: 128, height: 128), Vector2(x: 64, y: 64), 0, obstacles[i].color)
    drawFPS(10, 10)

proc gameLoop() {.cdecl.} =
  update()
  draw()

when defined(emscripten):
  emscriptenSetMainLoop(gameLoop, 0, 1)
else:
  while not windowShouldClose():
    gameLoop()
## ----------------------------------------------------------------------------------
##  De-Initialization
## --------------------------------------------------------------------------------------
unloadTexture(player.sprite.texture)
closeWindow()


