
main = (opt={}) ->
  @opt = opt
  @stack = []
  @step = opt.step or 1
  @

main.prototype = Object.create(Object.prototype) <<< do
  add: (v,s=0) ->
    if !(@value?) => @value = v
    v = if @step > 0 => Math.max(@value,v) else Math.min(@value,v)
    v = v + (if @step > 0 => 1 else -1) * Math.max(Math.abs(@step),Math.abs(s))
    @stack.push v
    @value = v
    return v

  remove: (v) ->
    if !~(i = @stack.indexOf v) => return
    @stack.splice i, 1

zmgr = new main!
ldCover.set-zmgr zmgr
ldLoader.set-zmgr zmgr
ldld = new ldLoader className: "full ldld", auto-z: true

view = new ldView do
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
ldcv.confirm = new ldCover root: view.get('ldcv-confirm')
ldcv.tos = new ldCover root: view.get('ldcv-tos')
ldcv.mini = new ldCover root: view.get('ldcv-mini')
ldcv.mini.toggle true
