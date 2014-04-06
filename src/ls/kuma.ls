class Kuma
  @@create-kumaclips = (path) ->
    texture = PIXI.BaseTexture.fromImage path
    dim = width: 24 height: 32
    bases =
      down:  0
      right: 96
      up:    192
      left:  288
    clips =
      stand: {}
      walk: {}
      hoe: {}
    hoe = new PIXI.MovieClip [new PIXI.Texture texture, {x: 384  y: 0} <<< dim]
    hoe.animationSpeed = 0.5
    for key, base of bases
      clips.stand[key] = new PIXI.MovieClip [new PIXI.Texture texture, {x: base + 24   y: 0 } <<< dim]
      clips.stand[key].animationSpeed = 0.5
      mcs = for i from 0 til 4
        new PIXI.Texture texture, {x: base + i * 24  y: 0} <<< dim
      clips.walk[key] = new PIXI.MovieClip mcs
      clips.walk[key].animationSpeed = 0.5
      clips.hoe[key] = hoe
    clips
  @@sprites = []
  @@create-random = ->
    spritesheet = @@sprites[~~(Math.random! * *)]
    new Kuma Kuma.create-kumaclips spritesheet
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
        x: -2 y: 0
      right:
        x: 2  y: 0
      up:
        x: 0  y: -1
      down:
        x: 0  y: 1
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
