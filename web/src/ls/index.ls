view = new ldView do
  root: document.body
  action: click: "show-tos": -> ldcv.tos.toggle true
ldcv = {}
ldcv.tos = new ldCover root: view.get('ldcv-tos')
ldcv.mini = new ldCover root: view.get('ldcv-mini')
ldcv.mini.toggle true
