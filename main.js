/**
 * Copyright (c) 2014, caasi Huang <caasi.igd@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 **/
(function(){
  var script, scriptParser, current, i, branch, talk, x$, y$, ref$, Kuma, $win, config, dimension, computePosScale, loader;
  script = {
    caasi: [
      {
        dialog: 'Hello.',
        response: function(){
          var this$ = this;
          console.log('Hi, I am...');
          return setTimeout(function(){
            console.log('caasi.');
            return this$.done();
          }, 2000);
        },
        children: [{
          dialog: 'Bye.',
          response: function(done){
            console.log('Bye!');
            return done();
          }
        }]
      }, {
        dialog: 'Bye.'
      }
    ]
  };
  scriptParser = function(script){
    var i$, len$, results$ = [];
    script == null && (script = []);
    for (i$ = 0, len$ = script.length; i$ < len$; ++i$) {
      results$.push((fn$.call(this, script[i$])));
    }
    return results$;
    function fn$(branch){
      return {
        dialog: branch.dialog,
        execute: function(){
          var dialogs;
          dialogs = scriptParser(branch.children);
          return new Promise(function(resolve, reject){
            var context;
            if (branch.response) {
              context = {
                done: function(){
                  resolve(dialogs);
                }
              };
              return branch.response.call(context, context.done);
            } else {
              return resolve(dialogs);
            }
          });
        }
      };
    }
  };
  script.caasi = scriptParser(script.caasi);
  current = script.caasi;
  for (i in current) {
    branch = current[i];
    console.log(i + ". " + branch.dialog);
  }
  talk = function(index){
    if (index < 0 || current.length <= index) {
      return;
    }
    console.log("> " + current[index].dialog);
    current[index].execute().then(function(it){
      var i, branch, results$ = [];
      current = it;
      for (i in it) {
        branch = it[i];
        results$.push(console.log(i + ". " + branch.dialog));
      }
      return results$;
    });
  };
  x$ = window;
  y$ = (ref$ = x$.P) != null
    ? ref$
    : x$.P = {};
  y$.ActorManager == null && (y$.ActorManager = {
    get: function(){
      return console.log('foo');
    },
    talk: talk
  });
  Kuma = (function(){
    Kuma.displayName = 'Kuma';
    var prototype = Kuma.prototype, constructor = Kuma;
    constructor.createKumaclips = function(path){
      var texture, dim, bases, clips, hoe, key, base, mcs, res$, i$, i;
      texture = PIXI.BaseTexture.fromImage(path);
      dim = {
        width: 24,
        height: 32
      };
      bases = {
        down: 0,
        right: 96,
        up: 192,
        left: 288
      };
      clips = {
        stand: {},
        walk: {},
        hoe: {}
      };
      hoe = new PIXI.MovieClip([new PIXI.Texture(texture, import$({
        x: 384,
        y: 0
      }, dim))]);
      hoe.animationSpeed = 0.5;
      for (key in bases) {
        base = bases[key];
        clips.stand[key] = new PIXI.MovieClip([new PIXI.Texture(texture, import$({
          x: base + 24,
          y: 0
        }, dim))]);
        clips.stand[key].animationSpeed = 0.5;
        res$ = [];
        for (i$ = 0; i$ < 4; ++i$) {
          i = i$;
          res$.push(new PIXI.Texture(texture, import$({
            x: base + i * 24,
            y: 0
          }, dim)));
        }
        mcs = res$;
        clips.walk[key] = new PIXI.MovieClip(mcs);
        clips.walk[key].animationSpeed = 0.5;
        clips.hoe[key] = hoe;
      }
      return clips;
    };
    constructor.sprites = [];
    constructor.createRandom = function(){
      var spritesheet, ref$;
      spritesheet = (ref$ = constructor.sprites)[~~(Math.random() * ref$.length)];
      return new Kuma(Kuma.createKumaclips(spritesheet));
    };
    function Kuma(movieclips){
      this.movieclips = movieclips;
      this.sprite = new PIXI.DisplayObjectContainer;
      this.stance = 'stand';
      this.facing = 'down';
      this.currentClip = this.movieclips[this.stance][this.facing];
      this.sprite.addChild(this.currentClip);
      this.status = {
        stance: this.stance,
        facing: this.facing
      };
      this.speed = {
        left: {
          x: -2,
          y: 0
        },
        right: {
          x: 2,
          y: 0
        },
        up: {
          x: 0,
          y: -1
        },
        down: {
          x: 0,
          y: 1
        }
      };
    }
    prototype.update = function(){
      var x$, y$;
      if (this.status.stance !== this.stance || this.status.facing !== this.facing) {
        this.currentClip.stop();
        this.sprite.removeChild(this.currentClip);
        this.currentClip = this.movieclips[this.stance][this.facing];
        this.currentClip.play();
        this.sprite.addChild(this.currentClip);
        x$ = this.status;
        x$.stance = this.stance;
        x$.facing = this.facing;
      }
      if (this.status.stance === 'walk') {
        y$ = this.sprite;
        y$.x += this.speed[this.status.facing].x;
        y$.y += this.speed[this.status.facing].y;
        return y$;
      }
    };
    return Kuma;
  }());
  $win = $(window);
  config = {
    width: 160,
    height: 120,
    path: {
      image: './img'
    }
  };
  dimension = function(){
    return {
      w: $win.width(),
      h: $win.height()
    };
  };
  computePosScale = function(dim){
    var ratio, s;
    ratio = {
      w: dim.w / config.width,
      h: dim.h / config.height
    };
    s = Math.min(ratio.w, ratio.h);
    return {
      scale: {
        x: s,
        y: s
      },
      offset: {
        x: (dim.w - config.width * s) / 2,
        y: (dim.h - config.height * s) / 2
      }
    };
  };
  PIXI.scaleModes.DEFAULT = PIXI.scaleModes.NEARST;
  loader = new PIXI.AssetLoader([config.path.image + "/gerbera_sprites.png", config.path.image + "/char1_sprites.png", config.path.image + "/char2_sprites.png", config.path.image + "/char3_sprites.png", config.path.image + "/char4_sprites.png"]);
  loader.addEventListener('onComplete', function(){
    var stage, dim, setting, x$, gameStage, y$, kuma, renderer, z$, animate;
    stage = new PIXI.Stage(0x000000);
    dim = dimension();
    setting = computePosScale(dim);
    x$ = gameStage = new PIXI.Graphics;
    x$.beginFill(0xff9900);
    x$.drawRect(0, 0, config.width, config.height);
    x$.endFill();
    x$.position = setting.offset;
    x$.scale = setting.scale;
    stage.addChild(gameStage);
    y$ = Kuma.sprites;
    y$.push(config.path.image + "/char1_sprites.png");
    y$.push(config.path.image + "/char2_sprites.png");
    y$.push(config.path.image + "/char3_sprites.png");
    y$.push(config.path.image + "/char4_sprites.png");
    kuma = Kuma.createRandom();
    gameStage.addChild(kuma.sprite);
    renderer = PIXI.autoDetectRenderer($win.width(), $win.height());
    renderer.view.className = 'rendererView';
    $('body').append(renderer.view);
    z$ = $win;
    z$.resize(function(){
      var dim, setting, x$;
      dim = dimension();
      setting = computePosScale(dim);
      renderer.resize(dim.w, dim.h);
      x$ = gameStage;
      x$.position = setting.offset;
      x$.scale = setting.scale;
    });
    z$.keydown(function(e){
      var facing;
      facing = {
        '37': 'left',
        '38': 'up',
        '39': 'right',
        '40': 'down'
      };
      switch (e.which) {
      case 37:
      case 38:
      case 39:
      case 40:
        kuma.stance = 'walk';
        kuma.facing = facing[e.which];
      }
    });
    z$.keyup(function(e){
      switch (e.which) {
      case 37:
      case 38:
      case 39:
      case 40:
        kuma.stance = 'stand';
      }
    });
    animate = function(){
      kuma.update();
      requestAnimationFrame(animate);
      renderer.render(stage);
    };
    return requestAnimationFrame(animate);
  });
  loader.load();
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
