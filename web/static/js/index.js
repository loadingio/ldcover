var view, ldcv;
view = new ldView({
  root: document.body
});
ldcv = new ldCover({
  root: view.get('ldcv')
});
ldcv.toggle(true);