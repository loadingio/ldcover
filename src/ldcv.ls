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
    # `active` is only written after the 50ms break below, so it is stale while
    # a transition is in flight. `running` marks exactly that window, and
    # `_target` carries the intended state across it; once settled, the dom is
    # the truth again - nothing here outlives a transition.
    cur = if @_r.classList.contains \running => @_target else @_r.classList.contains \active
    if v? and cur == !!v => return res!
    @_target = is-active = (if v? => !!v else !cur)
    @_seq = seq = (@_seq or 0) + 1
    if is-active and !@_r.parentNode =>
      # insert into original place if no container defined. default behavior ( `container` not provided )
      if !(@container?) and @_c and @_c.parentNode => @_c.parentNode.insertBefore @_r, @_c
      # insert into container - if container is explicitly set as `null`, use document.body
      else (@container or document.body).appendChild @_r
    @_r.classList.add \running
    if @opt.by-display => @_r.style.display = \block

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
    # if we want to remove this setTimeout, either we have to use css animation to force animation, or we just
    # setTimeout for adding active class only.
    #
    # Additionally, we should check if quickly toggle on / off will cause problem due to setTimeout.
    <~ setTimeout _, 50
    @_r.classList.toggle \active, is-active
    # scheduled here, next to the flip it settles, so nothing between the two
    # can leave `running` on forever by throwing.
    setTimeout (~>
      # superseded by a newer toggle - only the last one settles the state,
      # so that `toggled.*` fires once and `running` outlives every transition.
      if @_seq != seq => return
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
    # for inline cover, click outside trigger dismissing. registered after the
    # break above: the click that opens the cover is still bubbling before it,
    # and would reach this handler and close it right back.
    if @_r.classList.contains \inline =>
      if is-active =>
        if !@el_h =>
          @el_h = (e) ~> if @_r.contains e.target => return else @toggle false
          window.addEventListener \click, @el_h
      else if @el_h =>
        window.removeEventListener \click, @el_h
        @el_h = null
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

# promise-based dialog helpers ( alert / confirm / prompt / dialog ).
# structure-only styling; theme via `cls` opt or the nested class hooks under .ldcv.builtin.
ldcover.dialog = (opt = {}) -> new Promise (res, rej) ->
  add-cls = (el, cls) -> if cls => el.classList.add.apply el.classList, String(cls).split(/\s+/)
  rm-cls = (el, cls) -> if cls => el.classList.remove.apply el.classList, String(cls).split(/\s+/)
  theme-name = String(opt.theme or ldcover.dialog.theme!)
  theme = ldcover.dialog.themes[theme-name] or {}
  escapable = if opt.escape? => !!opt.escape else true
  options = opt.options or [{label: 'OK', value: \ok, variant: \primary, focus: true}]
  fields = opt.fields or []
  root = ldcover.dialog.dom!
  inner = root.querySelector '.inner'
  tel = root.querySelector '.title'
  mel = root.querySelector '.msg'
  fwrap = root.querySelector '.fields'
  owrap = root.querySelector '.options'
  # customize the prebuilt skeleton with DOM api only - no user input goes into innerHTML.
  if opt.title =>
    tel.textContent = opt.title
    add-cls tel, theme.title
  else if tel and tel.parentNode => tel.parentNode.removeChild tel
  if opt.msg and opt.msg.nodeType => mel.appendChild opt.msg
  else if opt.msg? => mel.textContent = opt.msg
  else if mel and mel.parentNode => mel.parentNode.removeChild mel
  if opt.msg? => add-cls mel, theme.msg
  input-of = {}
  has-required = false
  if !fields.length =>
    if fwrap and fwrap.parentNode => fwrap.parentNode.removeChild fwrap
  else
    add-cls fwrap, theme.fields
    for f in fields
      fel = document.createElement \div
      fel.className = \field
      add-cls fel, theme.field
      fwrap.appendChild fel
      if f.label =>
        lel = document.createElement \label
        lel.textContent = f.label
        add-cls lel, theme.label
        fel.appendChild lel
      if f.type == \textarea =>
        iel = document.createElement \textarea
        add-cls iel, theme.textarea
      else
        iel = document.createElement \input
        iel.type = f.type or \text
        add-cls iel, theme.input
      if f.placeholder => iel.placeholder = f.placeholder
      if f.value? => iel.value = f.value
      add-cls iel, f.cls
      if f.is-required => has-required = true
      fel.appendChild iel
      eel = document.createElement \div
      eel.className = \error
      add-cls eel, theme.error
      fel.appendChild eel
      input-of[f.name] = iel
  collect = ->
    ret = {}
    for k, el of input-of => ret[k] = el.value
    ret
  validate = ->
    ok = true
    for f in fields
      iel = input-of[f.name]
      fel = iel.parentNode
      err = fel.querySelector '.error'
      if f.is-required and !String(iel.value or '').trim!
        err.textContent = f.error or 'This field is required.'
        fel.classList.add \has-error
        add-cls iel, theme.invalid
        if ok => iel.focus!
        ok = false
      else
        err.textContent = ''
        fel.classList.remove \has-error
        rm-cls iel, theme.invalid
    ok
  add-cls owrap, theme.options
  btn-els = options.map (b) ->
    bel = document.createElement \button
    bel.type = \button
    bel.classList.add (b.variant or \default)
    add-cls bel, (if typeof(theme.button) == \string => theme.button else (theme.button or {})[b.variant or \default])
    add-cls bel, b.cls
    bel.textContent = b.label
    owrap.appendChild bel
    bel
  # default button ( triggered by Enter in input fields ): focus > primary/danger > last
  di = -1
  for b, i in options => if b.focus => di = i; break
  if di < 0 => for b, i in options => if b.variant in <[primary danger]> => di = i
  if di < 0 and options.length => di = options.length - 1
  default-btn = if di >= 0 => btn-els[di] else null
  options.forEach (b, i) ->
    btn-els[i].addEventListener \click, ->
      # options with `action` run the callback and keep the dialog open -
      # handy for opening nested dialogs or custom in-dialog behavior.
      if b.action => return b.action.call cov, {fields: collect!}
      # null-value ( cancel-ish ) or novalidate options bypass required validation
      if has-required and b.value? and !b.novalidate and !validate! => return
      cov.set {value: b.value, fields: collect!}
  inner.addEventListener \keydown, (e) ->
    if e.key == \Enter and e.target.tagName == \INPUT =>
      e.preventDefault!
      if default-btn => default-btn.click!
  # autogap / scroll by default: rwd-friendly gapping + scrollable when content is long
  cls = <[builtin autogap scroll]>
  # theme class on the .ldcv root. bundled: default / bootstrap / generic ( unstyled ).
  # any other string works too - define your own .ldcv.builtin.<theme> css
  # and / or register element classes in ldcover.dialog.themes.
  cls.push theme-name
  if opt.size in <[sm md lg]> => cls.push opt.size
  if opt.cls => cls = cls ++ String(opt.cls).split(/\s+/)
  cov = new ldcover root: root, escape: escapable, lock: !escapable, type: cls
  # focus may not apply while the cover's visibility transition is still running,
  # so try on toggle.on for instant response and retry on toggled.on to be sure.
  focus-target = ->
    tgt = if fields.length => input-of[fields.0.name] else default-btn
    if tgt and document.activeElement != tgt => tgt.focus!
  cov.on <[toggle.on toggled.on]>, focus-target
  # recycle the underlying cover ( and its DOM ) once dismissed
  cov.on \toggled.off, -> setTimeout (-> cov.destroy!), 0
  cov.get!
    # escape / backdrop close resolves `get` with undefined; map value to null
    # instead of rejecting so hosts don't have to try/catch every call.
    .then (v) -> res(if v == undefined => {value: null, fields: collect!} else v)
    .catch -> res {value: null, fields: collect!}

# prebuilt dialog skeleton. override to customize structure but keep the
# .title / .msg / .fields / .options hooks under .inner.
# static markup only; user provided content is applied later via DOM api to avoid xss.
ldcover.dialog.dom = ->
  root = document.createElement \div
  root.innerHTML = '<div class="base"><div class="inner"><div class="title"></div><div class="msg"></div><div class="fields"></div><div class="options"></div></div></div>'
  root

# get / set the default theme for dialogs without an explicit `theme` opt.
# e.g., `ldcover.dialog.theme('bootstrap')` once to apply globally.
# bundled: 'default' / 'bootstrap' / 'generic' ( unstyled, for host styling ).
ldcover.dialog.theme = -> if it? => ldcover.dialog._theme = it else (ldcover.dialog._theme or \generic)

# per-theme element classes, applied onto dialog elements while building.
# a theme entry may define: title / msg / fields / field / label / input / textarea /
# error / options / button ( string, or per-variant map ) / invalid ( added on
# input & textarea when required validation fails ).
# hosts can register their own theme here ( e.g. tailwind utility classes ).
ldcover.dialog.themes =
  bootstrap:
    title: \h5
    input: \form-control
    textarea: \form-control
    invalid: \is-invalid
    error: 'text-danger small'
    button:
      default: 'btn btn-outline-secondary'
      primary: 'btn btn-primary'
      danger: 'btn btn-danger'

# msg can be a string / DOM node, or an option object with `msg` inside.
norm-opt = (msg, opt) ->
  if msg and typeof(msg) == \object and !msg.nodeType => {} <<< msg <<< (opt or {})
  else {msg: msg} <<< (opt or {})

ldcover.alert = (msg, opt) ->
  o = norm-opt msg, opt
  ldcover.dialog do
    title: o.title, msg: o.msg, size: o.size, cls: o.cls, theme: o.theme
    options: [{label: o.ok-text or 'OK', value: \ok, variant: (o.variant or \primary), focus: true}]
  .then -> return

ldcover.confirm = (msg, opt) ->
  o = norm-opt msg, opt
  ldcover.dialog do
    title: o.title, msg: o.msg, size: o.size, cls: o.cls, theme: o.theme
    options: [
      {label: o.cancel-text or 'Cancel', value: null}
      {label: o.ok-text or 'OK', value: true, variant: (o.variant or \primary), focus: true}
    ]
  .then (r) -> r.value == true

ldcover.prompt = (msg, opt) ->
  o = norm-opt msg, opt
  ldcover.dialog do
    title: o.title, msg: o.msg, size: o.size, cls: o.cls, theme: o.theme
    fields: [{name: \value, type: o.type or \text, placeholder: o.placeholder, value: o.value, is-required: o.is-required}]
    options: [
      {label: o.cancel-text or 'Cancel', value: null}
      {label: o.ok-text or 'OK', value: \ok, variant: (o.variant or \primary), focus: true}
    ]
  .then (r) -> if r.value == \ok => r.fields.value else null

ldcover <<< do
  popups: []
  _zmgr: do
    add: (v) -> @[]s.push(z = Math.max(v or 0, (@s[* - 1] or 0) + 1)); return z
    remove: (v) -> if (i = @[]s.indexOf(v)) < 0 => return else @s.splice(i,1)
  zmgr: -> if it? => @_zmgr = it else @_zmgr

if module? => module.exports = ldcover
else if window => window.ldcover = ldcover
