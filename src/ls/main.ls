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
  mc-kuma =
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
  hoe = new PIXI.MovieClip [new PIXI.Texture sprite-kuma, {x: 72  y: 0} <<< dim]
  mc-kuma
    ..hoe =
      down:   hoe
      up:     hoe
      left:   hoe
      right:  hoe
    ..stand.left
      ..x = dim.width
      ..scale.x = -1
    ..walk.left
      ..x = dim.width
      ..scale.x = -1
  class Kuma
    (@movieclips) ->
      @sprite = new PIXI.DisplayObjectContainer
      @stance = \stand
      @facing = \down
      @current-clip = @movieclips[@stance][@facing]
      @sprite.addChild @current-clip
      @status =
        stance: @stance
        facing: @facing
      @speed =
        left:
          x: -4
          y: 0
        right:
          x: 4
          y: 0
        up:
          x: 0
          y: -2
        down:
          x: 0
          y: 2
    update: ->
      if @status.stance isnt @stance or @status.facing isnt @facing
        @current-clip.stop!
        @sprite.removeChild @current-clip
        @current-clip = @movieclips[@stance][@facing]
        @current-clip.play!
        @sprite.addChild @current-clip
        @status
          ..stance = @stance
          ..facing = @facing
      if @status.stance is \walk
        @sprite
          ..x += @speed[@status.facing].x
          ..y += @speed[@status.facing].y
  kuma = new Kuma mc-kuma
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
