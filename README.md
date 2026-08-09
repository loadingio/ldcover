# ldcover

vanilla popup / dialog library.


## Usage

install with npm:

    npm install ldcover

include required files ( `index.js` and `index.css` ), and create a ldcover object:

    var ldcv = new ldcover({ ... });


## Constructor Options

 - `root`: container.
   - you can use `template` tag as root for better performance during initialization. The first child in the template will be used as the real root for this ldcover.
 - `type`: additional class to add. default: ''. space seprated.
 - `transform-fix`: true/false. default: false.
   add a 'shown' class after ldcover is shown, which removes transform from .inner block.
   useful when content is blurred due to transform, but might lead to glitches when doing transition. use it carefully.
 - `delay`: milliseconds. default 300. should be aligned with transition duration. use to control 'shown' and 'running' classes.
 - `autoZ`: update root's z-index automatically. default true.
 - `baseZ`: the minimal z-index of root. default 3000.
   - with autoZ, ldcover keeps track of all cover' z-index and always use larger z-index for newly toggled covers.
     baseZ is then used as a base value for all autoZ covers.
     however, this may conflict with customized zmgr.
 - `zmgr`: set z-index manager for this cover.
   - `baseZ` will be used to call zmgr, which set a lower bound of `z-index`.
     set `baseZ` to 0 for zmgr to correct work with lower values.
 - `animation`: optional space separated class list.
   - will be added to .inner node when toggling on, and removed when toggling off.
   - handy for adding customized animation from libraries like transition.css or animate.css.
 - `escape`: should pressing escape key close the dialog. boolean, default true, optional.
 - `lock`: default false. if set to true, only API or data-ldcv-set could close this modal.
 - `resident`: default false. if set to true, DOM for this cover will always attached under document. otherwise false.
   - not resident node will be attached under `container` or document.body.
 - `inPlace`: default true. if set to false, root will be removed from original parent and re-added under body.
 - `container`: container for non-resident cover. by default parent of DOM or document.body
   - by default, non-resident cover is inserted to the location we find it. Set `container` to change this behavior.
     - when `container` is null, `root` is appended at the end of `document.body` when toggled.
     - otherwise, `root`is appended at the end of `container` when toggled.


## Object Methods

 - `toggle(state, data)`: toggle on/off ldcover.
   - `data`: optional parameter, which will be sent in `data` event.
     - program that manages the content of this cover can use this data to update its content.
 - `get(data)`: toggle on ldcover and return a promise, which will only be resolved when ldcover.set is called.
   - `data`: see `toggle` above.
 - `set(v, hide=true)`: set value, which resolve promises from get, and hide ldcover if hide = true.
   - use `data-ldcv-set` on elements to automatically set value when elements are clicked.
 - `cancel(err, hide=true)`: reject promise returned by `get` with given error `err`.
   - a default `Error` object with `{name: 'lderror', id: 999}` will be used if `err` is omitted.
   - ldcover is hidden if `hide` = true. true by default.
   - use `data-ldcv-cancel` on elements to automatically cancel when clicked.
 - `on(event, cb)`: listen to certain event. evnets:
   - `toggle.on`: when ldcover is toggled on. may fired before shown.
   - `toggle.off`: when ldcover is toggled off. may fired before hidden.
   - `toggled.on`: when ldcover is toggled on. fired after shown.
   - `toggled.off`: when ldcover is toggled off. fired after hidden.
 - `isOn()`: is this modal active ( opened ). return true or false
 - `lock()`: lock this cover. ( can't be dismissed by escaping )
   - alternatively, you can lock cover by adding `data-lock="true"` attribute to cover root.
 - `root()`: get cover root node.
 - `zmgr(mgr)`: set z-index manager for this cover. return the zmgr used if `mgr` is omitted.
   - `baseZ` will be used to call zmgr, which set a lower bound of `z-index`.
     set `baseZ` to 0 for zmgr to correct work with lower values.
 - `append(node)`: insert `node` in the base node of this cover.
   - useful if this ldcover is created without root.
 - `destroy(opt)`: object destroyer. `opt` is an option object with following fields:
   - `removeNode`: should ldcover remove DOM of this cover. default false
     - by default, DOM of this cover will be inserted back in DOM after this ldcover object been destroyed.
     - to also wipe out the DOM element, set `removeNode` to true.


## Class Method

 - `zmgr(zmgr)`: set a shared z-index manager. useful to manager widget z-index globally.
   this manager should provide following methods:
   - `add(baseVal, size)`: return actual added value.
     - baseVal: hint value for the z-index we'd like to use
     - size: hint size about how large the object we added is
   - `remove(val)`: remove val ( returned by add ) from this manager.

   as described above, `baseZ` will be used to call zmgr, which set a lower bound of `z-index`.
   set `baseZ` to 0 in ldcover instance so zmgr can work correclty with lower values.


## Spec. and structure

A simple ldcover popup are built with following html structure:

 * .ldcv          - topmost, fullscreen container
   * .base        - control the overall size and position for this box ( could be omit )
     * .inner     - dialog container. constraint size. transition animation goes here


one can decorate ldcover widgets by adding classes over the outmost element. following classes are defined by default:

 * .ldcv.bare:
   - no covered bk.
   - custom position for .ldcv > .base
   - overflow: visible for .ldcv > .base > .inner (why?)
 * .ldcv.lg, .ldcv.md
   - different size of panel. instead of using this, you could also set size directly on .base element.
 * .ldcv.full - fullscreen modal.
 * .ldcv.full-sm, .ldcv.full-md, .ldcv.full-lg - conditional fullscreen modal. break point:
   - `sm`: < 576px
   - `md`: < 768px
   - `lg`: < 960px
 * .ldcv.light - light overlay bk
 * .ldcv.mini - non-blocking, float style dialog with following position available:
   - .ldcv.mini.left
   - .ldcv.mini.right
   - .ldcv.mini.top
   - .ldcv.mini.bottom
 * .ldcv.inline - inline cover. Won't affect local layout

 * centering
   - by default .base is centered with vertical-align + ::after pseudo class. instead you can choose different methods, described below:
   - .ldcv.margin-centered
     - center with margin: auto + left/right/top/bottom: 0 and position: absolute. need width/height to be provided.
   - .ldcv.transform-centered
     - with transform-center, .base is centered with left: 50%, top: 50% + transform: translate(-50%,-50%), which don't need width/height to be provided anymore.
     - NOTE: this might causes content to be blur, so use it carefully.

 * .ldcv.scroll:
   - add `scroll` class on the ldcv node when you expect the modal content to longer than a screen's height. It makes the modal scrollable by users.

 * .ldcv.autogap:
   - add `autogap` class on the ldcv node to automatically adjust cover padding and margin along with responsive scenario, with two additional classes:
   - `.outer-gap`: only apply margin style. Used alone without `autogap`
   - `.autogap.nested-gap`: apply padding style in nested div. Used along with `autogap`

 * alternative transition
   - you can use alternative transition by adding additional class in .ldcv, including following classes:
     - ldcv-scale
     - ldcv-zoom
     - ldcv-vortex
     - ldcv-slide-rtl
     - ldcv-slide-ltr
     - ldcv-slide-ttb
     - ldcv-slide-btt
     - ldcv-flip-h-left
     - ldcv-flip-h-right
     - ldcv-flip-v-top
     - ldcv-flip-v-bottom
     - ldcv-fade
   - example of setting a alternative transition:


    <div class="ldcv ldcv-scale"> ... </div>



## Action

Simple popup could be configured with automatically set invocation to resolve promises waited by get. use `data-ldcv-set` attribute on elements to indicate what values to be passed into set:

    <div class="ldcv">
      <button data-ldcv-set="1"> OK </button>
      <button data-ldcv-set="0"> Cancel </button>
    </div>

use get function to wait for the return value:

    ldcv.get!then -> if it == "1" => "OK" else "Cancel"


## Dialog

promise-based dialog helpers as drop-in replacements for the browser native `alert()` / `confirm()` / `prompt()`:

    await ldcover.alert('hi');                  // resolves after OK is clicked
    ok = await ldcover.confirm('are you sure?') // true ( OK ) / false ( cancel / escape )
    name = await ldcover.prompt('your name?')   // string ( OK ) / null ( cancel / escape )

the first argument can be a message ( string / DOM node ) or an option object with `msg` inside; an additional option object can also be passed as the 2nd argument:

    await ldcover.confirm({title: 'Delete', msg: 'are you sure?', danger: true});
    await ldcover.confirm('are you sure?', {danger: true});  // same thing

common options for `alert` / `confirm` / `prompt` ( all optional ):

 - `title`: dialog title.
 - `msg`: message. plain text ( rendered with `pre-wrap`, so newlines work ) or a DOM node.
 - `okText`: label of the OK button. default `OK`.
 - `cancelText`: label of the cancel button. default `Cancel`.
 - `variant`: variant of the OK option. default `primary`; use `danger` for destructive confirms. any string works - it lands as a semantic class on the button and is looked up in the theme's `button` map ( see Theming ).
 - `size`: `sm` / `md` / `lg`. default `md`.
 - `cls`: additional classes added on the `.ldcv` root, for theming.

i18n is left to the caller - pass localized `okText` / `cancelText` / `msg` yourself.

`prompt` additionally supports:

 - `placeholder`: input placeholder.
 - `value`: default value.
 - `type`: input type. default `text`.
 - `isRequired`: if true, OK won't resolve until the field is filled.


### ldcover.dialog(opt)

generic method behind the helpers above. returns a Promise resolving `{value, fields}` where `value` is the value of the clicked option ( button ) and `fields` is an object of input values keyed by field name. closing by escape / backdrop click always resolves with `value: null`.

 - `title`: optional title.
 - `msg`: message. plain text ( `pre-wrap` ) or a DOM node.
 - `fields`: optional input fields: `[{name, label?, type='text', placeholder?, value?, isRequired?, error?, cls?}]`.
   - `type: 'textarea'` renders a textarea.
   - `error`: message shown when `isRequired` validation fails. default `This field is required.`.
   - `cls`: additional classes added on the input / textarea element.
 - `options`: buttons: `[{label, value, variant?, focus?, novalidate?, action?, cls?}]`.
   - `variant`: semantic variant of this option, added as a class on the button in every theme. bundled ( styled by bundled themes ): `default` / `primary` / `danger`; any other string also works - style it yourself, or map it in your theme's `button` map.
   - `focus`: focused on open ( when no fields ); also triggered by Enter in input fields.
   - `novalidate`: skip required validation for this option. options with `value: null` ( cancel-ish ) skip validation automatically.
   - `action`: `({fields}) -> ...` - clicking this option runs the callback and keeps the dialog open, instead of resolving. useful for opening nested dialogs or custom in-dialog behavior.
   - `cls`: additional classes added on the button element.
 - `escape`: allow closing by escape key / backdrop click. default true.
 - `size`: `sm` / `md` / `lg`.
 - `theme`: visual theme, added as a class on the `.ldcv` root. bundled: `default` / `bootstrap` / `generic`. defaults to `ldcover.dialog.theme()` ( initially `generic` ). see Theming below.
 - `cls`: additional classes added on the `.ldcv` root.

example:

    ldcover.dialog({
      title: 'Rename',
      msg: 'enter a new name:',
      fields: [{name: 'name', isRequired: true}],
      options: [
        {label: 'Cancel', value: null},
        {label: 'Rename', value: 'ok', variant: 'primary', focus: true}
      ]
    }).then(function(r) { if (r.value == 'ok') { console.log(r.fields.name); } });

dialogs can be stacked; z-index is managed by the same autoZ mechanism used by ldcover instances. each call builds its own cover, which is destroyed and removed from DOM automatically after dismissed.


### Theming

structural styles ( layout / spacing / sizes ) always apply under `.ldcv.builtin`; all visual styles ( font size / color / background / border ) live in a separate theme class on the root, picked by the `theme` option:

 - `generic` ( the default ): no visual styles at all. the dialog is structurally correct but unstyled - style it yourself via the class hooks below.
 - `default`: bundled standalone look. neutral colors, no dependency.
 - `bootstrap`: applies bootstrap's own classes onto the elements while building the dialog - `form-control` on inputs / textareas, `btn btn-primary` for OK, `btn btn-outline-secondary` for cancel, `btn btn-danger` for danger, `is-invalid` on inputs failing required validation. requires bootstrap css to be loaded on the page.

set a session-wide default once instead of passing `theme` on every call ( call with no argument to read it back ):

    ldcover.dialog.theme('bootstrap');

themes that inject element classes ( like `bootstrap` ) are defined in the `ldcover.dialog.themes` registry - register your own for utility-css frameworks ( e.g. tailwind ):

    ldcover.dialog.themes.tailwind = {
      input: 'border rounded px-3 py-2 w-full',
      textarea: 'border rounded px-3 py-2 w-full',
      invalid: 'border-red-500',
      error: 'text-red-600 text-sm',
      button: {
        "default": 'px-4 py-2 rounded border',
        primary: 'px-4 py-2 rounded bg-blue-600 text-white',
        danger: 'px-4 py-2 rounded bg-red-600 text-white'
      }
    };
    ldcover.dialog.theme('tailwind');

a theme entry may define `title` / `msg` / `fields` / `field` / `label` / `input` / `textarea` / `error` / `options` / `button` ( string, or a per-variant map ) / `invalid` ( toggled on inputs by required validation ).

the theme name also lands as a class on the `.ldcv` root ( `.ldcv.builtin.my-theme` ), so a custom theme can also just be visual css defined under it:

    .ldcv.builtin        // dialog root; .sm / .md / .lg for size.
                         // .autogap and .scroll are also added by default,
                         // for rwd gapping and long-content scrolling
      .base .inner
        .title
        .msg             // pre-wrap
        .fields
          .field         // label + input/textarea + .error
                         // .has-error is added when required validation fails
        .options
          button         // with variant class: .default / .primary / .danger

the skeleton itself can also be replaced by overriding `ldcover.dialog.dom`, a function returning the root element of a dialog. keep the `.base` / `.inner` structure and the `.title` / `.msg` / `.fields` / `.options` hooks inside `.inner`; user provided content is applied onto the skeleton via DOM api ( no innerHTML ), so the skeleton should contain static markup only.


## Todo

 - implement all this nice transitional effect:
   - https://tympanus.net/Development/ModalWindowEffects/
   - https://tympanus.net/Development/PageTransitions/


## License

MIT
