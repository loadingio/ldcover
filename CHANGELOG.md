# Change Logs

## v3.5.3

 - tweak style about gapping with `scroll` + `autogap` settings.
 

## v3.5.2

 - add `autogap` class for automatically prepare padding / gapping between window boundary


## v3.5.1

 - tweak fullscreen classes responsive settings


## v3.5.0

 - support conditional fullscreen class


## v3.4.0

 - support destroy function
 - remove escape listener once dialog is dismissed
 - clear inline cover click event listener variable once dismiss
 - fix bug: small gap in the left hand side due to :after pseudo class margin


## v3.3.1

 - fix bug: nested `data-ldcv-*` in child ldcover should not be propagated to parent ldcover.
 - upgrade modules to fix dependencies vulnerability


## v3.3.0

 - add `toggled.on` and `toggled.off` event for post toggle event


## v3.2.1

 - fix bug: when toggling off, z-index is updated too early, lead to unsmooth fading animaion sometimes.


## v3.2.0

 - add `data` parameter in `toggle` and `get` api for passing data between caller / callee.
 - add `data` event to pass data to callee


## v3.1.0

 - upgrade modules to fix dependencies vulnerability
 - add `inPlace` mode to decide if DOM should be re-added under body.


## v3.0.1

 - remove unnecessary `fs-extra` dependency


## v3.0.0

 - release with compact directory structure


## v2.1.2

 - add `style` field in `package.json`


## v2.1.1

 - use minimized dist file as main / browser default file
 - upgrade modules


## v2.1.0

 - support initializing DOM based on `template` tag for shadow DOM.
 - only insert DOM when cover is active. behavior controlled by `resident` option.
 - mangle + compress minimized js to optimize its size in advance.
 - lazy initializing until toggling if `root` is a template.
 - update document for undocumented features
 - member `root` is now a function for accessing `_r` (formal `root`)
 - support `inline` mode
   - modal displayed inline yet not affect layout
   - dismiss on clicking outside dialog


## v2.0.0

 - support `zmgr` directly in ldcover constructor
 - use zmgr fallback instead of zstack implementation to simplify code logic
 - remove legacy `ldCover` definition
 - update window object only if module is not available
 - rename `ldcv.*` to `index.*`
 - rename static method `set-zmgr` to `zmgr`
 - support multiple event syntax


## v1.3.3

 - add `cancel` api for canceling `get` call by promise rejection.
 - add `data-ldcv-cancel` directive corresponding to `cancel` api.


## v1.3.2

 - upgrade modules
 - add `ldcover` and deprecate `ldCover`


## v1.3.1

 - bug fix: move transition to `.running, .active` classes so there won't be a initial flash of dialog content.


## v1.3.0

 - add `setZmgr` for managing z-index globally.
 - update demo for testing `setZmgr`.


## v1.2.0

 - upgrade `template` and `livescript`
 - add `bootstrap.ldui` for development.
 - add `ldview` and `ldquery` for development.
 - tweak build script
 - refactor web/
 - add `mini` style ldcover.


## v1.1.1

 - fix bug: escape should not close all modals, but only the topmost modal.
   - as a side effect we add an ldcv list ( `popup` ) in ldCover object to track popup order.


## v1.1.0

 - add lock function
 - fix bug: incorrect z-index calculation for nested cover
 - change scrolling behavior - default no scrolling
 - add demo site code
