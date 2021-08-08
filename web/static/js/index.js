var zmgr, ldld, view, ldcv;
zmgr = new zmgr();
ldCover.setZmgr(zmgr);
ldLoader.setZmgr(zmgr);
ldld = new ldLoader({
  className: "full ldld",
  autoZ: true
});
view = new ldview({
  root: document.body,
  action: {
    click: {
      "show-tos": function(){
        return ldcv.tos.toggle(true);
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
ldcv.confirm = new ldcover({
  root: view.get('ldcv-confirm')
});
ldcv.tos = new ldcover({
  root: view.get('ldcv-tos')
});
ldcv.getValue = new ldcover({
  root: view.get('ldcv-get-value')
});
ldcv.mini = new ldcover({
  root: view.get('ldcv-mini')
});
ldcv.mini.toggle(true);