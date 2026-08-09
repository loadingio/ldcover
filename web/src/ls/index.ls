
zmgr = new zmgr!
zmgr-float = zmgr.scope 'float'
zmgr-modal = zmgr.scope 'modal'
zmgr-splash = zmgr.scope 'splash'

#zmgr-lower = new zmgr init: 100
#zmgr = new zmgr init: 1000
ldcover.zmgr zmgr-modal
# session-wide default theme for dialog helpers; per-call `theme` opt still wins
ldcover.dialog.theme \default
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
    "test-alert": ->
      ldcover.alert {title: (view.get('dlg-title').value or void), msg: view.get('dlg-msg').value, theme: view.get('dlg-theme').value}
        .then -> console.log 'alert dismissed'
    "test-confirm": ->
      # confirm comes with ok + cancel by default
      ldcover.confirm {title: (view.get('dlg-title').value or void), msg: view.get('dlg-msg').value, theme: view.get('dlg-theme').value}
        .then -> console.log "confirm result: ", it
    "demo-alert": ->
      ldcover.alert 'hi, this is an alert.\nmsg is rendered with pre-wrap,\nso simple formatting works.'
        .then -> console.log 'alert dismissed'
    "demo-confirm": ->
      ldcover.confirm 'are you sure?', {title: 'Confirm'}
        .then -> console.log "confirm result: ", it
    # `variant: 'danger'` renders the OK option in danger variant ( btn-danger in bootstrap theme )
    "demo-confirm-danger": ->
      ldcover.confirm 'delete this item?', {title: 'Delete', variant: \danger}
        .then -> console.log "confirm ( danger ) result: ", it
    "demo-prompt": ->
      ldcover.prompt 'what is your name?', {placeholder: 'your name', is-required: true}
        .then -> console.log "prompt result: ", it
    "demo-dialog": ->
      ldcover.dialog do
        title: 'Custom Dialog'
        msg: 'dialogs can be nested - try the buttons below.'
        fields: [
          {name: \email, label: 'Email', type: \email, placeholder: 'me@example.com', is-required: true}
          {name: \note, label: 'Note', type: \textarea}
        ]
        options: [
          {label: 'Nest another', action: -> ldcover.confirm 'a nested confirm, stacked above. z-index should be correct.'}
          {label: 'Cancel', value: null}
          {label: 'Submit', value: \submit, variant: \primary, focus: true}
        ]
      .then (r) -> console.log "dialog result: ", r


# theme chooser next to the demo buttons updates the global default
view.get('demo-theme').addEventListener \change, (e) -> ldcover.dialog.theme e.target.value

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
