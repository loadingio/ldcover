var view, ldcv;
view = new ldView({
  root: document.body,
  action: {
    click: {
      "show-tos": function(){
        return ldcv.tos.toggle(true);
      }
    }
  }
});
ldcv = {};
ldcv.tos = new ldCover({
  root: view.get('ldcv-tos')
});
ldcv.mini = new ldCover({
  root: view.get('ldcv-mini')
});
ldcv.mini.toggle(true);