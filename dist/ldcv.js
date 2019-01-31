// Generated by LiveScript 1.3.1
var slice$ = [].slice;
(function(){
  var ldCover;
  ldCover = function(opt){
    var ret, cls, this$ = this;
    opt == null && (opt = {});
    this.root = opt.root;
    this.root = !this.root
      ? (ret = document.createElement("div"), ret.innerHTML = "<div class=\"base\"></div>", ret)
      : typeof this.root === 'string'
        ? document.querySelector(this.root)
        : this.root;
    cls = typeof opt.type === 'string'
      ? opt.type.split(' ')
      : opt.type;
    this.base = this.root.querySelector('.base');
    this.root.classList.add.apply(this.root.classList, ['ldcv'].concat(cls || []));
    this.root.addEventListener('click', function(e){
      if (e.target === this$.root || e.target.classList.contains('close-btn')) {
        return this$.toggle(false);
      }
    });
    this.evtHandler = {};
    return this;
  };
  ldCover.prototype = import$(Object.create(Object.prototype), {
    promises: [],
    append: function(it){
      var base;
      base = this.root.childNodes[0];
      return (base && base.classList.contains('base')
        ? base
        : this.root).appendChild(it);
    },
    get: function(){
      var this$ = this;
      return new Promise(function(res, rej){
        this$.promises.push({
          res: res,
          rej: rej
        });
        return this$.toggle(true);
      });
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
    toggle: function(v){
      var this$ = this;
      if (this.root.classList.contains('running')) {
        return;
      }
      this.root.classList.remove('shown');
      this.root.classList.add('running');
      if (v != null) {
        this.root.classList[v ? 'add' : 'remove']('active');
      } else {
        this.root.classList.toggle('active');
      }
      setTimeout(function(){
        this$.root.classList.remove('running');
        if (this$.root.classList.contains('active')) {
          return this$.root.classList.add('shown');
        }
      }, 100);
      if (this.promises.length && !this.root.classList.contains('active')) {
        return this.set(undefined, false);
      }
    },
    on: function(n, cb){
      var ref$;
      return ((ref$ = this.evtHandler)[n] || (ref$[n] = [])).push(cb);
    },
    fire: function(n){
      var v, i$, ref$, len$, cb, results$ = [];
      v = slice$.call(arguments, 1);
      for (i$ = 0, len$ = (ref$ = this.evtHandler[n] || []).length; i$ < len$; ++i$) {
        cb = ref$[i$];
        results$.push(cb.apply(this, v));
      }
      return results$;
    }
  });
  if (typeof module != 'undefined' && module !== null) {
    module.exports = ldCover;
  }
  if (window) {
    return window.ldCover = ldCover;
  }
})();
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
