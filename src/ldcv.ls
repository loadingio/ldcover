parent = (r, s, e = document) ->
  n = r; while n and n != e => n = n.parentNode # must under e
  if n != e => return null
  n = r; while n and n != e and n.matches and !n.matches(s) => n = n.parentNode # must match s selector
  if n == e and (!e.matches or !e.matches(s)) => return null
  return n

ldcover = (opt={}) ->
  @opt = {delay: 300, auto-z: true, base-z: 3000, escape: true, by-display: true} <<< opt
  if opt.zmgr => @zmgr opt.zmgr
  @promises = []
  @root = if !opt.root =>
    ret = document.createElement("div")
    ret.innerHTML = """<div class="base"></div>"""
    ret
  else if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  cls = if typeof(opt.type) == \string => opt.type.split ' ' else opt.type
  if @root.getAttribute(\data-lock) => if that == \true => @opt.lock = true
  @inner = @root.querySelector '.inner'
  @base = @root.querySelector '.base'
  @root.classList.add.apply @root.classList, <[ldcv]> ++ (cls or [])
  if @opt.by-display => @root.style.display = \none

  # keep mousedown element here to track if the following click is inside the black area.
  # some modal might contain widgets for user to drag. user might drag outside the modal.
  # if user drag and release in the black area, it might trigger a click event -
  # but we don't want this event to be treated as a close signal.
  # so, if clicksrc is not @root, we just don't close modal directly but do following check then.
  clicksrc = null
  @root.addEventListener \mousedown, (e) ~> clicksrc := e.target
  @root.addEventListener \click, (e) ~>
    if clicksrc == @root and !@opt.lock => return @toggle false
    if parent(e.target, '*[data-ldcv-cancel]', @root) => return @cancel!
    tgt = parent(e.target, '*[data-ldcv-set]', @root)
    if tgt and (action = tgt.getAttribute("data-ldcv-set"))? =>
      if !parent(tgt, '.disabled', @root) => @set action
  @evt-handler = {}
  @

ldcover.prototype = Object.create(Object.prototype) <<< do
  zmgr: -> if it? => @_zmgr = it else @_zmgr
  # append element into ldcv. should be used for ldcv created without providing root.
  append: ->
    base = @root.childNodes.0
    (if base and base.classList.contains('base') => base else @root).appendChild it
  get: -> new Promise (res, rej) ~>
    @promises.push {res, rej}
    @toggle true
  cancel: (err, hide = true) ->
    @promises.splice 0 .map (p) -> p.rej(err or (new Error! <<< {name: \lderror, id: 999}))
    if hide => @toggle false
  # clear promises list and call res for each item
  set: (v, hide = true) ->
    @promises.splice 0 .map (p) -> p.res v
    if hide => @toggle false
  is-on: -> return @root.classList.contains(\active)
  lock: ->
    @opt.lock = true
  toggle: (v) -> new Promise (res, rej) ~>
    if !(v?) and @root.classList.contains \running => return res!
    @root.classList.add \running
    if @opt.by-display => @root.style.display = \block
    # why setTimeout?
    # It seems even if element is not visible ( opacity = 0, visibility = hidden ), mouse moving over them might
    # still makes animation slow down.
    # set z-index to -1 seems to work but if ldcv is in another div with greater z-index, it then won't work.
    #
    # To maximize performance, we set `display` style to `none` for nonactive ldcv element, and set it to
    # `block` when we need to activate it.
    #
    # But when ldcv is visible by setting `display` to `block` and adding 'active' at the same time,
    # all visual styles ( such as opacity, transform etc ) will be inited by active class instead of
    # the non-active value. This makes entering transition not work.
    #
    # Thus, we first set `block` here, give it a break by `setTimeout`, then set `active` class immediately
    #
    # if we want to remove thie setTimeout, either we have to use css animation to force animation, or we just
    # setTimeout for adding active class only.
    #
    # Additionally, we should check if quickly toggle on / off will cause problem due to setTimeout.
    <~ setTimeout _, 50
    if v? => @root.classList[if v => \add else \remove](\active)
    else @root.classList.toggle \active
    is-active = @root.classList.contains(\active)
    if !@opt.lock and @opt.escape and is-active =>
      esc = (e) ~> if e.keyCode == 27 =>
        if ldcover.popups[* - 1] != @ => return
        @toggle false
        document.removeEventListener \keyup, esc
      document.addEventListener \keyup, esc
    if @opt.animation and @inner =>
      @inner.classList[if is-active => \add else \remove].apply @inner.classList, @opt.animation.split(' ')
    if is-active => ldcover.popups.push @
    else
      idx = ldcover.popups.indexOf(@)
      if idx >= 0 => ldcover.popups.splice idx, 1
    if @opt.auto-z =>
      if is-active =>
        @root.style.zIndex = @z = (@_zmgr or ldcover._zmgr).add @opt.base-z
      else
        (@_zmgr or ldcover._zmgr).remove @z
        delete @z # must delete z to prevent some modal being toggled off twice.
        @root.style.zIndex = ""
    if @opt.transform-fix and !is-active => @root.classList.remove \shown
    setTimeout (~>
      @root.classList.remove \running
      if @opt.transform-fix and is-active => @root.classList.add \shown
      if !is-active and @opt.by-display => @root.style.display = \none
    ), @opt.delay
    if @promises.length and !is-active => @set undefined, false
    @fire "toggle.#{if is-active => \on else \off}"
    return res!
  on: (n, cb) -> (if Array.isArray(n) => n else [n]).map (n) ~> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v

ldcover <<< do
  popups: []
  _zmgr: do
    add: (v) -> @[]s.push(z = Math.max(v or 0, (@s[* - 1] or 0) + 1)); return z
    remove: (v) -> if (i = @[]s.indexOf(v)) < 0 => return else @s.splice(i,1)
  zmgr: -> if it? => @_zmgr = it else @_zmgr

if module? => module.exports = ldcover
else if window => window.ldCover = window.ldcover = ldcover
