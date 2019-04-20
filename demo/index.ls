
ldcv = new ldCover {root: document.querySelector('.ldcv'), transition: "ld ld-bounce-in"}

show = ->
  ldcv.get!then -> console.log \ok, it
