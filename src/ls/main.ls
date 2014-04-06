$win   = $ window
config =
  width:  160
  height: 120
  path:
    image: './img'

dimension = ->
  w: $win.width!
  h: $win.height!

compute-pos-scale = (dim) ->
  ratio =
    w: dim.w / config.width
    h: dim.h / config.height
  s = Math.min ratio.w, ratio.h
  scale:
    x: s
    y: s
  offset:
    x: (dim.w - config.width  * s) / 2
    y: (dim.h - config.height * s) / 2

# setup stage and engine
PIXI.scaleModes.DEFAULT = PIXI.scaleModes.NEARST

# preload images
loader = new PIXI.AssetLoader [
  "#{config.path.image}/template_gerbera.png"
  "#{config.path.image}/char1.png"
  "#{config.path.image}/char2.png"
  "#{config.path.image}/char3.png"
  "#{config.path.image}/char4.png"
]

loader.addEventListener \onComplete ->
  stage = new PIXI.Stage 0x000000

  dim = dimension!
  setting = compute-pos-scale dim
  game-stage = new PIXI.Graphics
    ..beginFill 0xff9900
    ..drawRect 0 0 config.width, config.height
    ..endFill!
    ..position = setting.offset
    ..scale    = setting.scale
  stage.addChild game-stage

  # sprites
  Kuma.sprites
    ..push "#{config.path.image}/char1.png"
    ..push "#{config.path.image}/char2.png"
    ..push "#{config.path.image}/char3.png"
    ..push "#{config.path.image}/char4.png"
  kuma = Kuma.create-random!
  game-stage.addChild kuma.sprite

  # resize and render
  renderer = PIXI.autoDetectRenderer $win.width!, $win.height!
  renderer.view.className = \rendererView
  $(\body).append renderer.view

  $win
    ..resize !->
      dim = dimension!
      setting = compute-pos-scale dim
      renderer.resize dim.w, dim.h
      game-stage
        ..position = setting.offset
        ..scale    = setting.scale
    # a lame solution
    ..keydown (e) !->
      facing =
        '37': \left
        '38': \up
        '39': \right
        '40': \down
      switch e.which
      | 37, 38, 39, 40 =>
        kuma.stance = \walk
        kuma.facing = facing[e.which]
    ..keyup (e) !->
      switch e.which
      | 37, 38, 39, 40 => kuma.stance = \stand

  animate = !->
    kuma.update!
    requestAnimationFrame animate
    renderer.render stage
  requestAnimationFrame animate
loader.load!
