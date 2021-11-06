
zmgr-lower = new zmgr init: 100
zmgr = new zmgr init: 1000
ldcover.zmgr zmgr
ldloader.zmgr zmgr
ldld = new ldloader className: "full ldld", auto-z: true, zmgr: zmgr

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
ldcv.editbox = new ldcover root: view.get('ldcv-editbox'), zmgr: zmgr-lower, resident: true
ldcv.template = new ldcover root: view.get('ldcv-template'), zmgr: zmgr-lower
ldcv.timeout = new ldcover root: view.get('ldcv-timeout'), zmgr: zmgr-lower
ldcv.hint = new ldcover root: view.get('ldcv-hint'), zmgr: zmgr-lower
ldcv.confirm = new ldcover root: view.get('ldcv-confirm'), zmgr: zmgr
ldcv.tos = new ldcover root: view.get('ldcv-tos'), zmgr: zmgr
ldcv.get-value = new ldcover root: view.get('ldcv-get-value'), zmgr: zmgr
ldcv.mini = new ldcover root: view.get('ldcv-mini'), zmgr: zmgr
ldcv.mini.toggle true, zmgr: zmgr

setTimeout (-> ldcv.timeout.toggle! ), 1000
