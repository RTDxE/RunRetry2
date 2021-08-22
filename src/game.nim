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
  WORLD_SPEED = 1500
  CHUNK_SIZE = 3000

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
    position: Vector2
    size: Vector2
    color: Color
  Obstacle = ref ObstacleObj

  RaceChunkObj {.bycopy.} = object
    width: cint
    pos_y: cint
  RaceChunk = ref RaceChunkObj

var chunks: array[10, RaceChunk]
var prevWidth = 0
for chunk in chunks.mitems:
  chunk = new RaceChunk
  chunk.width = getRandomValue(300, 900)
  while abs(chunk.width - prevWidth) < 100:
    chunk.width = getRandomValue(400, 900)
  prevWidth = chunk.width

var obstaclesCount = 0
var obstacles: array[16, Obstacle]
for obstacle in obstacles.mitems:
  obstacle = new Obstacle
  # obstacle.position.y = -1000 # bugfix?
  obstacle.color = Black

var worldPos = 0.0
var nextSpawnPoint = 1200
const spawnDistance = 500

var currentChunk = 0

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
  var idx = obstaclesCount mod obstacles.len
  inc obstaclesCount
  obstacles[idx].color = Green
  return obstacles[idx]

proc getFreeObstacle(): Obstacle =
  return spawnObstacle()

proc obstaclesUpdate() = 
  if worldPos > nextSpawnPoint:
    nextSpawnPoint += spawnDistance
    var ch = ((worldPos - CHUNK_SIZE / 2 + 2100) / CHUNK_SIZE).int
    ch = ch mod chunks.len
    var cc = (chunks[ch].width / 2).int - 64
    if (cc > 128):
      var obs = getFreeObstacle()
      obs.position = (x: getRandomValue(-cc, cc).float, y: -2000.0)

  for i in 0..<min(obstaclesCount, obstacles.len):
    obstacles[i].position.y += WORLD_SPEED * getFrameTime()

proc update() =
  cameraUpdate()
  checkMouseMovement()
  playerUpdate()
  obstaclesUpdate()

  worldPos += WORLD_SPEED * getFrameTime()
  currentChunk = ((worldPos - CHUNK_SIZE / 2) / CHUNK_SIZE).int

proc draw() =
  beginDrawing:
    clearBackground(Green);
    
    beginMode2D(camera):
      if currentChunk > 0:
        var cc = (currentChunk - 1) mod chunks.len
        drawRectangleGradientV((-chunks[cc].width / 2).int, -(CHUNK_SIZE / 2).int - (currentChunk - 1) * CHUNK_SIZE + worldPos.int, (chunks[cc].width).int, 300, Lightgray, Green)
      drawRectangleGradientV((-chunks[currentChunk mod chunks.len].width / 2).int, -(CHUNK_SIZE / 2).int - (currentChunk) * CHUNK_SIZE + worldPos.int, (chunks[currentChunk mod chunks.len].width).int, 300, Lightgray, Green)
      if true:
        var cc = (currentChunk + 1) mod chunks.len
        drawRectangleGradientV((-chunks[cc].width / 2).int, -(CHUNK_SIZE / 2).int - (currentChunk + 1) * CHUNK_SIZE + worldPos.int, (chunks[cc].width).int, 300, Lightgray, Green)

      drawRectangle(-450, -(CHUNK_SIZE / 2).int + worldPos.int, 900, CHUNK_SIZE, Gray)
      
      if currentChunk > 0:
        var cc = (currentChunk - 1) mod chunks.len
        drawRectangle((-chunks[cc].width / 2).int, -(CHUNK_SIZE / 2).int - (currentChunk) * CHUNK_SIZE + worldPos.int, (chunks[cc].width).int, CHUNK_SIZE, Raywhite)
      drawRectangle((-chunks[currentChunk mod chunks.len].width / 2).int, -(CHUNK_SIZE / 2).int - (currentChunk + 1) * CHUNK_SIZE + worldPos.int, (chunks[currentChunk mod chunks.len].width).int, CHUNK_SIZE, Raywhite)
      if true:
        var cc = (currentChunk + 1) mod chunks.len
        drawRectangle((-chunks[cc].width / 2).int, -(CHUNK_SIZE / 2).int - (currentChunk + 2) * CHUNK_SIZE + worldPos.int, (chunks[cc].width).int, CHUNK_SIZE, Raywhite)

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
      
      for i in 0..<min(obstaclesCount, obstacles.len):
        drawRectangleGradientV(obstacles[i].position.x.int - 64, obstacles[i].position.y.int + 32, 128, 64, Lightgray, Raywhite)
        drawRectanglePro(Rectangle(x: obstacles[i].position.x, y: obstacles[i].position.y - 32,
          width: 128, height: 128), Vector2(x: 64, y: 64), 0, obstacles[i].color)
    drawFPS(10, 10)
    drawText($currentChunk, 10, 40, 15, Black)
    drawText($(worldPos/10).int & "m", 10, 60, 15, Black)

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


