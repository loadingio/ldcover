parent = (r, s, e = document) ->
  n = r; while n and n != e => n = n.parentNode # must under e
  if n != e => return null
  n = r; while n and n != e and n.matches and !n.matches(s) => n = n.parentNode # must match s selector
  if n == e and (!e.matches or !e.matches(s)) => return null
  return n

ldcover = (opt={}) ->
  @evt-handler = {}
  @opt = {delay: 300, auto-z: true, base-z: 3000, escape: true, by-display: true} <<< opt
  if opt.zmgr => @zmgr opt.zmgr
  @promises = []
  @_r = if !opt.root =>
    ret = document.createElement("div")
    ret.innerHTML = """<div class="base"></div>"""
    ret
  else if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  @cls = if typeof(opt.type) == \string => opt.type.split ' ' else opt.type
  @resident = if opt.resident? => opt.resident else false
  @in-place = if opt.in-place? => opt.in-place else true
  @container = if typeof(opt.container) == \string => document.querySelector(opt.container) else opt.container
  # for template type root, lazy init.
  if !(@_r.content and @_r.content.nodeType == Element.DOCUMENT_FRAGMENT_NODE) => @init!
  @

ldcover.prototype = Object.create(Object.prototype) <<< do
  root: ->
    if !@inited => @init!
    @_r
  init: ->
    if @inited => return
    @inited = true
    if !@in-place =>
      @_r.parentNode.removeChild @_r
      document.body.appendChild @_r
    if !@resident and @_r.parentNode =>
      @_c = document.createComment " ldcover placeholder "
      @_r.parentNode.insertBefore @_c, @_r
      @_r.parentNode.removeChild @_r
    if @_r.content and @_r.content.nodeType == Element.DOCUMENT_FRAGMENT_NODE =>
      @_r = @_r.content.cloneNode(true).childNodes.0
      @_r.parentNode.removeChild @_r

    if @_r.getAttribute(\data-lock) => if that == \true => @opt.lock = true
    @inner = @_r.querySelector '.inner'
    @base = @_r.querySelector '.base'
    @_r.classList.add.apply @_r.classList, <[ldcv]> ++ (@cls or [])
    if @opt.by-display => @_r.style.display = \none
    # keep mousedown element here to track if the following click is inside the black area.
    # some modal might contain widgets for user to drag. user might drag outside the modal.
    # if user drag and release in the black area, it might trigger a click event -
    # but we don't want this event to be treated as a close signal.
    # so, if clicksrc is not @_r, we just don't close modal directly but do following check then.
    clicksrc = null
    @_r.addEventListener \mousedown, @el_md = (e) ~> clicksrc := e.target
    @_r.addEventListener \click, @el_c = (e) ~>
      if clicksrc == @_r and !@opt.lock =>
        e.stopPropagation!
        return @toggle false
      if parent(e.target, '*[data-ldcv-cancel]', @_r) =>
        e.stopPropagation!
        return @cancel!
      tgt = parent(e.target, '*[data-ldcv-set]', @_r)
      if tgt and (action = tgt.getAttribute("data-ldcv-set"))? =>
        if !parent(tgt, '.disabled', @_r) =>
          e.stopPropagation!
          @set action

  zmgr: -> if it? => @_zmgr = it else @_zmgr
  # append element into ldcv. should be used for ldcv created without providing root.
  append: ->
    base = @_r.childNodes.0
    (if base and base.classList.contains('base') => base else @_r).appendChild it
  get: (p) -> new Promise (res, rej) ~>
    @promises.push {res, rej}
    @toggle true, p
  cancel: (err, hide = true) ->
    @promises.splice 0 .map (p) -> p.rej(err or (new Error! <<< {name: \lderror, id: 999}))
    if hide => @toggle false
  # clear promises list and call res for each item
  set: (v, hide = true) ->
    @promises.splice 0 .map (p) -> p.res v
    if hide => @toggle false
  is-on: -> return @_r.classList.contains(\active)
  lock: -> @opt.lock = true
  toggle: (v, p) -> new Promise (res, rej) ~>
    if !@inited => @init!
    # p is for passing additional parameter to ldcv host
    if v and p? => @fire \data, p
    if !(v?) and @_r.classList.contains \running => return res!
    if v? and @_r.classList.contains(\active) == !!v => return res!
    is-active = if v? => v else !@_r.classList.contains(\active)
    if is-active and !@_r.parentNode =>
      # insert into original place if no container defined. default behavior ( `container` not provided )
      if !(@container?) and @_c and @_c.parentNode => @_c.parentNode.insertBefore @_r, @_c
      # insert into container - if container is explicitly set as `null`, use document.body
      else (@container or document.body).appendChild @_r
    @_r.classList.add \running
    if @opt.by-display => @_r.style.display = \block

    # for inline cover, click outside trigger dismissing.
    if @_r.classList.contains \inline =>
      if is-active =>
        @el_h = (e) ~> if @_r.contains e.target => return else @toggle false
        window.addEventListener \click, @el_h
      else if @el_h =>
        window.removeEventListener \click, @el_h
        @el_h = null

    if !is-active and @el_esc =>
      document.removeEventListener \keyup, @el_esc
      @el_esc = null

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
    @_r.classList.toggle \active, is-active
    if !@opt.lock and @opt.escape and is-active and !@el_esc =>
      @el_esc = (e) ~> if e.keyCode == 27 =>
        if ldcover.popups[* - 1] == @ => @toggle false
      document.addEventListener \keyup, @el_esc
    if @opt.animation and @inner =>
      @inner.classList[if is-active => \add else \remove].apply @inner.classList, @opt.animation.split(' ')
    if is-active => ldcover.popups.push @
    else
      idx = ldcover.popups.indexOf(@)
      if idx >= 0 => ldcover.popups.splice idx, 1
    if @opt.auto-z =>
      if is-active =>
        @_r.style.zIndex = @z = (@_zmgr or ldcover._zmgr).add @opt.base-z
      else
        (@_zmgr or ldcover._zmgr).remove @z
        delete @z # must delete z to prevent some modal being toggled off twice.
    if @opt.transform-fix and !is-active => @_r.classList.remove \shown
    setTimeout (~>
      @_r.classList.remove \running
      if @opt.transform-fix and is-active => @_r.classList.add \shown
      if !is-active and @opt.by-display => @_r.style.display = \none
      if !is-active and @_r.parentNode and !@resident => @_r.parentNode.removeChild @_r
      # clear z-index until hidden so we can fade away smoothly
      # otherwise if there are relative element with some z-index
      # we will fall immediately behind them.
      if !is-active and @opt.auto-z => @_r.style.zIndex = ""
      @fire "toggled.#{if is-active => \on else \off}"
    ), @opt.delay
    if @promises.length and !is-active => @set undefined, false
    @fire "toggle.#{if is-active => \on else \off}"
    return res!
  on: (n, cb) -> (if Array.isArray(n) => n else [n]).map (n) ~> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  destroy: (o={}) ->
    <~ @toggle false .then _
    if @_c =>
      if !o.remove-node => @_c.parentNode.insertBefore @_r, @_c
      @_c.parentNode.removeChild @_c
    @_r.removeEventListener \mousedown, @el_md
    @_r.removeEventListener \click, @el_c

ldcover <<< do
  popups: []
  _zmgr: do
    add: (v) -> @[]s.push(z = Math.max(v or 0, (@s[* - 1] or 0) + 1)); return z
    remove: (v) -> if (i = @[]s.indexOf(v)) < 0 => return else @s.splice(i,1)
  zmgr: -> if it? => @_zmgr = it else @_zmgr

if module? => module.exports = ldcover
else if window => window.ldcover = ldcover
