$win   = $ window
config =
  width:  160
  height: 120
  path:
    image: './img/'

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
  "#{config.path.image}char1.png"
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
  sprite-kuma = PIXI.BaseTexture.fromImage "#{config.path.image}char1.png"
  dim = width: 24 height: 32
  kuma =
    stand:
      down:   new PIXI.MovieClip [new PIXI.Texture sprite-kuma, {x: 24  y: 0 } <<< dim]
      up:     new PIXI.MovieClip [new PIXI.Texture sprite-kuma, {x: 24  y: 64} <<< dim]
      left:   new PIXI.MovieClip [new PIXI.Texture sprite-kuma, {x: 24  y: 32} <<< dim]
      right:  new PIXI.MovieClip [new PIXI.Texture sprite-kuma, {x: 24  y: 32} <<< dim]
    walk:
      down:   new PIXI.MovieClip do
                * new PIXI.Texture sprite-kuma, {x: 0  y: 0} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 24 y: 0} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 48 y: 0} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 24 y: 0} <<< dim
      up:     new PIXI.MovieClip do
                * new PIXI.Texture sprite-kuma, {x: 0  y: 64} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 24 y: 64} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 48 y: 64} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 24 y: 64} <<< dim
      left:   new PIXI.MovieClip do
                * new PIXI.Texture sprite-kuma, {x: 0  y: 32} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 24 y: 32} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 48 y: 32} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 24 y: 32} <<< dim
      right:  new PIXI.MovieClip do
                * new PIXI.Texture sprite-kuma, {x: 0  y: 32} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 24 y: 32} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 48 y: 32} <<< dim
                  new PIXI.Texture sprite-kuma, {x: 24 y: 32} <<< dim
  hoe = new PIXI.MovieClip [new PIXI.Texture sprite-kuma, {x: 96  y: 0} <<< dim]
  kuma.hoe =
    down:   hoe
    up:     hoe
    left:   hoe
    right:  hoe
  kuma.stand.left.scale.x = -1
  kuma.walk.left.scale.x = -1
  kuma.walk.down.play!
  game-stage.addChild kuma.walk.down

  # resize and render
  renderer = PIXI.autoDetectRenderer $win.width!, $win.height!
  renderer.view.className = \rendererView
  $(\body).append renderer.view

  $(window).resize !->
    dim = dimension!
    setting = compute-pos-scale dim
    renderer.resize dim.w, dim.h
    game-stage
      ..position = setting.offset
      ..scale    = setting.scale

  animate = !->
    requestAnimationFrame animate
    renderer.render stage
  requestAnimationFrame animate
loader.load!
