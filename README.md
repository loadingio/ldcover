# ldCover

vanilla popup / dialog library.


## Usage

var ldcv = new ldCover({ ... });

configurations:

 * root: container.
 * type: additional class to add. default: ''. space seprated. 
 * transform-fix: true/false. default: false.
   add a 'shown' class after ldCover is shown, which remove transform from .inner block.
   useful when content is blurred due to transform, but might lead to glitches when doing transition. use it carefully.
 * delay: milliseconds. default 300. should be aligned with transition duration. use to control 'shown' and 'running' classes.
 * auto-z: update root's z-index automatically. default true.
 * base-z: the minimal z-index of root. default 1000.
   - with auto-z, ldCover keeps track of all cover' z-index and always use larger z-index for newly toggled covers. base-z is then used as a base value for all auto-z covers.



Methods:
 * toggle(state): toggle on/off ldCover.
 * get(): toggle on ldCover and return a promise, which will only be resolved when ldCover.set is called.
 * set(v, hide=true): set value, which resolve promises from get, and hide ldCover if hide = true.
 * on(event, cb): listen to certain event. evnets:
   - toggle.on: when ldCover is toggled on.
   - toggle.off: when ldCover is toggled off.


## Spec. and structure

A simple ldCover popup are built with following html structure:

 * .ldcv          - topmost, fullscreen container
   * .base        - control the overall size and position for this box ( could be omit )
     *  .inner     - dialog container. constraint size. transition animation goes here


one can decorate ldCover widgets by adding classes over the outmost element. following classes are defined by default:

 * .ldcv.bare:
   - no covered bk.
   - custom position for .ldcv > .base
   - overflow: visible for .ldcv > .base > .inner (why?)

 * .ldcv.transform-center
   - by default .base is centered with margin: auto. this needs us to provide width/height for .base.
   - with transform-center, .base is centered with left: 50%, top: 50% + transform: translate(-50%,-50%), which don't need width/height to be provided anymore.
   - NOTE: this might causes content to be blur, so use it carefully.


## Todo

 * implement all this nice transitional effect:
   - https://tympanus.net/Development/ModalWindowEffects/
   - https://tympanus.net/Development/PageTransitions/


## License

MIT
