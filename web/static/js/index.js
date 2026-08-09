var zmgr, zmgrFloat, zmgrModal, zmgrSplash, ldld, view, ldcv;
zmgr = new zmgr();
zmgrFloat = zmgr.scope('float');
zmgrModal = zmgr.scope('modal');
zmgrSplash = zmgr.scope('splash');
ldcover.zmgr(zmgrModal);
ldcover.dialog.theme('default');
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
      },
      "test-alert": function(){
        return ldcover.alert({
          title: view.get('dlg-title').value || void 8,
          msg: view.get('dlg-msg').value,
          theme: view.get('dlg-theme').value
        }).then(function(){
          return console.log('alert dismissed');
        });
      },
      "test-confirm": function(){
        return ldcover.confirm({
          title: view.get('dlg-title').value || void 8,
          msg: view.get('dlg-msg').value,
          theme: view.get('dlg-theme').value
        }).then(function(it){
          return console.log("confirm result: ", it);
        });
      },
      "demo-alert": function(){
        return ldcover.alert('hi, this is an alert.\nmsg is rendered with pre-wrap,\nso simple formatting works.').then(function(){
          return console.log('alert dismissed');
        });
      },
      "demo-confirm": function(){
        return ldcover.confirm('are you sure?', {
          title: 'Confirm'
        }).then(function(it){
          return console.log("confirm result: ", it);
        });
      },
      "demo-confirm-danger": function(){
        return ldcover.confirm('delete this item?', {
          title: 'Delete',
          variant: 'danger'
        }).then(function(it){
          return console.log("confirm ( danger ) result: ", it);
        });
      },
      "demo-prompt": function(){
        return ldcover.prompt('what is your name?', {
          placeholder: 'your name',
          isRequired: true
        }).then(function(it){
          return console.log("prompt result: ", it);
        });
      },
      "demo-dialog": function(){
        return ldcover.dialog({
          title: 'Custom Dialog',
          msg: 'dialogs can be nested - try the buttons below.',
          fields: [
            {
              name: 'email',
              label: 'Email',
              type: 'email',
              placeholder: 'me@example.com',
              isRequired: true
            }, {
              name: 'note',
              label: 'Note',
              type: 'textarea'
            }
          ],
          options: [
            {
              label: 'Nest another',
              action: function(){
                return ldcover.confirm('a nested confirm, stacked above. z-index should be correct.');
              }
            }, {
              label: 'Cancel',
              value: null
            }, {
              label: 'Submit',
              value: 'submit',
              variant: 'primary',
              focus: true
            }
          ]
        }).then(function(r){
          return console.log("dialog result: ", r);
        });
      }
    }
  }
});
view.get('demo-theme').addEventListener('change', function(e){
  return ldcover.dialog.theme(e.target.value);
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
  inPlace: false,
  lock: true
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
  zmgr: zmgrModal,
  escape: false
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