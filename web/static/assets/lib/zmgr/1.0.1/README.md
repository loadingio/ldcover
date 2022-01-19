# zmgr

manage stackable values such as z-index.


## Install

    npm install zmgr


## Usage

include `dist/index.js` then:

    mgr = new zmgr({...})
    ret1 = mgr.add 100, 1
    ret2 = mgr.add 100, 1
    mgr.remove ret1
    mgr.remove ret2


## Constructor options

 - `init`: default value. optional.
   - if provided, the first added value will be updated based on `init` and `step`:
     - if step > 0: max(init, added) will be used
     - if step < 0: min(init, added) will be used
 - `step`: amount of increase between `add` function calls. default 1 if omitted.
   - can be negative, indicating a decreased value.


## API

 - `add(v,s)`: use a certain  `v`. Return assigned value to use.
   - params:
     - `v`: expected z-index. 
     - `s`: custom step. direction is ignored.

 - `remove(v)`: remove a used value from zmgr.


## Layered Values

You can use multiple `zmgr` with different `init` value to better separate values for different purpose. For example, assume we have some dialogs to popup. Some of them are just hints and some of them are important message and users must interact with them.

We can thus use 2 `zmgr` for configuring them `z-index` accordingly:

    manager = do
      prompt: new zmgr init: 10000
      hint: new zmgr init: 100

    ldcv = do
      prompt1: new ldcover zmgr: manager.prompt
      prompt2: new ldcover zmgr: manager.prompt
      hint1: new ldcover zmgr: manager.hint
      hint2: new ldcover zmgr: manager.hint




## Fallback

While zmgr is necessary for aligning values such as `z-index` across components, we can prepare a fallback one if zmgr is not available ( example in livescript ):

    zmgr = do
      add: (v) -> @[]s.push(z = Math.max(v or 0, (@s[* - 1] or 0) + 1)); return z
      remove: (v) -> if (i = @[]s.indexOf(v)) < 0 => return else @s.splice(i,1)


## License

MIT
