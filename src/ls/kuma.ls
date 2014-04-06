class Kuma
  @@create-kumaclips = (path) ->
    texture = PIXI.BaseTexture.fromImage path
    dim = width: 24 height: 32
    clips =
      stand:
        down:   new PIXI.MovieClip [new PIXI.Texture texture, {x: 24  y: 0 } <<< dim]
        up:     new PIXI.MovieClip [new PIXI.Texture texture, {x: 24  y: 64} <<< dim]
        left:   new PIXI.MovieClip [new PIXI.Texture texture, {x: 24  y: 32} <<< dim]
        right:  new PIXI.MovieClip [new PIXI.Texture texture, {x: 24  y: 32} <<< dim]
      walk:
        down:   new PIXI.MovieClip do
                * new PIXI.Texture texture, {x: 0  y: 0} <<< dim
                  new PIXI.Texture texture, {x: 24 y: 0} <<< dim
                  new PIXI.Texture texture, {x: 48 y: 0} <<< dim
                  new PIXI.Texture texture, {x: 24 y: 0} <<< dim
        up:     new PIXI.MovieClip do
                * new PIXI.Texture texture, {x: 0  y: 64} <<< dim
                  new PIXI.Texture texture, {x: 24 y: 64} <<< dim
                  new PIXI.Texture texture, {x: 48 y: 64} <<< dim
                  new PIXI.Texture texture, {x: 24 y: 64} <<< dim
        left:   new PIXI.MovieClip do
                * new PIXI.Texture texture, {x: 0  y: 32} <<< dim
                  new PIXI.Texture texture, {x: 24 y: 32} <<< dim
                  new PIXI.Texture texture, {x: 48 y: 32} <<< dim
                  new PIXI.Texture texture, {x: 24 y: 32} <<< dim
        right:  new PIXI.MovieClip do
                * new PIXI.Texture texture, {x: 0  y: 32} <<< dim
                  new PIXI.Texture texture, {x: 24 y: 32} <<< dim
                  new PIXI.Texture texture, {x: 48 y: 32} <<< dim
                  new PIXI.Texture texture, {x: 24 y: 32} <<< dim
    hoe = new PIXI.MovieClip [new PIXI.Texture texture, {x: 72  y: 0} <<< dim]
    clips
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
        x: -4 y: 0
      right:
        x: 4  y: 0
      up:
        x: 0  y: -2
      down:
        x: 0  y: 2
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
