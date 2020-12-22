var main, zmgr, ldld, view, ldcv;
main = function(opt){
  opt == null && (opt = {});
  this.opt = opt;
  this.stack = [];
  this.step = opt.step || 1;
  return this;
};
main.prototype = import$(Object.create(Object.prototype), {
  add: function(v, s){
    s == null && (s = 0);
    if (!(this.value != null)) {
      this.value = v;
    }
    v = this.step > 0
      ? Math.max(this.value, v)
      : Math.min(this.value, v);
    v = v + (this.step > 0
      ? 1
      : -1) * Math.max(Math.abs(this.step), Math.abs(s));
    this.stack.push(v);
    this.value = v;
    return v;
  },
  remove: function(v){
    var i;
    if (!~(i = this.stack.indexOf(v))) {
      return;
    }
    return this.stack.splice(i, 1);
  }
});
zmgr = new main();
ldCover.setZmgr(zmgr);
ldLoader.setZmgr(zmgr);
ldld = new ldLoader({
  className: "full ldld",
  autoZ: true
});
view = new ldView({
  root: document.body,
  action: {
    click: {
      "show-tos": function(){
        return ldcv.tos.toggle(true);
      },
      agree: function(){
        ldld.on();
        return debounce(1000).then(function(){
          return ldld.off();
        }).then(function(){
          return ldcv.confirm.get();
        }).then(function(){
          return ldcv.tos.toggle(false);
        });
      }
    }
  }
});
ldcv = {};
ldcv.confirm = new ldCover({
  root: view.get('ldcv-confirm')
});
ldcv.tos = new ldCover({
  root: view.get('ldcv-tos')
});
ldcv.mini = new ldCover({
  root: view.get('ldcv-mini')
});
ldcv.mini.toggle(true);
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}