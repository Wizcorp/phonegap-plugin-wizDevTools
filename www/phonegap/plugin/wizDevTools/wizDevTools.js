/* WizDevTools for PhoneGap - Wizard Development Tools!
*
 * @author Ally Ogilvie
 * @copyright 2012 WizCorp Inc. [ Incorporated Wizards ]
 * @file - wizUtils.js
 * @about - JavaScript PhoneGap bridge for extra utilities 
 *
 *
*/

var wizDevTools = {
    ready: function() {
        return window.PhoneGap.exec(null, null, "wizDevToolsPlugin", "ready", []);
    }
};