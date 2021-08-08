
zmgr = new zmgr!
ldCover.set-zmgr zmgr
ldLoader.set-zmgr zmgr
ldld = new ldLoader className: "full ldld", auto-z: true

view = new ldview do
  root: document.body
  action: click:
    "show-tos": -> ldcv.tos.toggle true
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
ldcv.confirm = new ldcover root: view.get('ldcv-confirm')
ldcv.tos = new ldcover root: view.get('ldcv-tos')
ldcv.get-value = new ldcover root: view.get('ldcv-get-value')
ldcv.mini = new ldcover root: view.get('ldcv-mini')
ldcv.mini.toggle true
