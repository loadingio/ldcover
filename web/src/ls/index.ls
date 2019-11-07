(->
  ldcv = new ldCover root: '.ldcv'
  fire = (...args) ->
    dom = Array.from(ldcv.root.querySelectorAll('[data-name]'))
    hash = {}
    dom.map (d) ->
      name = d.getAttribute(\data-name)
      hash[name] = d

    if typeof(args.0) == \object => opt = args.0
    else opt = { title: args.0, desc: args.1, type: args.2 }
    hash["title"].innerHTML = opt.title
    hash["desc"].innerHTML = opt.desc
    hash["icon"].setAttribute(
      \src, 
      "assets/img/#{opt.type}.svg"
    )
    hash["cancel"].style.display = "none"
    ldcv.get!
  fire \failed,'your last action is not successful.',\error

)!
