(->
  fire = (e,n) -> if e[n] => e[n]!
  ldcv = new ldCover root: '.ldcv'
  window.ldAlert = ldAlert = (...args) ->
    if typeof(args.0) == \object => opt = args.0
    else opt = { title: args.0, desc: args.1, type: args.2 }
    evt = opt.event
    /* we should prepare ldcv and its root here. */
    root = ldcv.root
    if opt.clone =>
      root = root.cloneNode true
      document.body.appendChild root

    if !ldAlert.dom =>
      ldAlert.dom = dom = {}
      Array.from(ldcv.root.querySelectorAll('[data-name]'))
        .map (d) -> dom[d.getAttribute(\data-name)] = d
      dom.root = root
    else dom = ldAlert.dom

    <[title desc foot yes no cancel]>.map -> if opt[it] => dom[it].innerHTML = opt[it]
    if opt.type =>
      c = "#{icon.svg}#{icon[opt.type]}#{icon.bounce}<desc>#{Math.random!}</desc></svg>"
      dom.icon.setAttribute \src, "data:image/svg+xml,#{encodeURIComponent(c)}"
    if opt.foot => dom.footroot.classList.remove \d-none
    if opt.toggle => for k,v of opt.toggle => dom[k].style.display = if v => \inline-block else \none
    if opt.style => for k,v of opt.style => dom[k].style <<< v
    if opt.timer => setTimeout (-> ldcv.set!), opt.timer
    fire evt, \beforeOpen
    ldcv.get!finally ->
      if opt.clone => document.body.removeChild root
      fire evt, \afterClose

  #ldAlert \failed,'your last action is not successful.',\success
  window.fire = ->
    ldAlert {
      title: \Failed
      desc: 'Your <b>last action</b> is not successful. more about your <b>last action</b> in the following link.'
      type: \error
      foot: '<a href="#">Why did this action fail?</a>'
      yes: \hello
      toggle:
        cancel: true
        closebtn: true
      style:
        root: background: "linear-gradient(45deg,rgba(0,0,0,.5),rgba(255,255,255,.5))"
      event:
        beforeOpen: -> console.log \beforeOpen, it
        afterClose: -> console.log \afterClose, it
      #timer: 1000
    }
      .then -> console.log "got value: ", it
)!
