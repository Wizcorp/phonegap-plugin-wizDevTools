/* wizDevTools - IOS debug toolkit for PhoneGap
 *
 * @author Ally Ogilvie
 * @copyright 2012 WizCorp Inc. [ Incorporated Wizards ]
 * @file wizDevToolsPlugin.h for PhoneGap
 *
 */

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#ifdef PHONEGAP_FRAMEWORK
#import <PhoneGap/PGPlugin.h>
#else
#import "PGPlugin.h"
#endif

@interface UIWebView(ExceptionDebug)
@end


@interface wizDevToolsPlugin : PGPlugin
    + (wizDevToolsPlugin*) sharedInstance;
    - (PGPlugin*)initWithWebView:(UIWebView*)webView;
    - (void)ready:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
@end
