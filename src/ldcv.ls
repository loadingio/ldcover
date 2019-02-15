(->
  ldCover = (opt={}) ->
    @opt = {delay: 300, auto-z: true, base-z: 1000} <<< opt
    @root = if !opt.root =>
      ret = document.createElement("div")
      ret.innerHTML = """<div class="base"></div>"""
      ret
    else if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
    cls = if typeof(opt.type) == \string => opt.type.split ' ' else opt.type
    @base = @root.querySelector '.base'
    @root.classList.add.apply @root.classList, <[ldcv]> ++ (cls or [])
    @root.addEventListener \click, (e) ~>
      if e.target == @root or e.target.classList.contains \close-btn => @toggle false
      action = e.target.getAttribute("data-ldcv-set")
      if action? => @set action
    @evt-handler = {}
    @

  ldCover.prototype = Object.create(Object.prototype) <<< do
    promises: []
    # append element into ldcv. should be used for ldcv created without providing root.
    append: ->
      base = @root.childNodes.0
      (if base and base.classList.contains('base') => base else @root).appendChild it
    get: -> new Promise (res, rej) ~>
      @promises.push {res, rej}
      @toggle true
    # clear promises list and call res for each item
    set: (v, hide = true) ->
      @promises.splice 0 .map (p) -> p.res v
      if hide => @toggle false
    is-on: -> return @root.classList.contains(\active)
    toggle: (v) ->
      if !(v?) and @root.classList.contains \running => return
      @root.classList.add \running
      if v? => @root.classList[if v => \add else \remove](\active)
      else @root.classList.toggle \active
      is-active = @root.classList.contains(\active)
      if @opt.auto-z =>
        if is-active =>
          @root.style.zIndex = @z = z = (ldCover.zstack[* - 1] or 0) + @opt.base-z
          ldCover.zstack.push z
        else
          if (idx = ldCover.zstack.indexOf(@z)) < 0 => return
          @root.style.zIndex = ""
          ldCover.zstack.splice(idx, 1)
      if @opt.transform-fix and !is-active => @root.classList.remove \shown
      setTimeout (~>
        @root.classList.remove \running
        if @opt.transform-fix and is-active => @root.classList.add \shown
      ), @opt.delay
      if @promises.length and !is-active => @set undefined, false
      @fire "toggle.#{if is-active => \on else \off}"

    on: (n, cb) -> @evt-handler.[][n].push cb
    fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v

  ldCover <<< do
    zstack: []

  if module? => module.exports = ldCover
  if window => window.ldCover = ldCover
)!
