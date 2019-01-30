(->
  ldCover = (opt={}) ->
    @ <<< opt{root}
    @root = if !@root =>
      ret = document.createElement("div")
      ret.innerHTML = """<div class="base"></div>"""
      ret
    else if typeof(@root) == \string => document.querySelector(@root) else @root
    cls = if typeof(opt.type) == \string => opt.type.split ' ' else opt.type
    @base = @root.querySelector '.base'
    @root.classList.add.apply @root.classList, <[ldcv]> ++ (cls or [])
    @root.addEventListener \click, (e) ~>
      if e.target == @root or e.target.classList.contains \close-btn => @toggle false
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
    set: (v) ->
      @promises.splice 0 .map (p) -> p.res v
      @toggle false
    toggle: (v) ->
      # running currently no use. remove it in the future?
      if @root.classList.contains \running => return
      @root.classList.remove \shown
      @root.classList.add \running
      if v? => @root.classList[if v => \add else \remove](\active )
      else @root.classList.toggle \active
      setTimeout (~>
        @root.classList.remove \running
        if @root.classList.contains \active => @root.classList.add \shown
      ), 100
      if @promises.length and !@root.classList.contains(\active) => @set!
    on: (n, cb) -> @evt-handler.[][n].push cb
    fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v


  if module? => module.exports = ldCover
  if window => window.ldCover = ldCover
)!
