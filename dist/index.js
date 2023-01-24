(function(){
  var parent, ldcover;
  parent = function(r, s, e){
    var n;
    e == null && (e = document);
    n = r;
    while (n && n !== e) {
      n = n.parentNode;
    }
    if (n !== e) {
      return null;
    }
    n = r;
    while (n && n !== e && n.matches && !n.matches(s)) {
      n = n.parentNode;
    }
    if (n === e && (!e.matches || !e.matches(s))) {
      return null;
    }
    return n;
  };
  ldcover = function(opt){
    var ret;
    opt == null && (opt = {});
    this.evtHandler = {};
    this.opt = import$({
      delay: 300,
      autoZ: true,
      baseZ: 3000,
      escape: true,
      byDisplay: true
    }, opt);
    if (opt.zmgr) {
      this.zmgr(opt.zmgr);
    }
    this.promises = [];
    this._r = !opt.root
      ? (ret = document.createElement("div"), ret.innerHTML = "<div class=\"base\"></div>", ret)
      : typeof opt.root === 'string'
        ? document.querySelector(opt.root)
        : opt.root;
    this.cls = typeof opt.type === 'string'
      ? opt.type.split(' ')
      : opt.type;
    this.resident = opt.resident != null ? opt.resident : false;
    this.inPlace = opt.inPlace != null ? opt.inPlace : true;
    this.container = typeof opt.container === 'string'
      ? document.querySelector(opt.container)
      : opt.container;
    if (!(this._r.content && this._r.content.nodeType === Element.DOCUMENT_FRAGMENT_NODE)) {
      this.init();
    }
    return this;
  };
  ldcover.prototype = import$(Object.create(Object.prototype), {
    root: function(){
      if (!this.inited) {
        this.init();
      }
      return this._r;
    },
    init: function(){
      var that, clicksrc, this$ = this;
      if (this.inited) {
        return;
      }
      this.inited = true;
      if (!this.inPlace) {
        this._r.parentNode.removeChild(this._r);
        document.body.appendChild(this._r);
      }
      if (!this.resident && this._r.parentNode) {
        this._c = document.createComment(" ldcover placeholder ");
        this._r.parentNode.insertBefore(this._c, this._r);
        this._r.parentNode.removeChild(this._r);
      }
      if (this._r.content && this._r.content.nodeType === Element.DOCUMENT_FRAGMENT_NODE) {
        this._r = this._r.content.cloneNode(true).childNodes[0];
        this._r.parentNode.removeChild(this._r);
      }
      if (that = this._r.getAttribute('data-lock')) {
        if (that === 'true') {
          this.opt.lock = true;
        }
      }
      this.inner = this._r.querySelector('.inner');
      this.base = this._r.querySelector('.base');
      this._r.classList.add.apply(this._r.classList, ['ldcv'].concat(this.cls || []));
      if (this.opt.byDisplay) {
        this._r.style.display = 'none';
      }
      clicksrc = null;
      this._r.addEventListener('mousedown', this.el_md = function(e){
        return clicksrc = e.target;
      });
      return this._r.addEventListener('click', this.el_c = function(e){
        var tgt, action;
        if (clicksrc === this$._r && !this$.opt.lock) {
          e.stopPropagation();
          return this$.toggle(false);
        }
        if (parent(e.target, '*[data-ldcv-cancel]', this$._r)) {
          e.stopPropagation();
          return this$.cancel();
        }
        tgt = parent(e.target, '*[data-ldcv-set]', this$._r);
        if (tgt && (action = tgt.getAttribute("data-ldcv-set")) != null) {
          if (!parent(tgt, '.disabled', this$._r)) {
            e.stopPropagation();
            return this$.set(action);
          }
        }
      });
    },
    zmgr: function(it){
      if (it != null) {
        return this._zmgr = it;
      } else {
        return this._zmgr;
      }
    },
    append: function(it){
      var base;
      base = this._r.childNodes[0];
      return (base && base.classList.contains('base')
        ? base
        : this._r).appendChild(it);
    },
    get: function(p){
      var this$ = this;
      return new Promise(function(res, rej){
        this$.promises.push({
          res: res,
          rej: rej
        });
        return this$.toggle(true, p);
      });
    },
    cancel: function(err, hide){
      hide == null && (hide = true);
      this.promises.splice(0).map(function(p){
        var ref$;
        return p.rej(err || (ref$ = new Error(), ref$.name = 'lderror', ref$.id = 999, ref$));
      });
      if (hide) {
        return this.toggle(false);
      }
    },
    set: function(v, hide){
      hide == null && (hide = true);
      this.promises.splice(0).map(function(p){
        return p.res(v);
      });
      if (hide) {
        return this.toggle(false);
      }
    },
    isOn: function(){
      return this._r.classList.contains('active');
    },
    lock: function(){
      return this.opt.lock = true;
    },
    toggle: function(v, p){
      var this$ = this;
      return new Promise(function(res, rej){
        var isActive;
        if (!this$.inited) {
          this$.init();
        }
        if (v && p != null) {
          this$.fire('data', p);
        }
        if (!(v != null) && this$._r.classList.contains('running')) {
          return res();
        }
        if (v != null && this$._r.classList.contains('active') === !!v) {
          return res();
        }
        isActive = v != null
          ? v
          : !this$._r.classList.contains('active');
        if (isActive && !this$._r.parentNode) {
          if (!(this$.container != null) && this$._c && this$._c.parentNode) {
            this$._c.parentNode.insertBefore(this$._r, this$._c);
          } else {
            (this$.container || document.body).appendChild(this$._r);
          }
        }
        this$._r.classList.add('running');
        if (this$.opt.byDisplay) {
          this$._r.style.display = 'block';
        }
        if (this$._r.classList.contains('inline')) {
          if (isActive) {
            this$.el_h = function(e){
              if (this$._r.contains(e.target)) {} else {
                return this$.toggle(false);
              }
            };
            window.addEventListener('click', this$.el_h);
          } else if (this$.el_h) {
            window.removeEventListener('click', this$.el_h);
            this$.el_h = null;
          }
        }
        if (!isActive && this$.el_esc) {
          document.removeEventListener('keyup', this$.el_esc);
          this$.el_esc = null;
        }
        return setTimeout(function(){
          var idx;
          this$._r.classList.toggle('active', isActive);
          if (!this$.opt.lock && this$.opt.escape && isActive && !this$.el_esc) {
            this$.el_esc = function(e){
              var ref$;
              if (e.keyCode === 27) {
                if ((ref$ = ldcover.popups)[ref$.length - 1] === this$) {
                  return this$.toggle(false);
                }
              }
            };
            document.addEventListener('keyup', this$.el_esc);
          }
          if (this$.opt.animation && this$.inner) {
            this$.inner.classList[isActive ? 'add' : 'remove'].apply(this$.inner.classList, this$.opt.animation.split(' '));
          }
          if (isActive) {
            ldcover.popups.push(this$);
          } else {
            idx = ldcover.popups.indexOf(this$);
            if (idx >= 0) {
              ldcover.popups.splice(idx, 1);
            }
          }
          if (this$.opt.autoZ) {
            if (isActive) {
              this$._r.style.zIndex = this$.z = (this$._zmgr || ldcover._zmgr).add(this$.opt.baseZ);
            } else {
              (this$._zmgr || ldcover._zmgr).remove(this$.z);
              delete this$.z;
            }
          }
          if (this$.opt.transformFix && !isActive) {
            this$._r.classList.remove('shown');
          }
          setTimeout(function(){
            this$._r.classList.remove('running');
            if (this$.opt.transformFix && isActive) {
              this$._r.classList.add('shown');
            }
            if (!isActive && this$.opt.byDisplay) {
              this$._r.style.display = 'none';
            }
            if (!isActive && this$._r.parentNode && !this$.resident) {
              this$._r.parentNode.removeChild(this$._r);
            }
            if (!isActive && this$.opt.autoZ) {
              this$._r.style.zIndex = "";
            }
            return this$.fire("toggled." + (isActive ? 'on' : 'off'));
          }, this$.opt.delay);
          if (this$.promises.length && !isActive) {
            this$.set(undefined, false);
          }
          this$.fire("toggle." + (isActive ? 'on' : 'off'));
          return res();
        }, 50);
      });
    },
    on: function(n, cb){
      var this$ = this;
      return (Array.isArray(n)
        ? n
        : [n]).map(function(n){
        var ref$;
        return ((ref$ = this$.evtHandler)[n] || (ref$[n] = [])).push(cb);
      });
    },
    fire: function(n){
      var v, res$, i$, to$, ref$, len$, cb, results$ = [];
      res$ = [];
      for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
        res$.push(arguments[i$]);
      }
      v = res$;
      for (i$ = 0, len$ = (ref$ = this.evtHandler[n] || []).length; i$ < len$; ++i$) {
        cb = ref$[i$];
        results$.push(cb.apply(this, v));
      }
      return results$;
    },
    destroy: function(){
      var this$ = this;
      return this.toggle(false).then(function(){
        if (this$._c) {
          this$._c.parentNode.insertBefore(this$._r, this$._c);
          this$._c.parentNode.removeChild(this$._c);
        }
        this$._r.removeEventListener('mousedown', this$.el_md);
        return this$._r.removeEventListener('click', this$.el_c);
      });
    }
  });
  import$(ldcover, {
    popups: [],
    _zmgr: {
      add: function(v){
        var z, ref$;
        (this.s || (this.s = [])).push(z = Math.max(v || 0, ((ref$ = this.s)[ref$.length - 1] || 0) + 1));
        return z;
      },
      remove: function(v){
        var i;
        if ((i = (this.s || (this.s = [])).indexOf(v)) < 0) {} else {
          return this.s.splice(i, 1);
        }
      }
    },
    zmgr: function(it){
      if (it != null) {
        return this._zmgr = it;
      } else {
        return this._zmgr;
      }
    }
  });
  if (typeof module != 'undefined' && module !== null) {
    module.exports = ldcover;
  } else if (window) {
    window.ldcover = ldcover;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
