/* wizDevTools - IOS debug toolkit for PhoneGap
 *
 * @author Ally Ogilvie
 * @copyright 2012 WizCorp Inc. [ Incorporated Wizards ]
 * @file wizDevToolsPlugin.h for PhoneGap
 *
 */

#import <Foundation/Foundation.h>

#import <Cordova/CDVPlugin.h>

@interface wizDevToolsPlugin : CDVPlugin
+ (wizDevToolsPlugin *) sharedInstance;
- (CDVPlugin *)initWithWebView:(UIWebView *)webView;
- (void)ready:(CDVInvokedUrlCommand*)command;
@end