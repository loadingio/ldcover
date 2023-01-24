
zmgr = new zmgr!
zmgr-float = zmgr.scope 'float'
zmgr-modal = zmgr.scope 'modal'
zmgr-splash = zmgr.scope 'splash'

#zmgr-lower = new zmgr init: 100
#zmgr = new zmgr init: 1000
ldcover.zmgr zmgr-modal
ldloader.zmgr zmgr-splash
ldld = new ldloader className: "full ldld", auto-z: true, zmgr: zmgr-splash

view = new ldview do
  root: document.body
  action: click:
    "show-editbox": -> ldcv.editbox.toggle true
    "show-tos": -> ldcv.tos.toggle true
    "show-hint": -> ldcv.hint.toggle true
    "show-template": -> ldcv.template.toggle true
    "get-value": ->
      ldcv.get-value.get!
        .then -> console.log \ok
        .catch -> console.error "exception: ", it
    agree: ->
      ldld.on!
      debounce 1000
        .then -> ldld.off!
        .then -> ldcv.confirm.get!
        .then -> ldcv.tos.toggle false


ldcv = {}
ldcv.editbox = new ldcover root: view.get('ldcv-editbox'), zmgr: zmgr-float, resident: true
ldcv.template = new ldcover root: view.get('ldcv-template'), zmgr: zmgr-float, in-place: false, lock: true
ldcv.timeout = new ldcover root: view.get('ldcv-timeout'), zmgr: zmgr-float, in-place: false
ldcv.hint = new ldcover root: view.get('ldcv-hint'), zmgr: zmgr-float, in-place: false
ldcv.confirm = new ldcover root: view.get('ldcv-confirm'), zmgr: zmgr-modal, in-place: false
ldcv.tos = new ldcover root: view.get('ldcv-tos'), zmgr: zmgr-modal, in-place: false
ldcv.get-value = new ldcover root: view.get('ldcv-get-value'), zmgr: zmgr-modal
ldcv.mini = new ldcover root: view.get('ldcv-mini'), zmgr: zmgr-modal, escape: false
ldcv.mini.toggle true, zmgr: zmgr-modal

ldcv.timeout.destroy!
  .then -> ldcv.editbox.destroy!
  .then ->
    ldcv.timeout = new ldcover root: view.get('ldcv-timeout'), zmgr: zmgr-float, in-place: false
    ldcv.editbox = new ldcover root: view.get('ldcv-editbox'), zmgr: zmgr-float, resident: true
  .then ->
    setTimeout (-> ldcv.timeout.toggle! ), 1000
