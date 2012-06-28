/* wizDevTools - IOS debug toolkit for PhoneGap
 *
 * @author Ally Ogilvie
 * @copyright 2012 WizCorp Inc. [ Incorporated Wizards ]
 * @file wizDevToolsPlugin.h for PhoneGap
 *
 */

#import <Foundation/Foundation.h>

#ifdef CORDOVA_FRAMEWORK
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVCordovaView.h>
#else
#import "CDVPlugin.h"
#import "CDVCordovaView.h"
#endif

@interface CDVCordovaView(ExceptionDebug)
@end

@interface wizDevToolsPlugin : CDVPlugin
+ (ExceptionDebugPlugin*) sharedInstance;
- (CDVPlugin*)initWithWebView:(UIWebView*)webView;
- (void)ready:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
@end