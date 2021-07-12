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
ldcv.mini = new ldcover({
  root: view.get('ldcv-mini')
});
ldcv.mini.toggle(true);