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


## License

MIT
