
zmgr = new zmgr!
ldCover.set-zmgr zmgr
ldLoader.set-zmgr zmgr
ldld = new ldLoader className: "full ldld", auto-z: true

view = new ldview do
  root: document.body
  action: click:
    "show-tos": -> ldcv.tos.toggle true
    agree: ->
      ldld.on!
      debounce 1000
        .then -> ldld.off!
        .then -> ldcv.confirm.get!
        .then -> ldcv.tos.toggle false


ldcv = {}
ldcv.confirm = new ldcover root: view.get('ldcv-confirm')
ldcv.tos = new ldcover root: view.get('ldcv-tos')
ldcv.mini = new ldcover root: view.get('ldcv-mini')
ldcv.mini.toggle true
