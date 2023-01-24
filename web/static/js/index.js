var zmgr, zmgrFloat, zmgrModal, zmgrSplash, ldld, view, ldcv;
zmgr = new zmgr();
zmgrFloat = zmgr.scope('float');
zmgrModal = zmgr.scope('modal');
zmgrSplash = zmgr.scope('splash');
ldcover.zmgr(zmgrModal);
ldloader.zmgr(zmgrSplash);
ldld = new ldloader({
  className: "full ldld",
  autoZ: true,
  zmgr: zmgrSplash
});
view = new ldview({
  root: document.body,
  action: {
    click: {
      "show-editbox": function(){
        return ldcv.editbox.toggle(true);
      },
      "show-tos": function(){
        return ldcv.tos.toggle(true);
      },
      "show-hint": function(){
        return ldcv.hint.toggle(true);
      },
      "show-template": function(){
        return ldcv.template.toggle(true);
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
ldcv.editbox = new ldcover({
  root: view.get('ldcv-editbox'),
  zmgr: zmgrFloat,
  resident: true
});
ldcv.template = new ldcover({
  root: view.get('ldcv-template'),
  zmgr: zmgrFloat,
  inPlace: false
});
ldcv.timeout = new ldcover({
  root: view.get('ldcv-timeout'),
  zmgr: zmgrFloat,
  inPlace: false
});
ldcv.hint = new ldcover({
  root: view.get('ldcv-hint'),
  zmgr: zmgrFloat,
  inPlace: false
});
ldcv.confirm = new ldcover({
  root: view.get('ldcv-confirm'),
  zmgr: zmgrModal,
  inPlace: false
});
ldcv.tos = new ldcover({
  root: view.get('ldcv-tos'),
  zmgr: zmgrModal,
  inPlace: false
});
ldcv.getValue = new ldcover({
  root: view.get('ldcv-get-value'),
  zmgr: zmgrModal
});
ldcv.mini = new ldcover({
  root: view.get('ldcv-mini'),
  zmgr: zmgrModal
});
ldcv.mini.toggle(true, {
  zmgr: zmgrModal
});
ldcv.timeout.destroy().then(function(){
  return ldcv.editbox.destroy();
}).then(function(){
  ldcv.timeout = new ldcover({
    root: view.get('ldcv-timeout'),
    zmgr: zmgrFloat,
    inPlace: false
  });
  return ldcv.editbox = new ldcover({
    root: view.get('ldcv-editbox'),
    zmgr: zmgrFloat,
    resident: true
  });
}).then(function(){
  return setTimeout(function(){
    return ldcv.timeout.toggle();
  }, 1000);
});