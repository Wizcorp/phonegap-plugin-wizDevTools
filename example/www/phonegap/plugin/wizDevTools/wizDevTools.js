/* WizDevTools for PhoneGap - Wizard Development Tools!
*
 * @author Ally Ogilvie
 * @copyright 2012 WizCorp Inc. [ Incorporated Wizards ]
 * @file - wizDevTools.js
 * @about - JavaScript PhoneGap bridge for extra utilities 
 *
 *
*/

if (window.cordova) {
    window.document.addEventListener("deviceready", function () {
        cordova.exec(null, null, "wizDevToolsPlugin", "ready", []);
    }, false);
}
