var zmgrLower, zmgr, ldld, view, ldcv;
zmgrLower = new zmgr({
  init: 100
});
zmgr = new zmgr({
  init: 1000
});
ldcover.zmgr(zmgr);
ldloader.zmgr(zmgr);
ldld = new ldloader({
  className: "full ldld",
  autoZ: true,
  zmgr: zmgr
});
view = new ldview({
  root: document.body,
  action: {
    click: {
      "show-tos": function(){
        return ldcv.tos.toggle(true);
      },
      "show-hint": function(){
        return ldcv.hint.toggle(true);
      },
      "get-value": function(){
        return ldcv.getValue.get().then(function(){
          return console.log('ok');
        })['catch'](function(it){
          return console.error("exception: ", it);
        });
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
ldcv.timeout = new ldcover({
  root: view.get('ldcv-timeout'),
  zmgr: zmgrLower
});
ldcv.hint = new ldcover({
  root: view.get('ldcv-hint'),
  zmgr: zmgrLower
});
ldcv.confirm = new ldcover({
  root: view.get('ldcv-confirm'),
  zmgr: zmgr
});
ldcv.tos = new ldcover({
  root: view.get('ldcv-tos'),
  zmgr: zmgr
});
ldcv.getValue = new ldcover({
  root: view.get('ldcv-get-value'),
  zmgr: zmgr
});
ldcv.mini = new ldcover({
  root: view.get('ldcv-mini'),
  zmgr: zmgr
});
ldcv.mini.toggle(true, {
  zmgr: zmgr
});
setTimeout(function(){
  return ldcv.timeout.toggle();
}, 1000);