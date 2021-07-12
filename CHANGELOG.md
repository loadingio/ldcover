# Change Logs

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
