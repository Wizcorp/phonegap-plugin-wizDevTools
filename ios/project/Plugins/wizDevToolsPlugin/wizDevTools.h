/* wizDevTools - IOS debug toolkit for PhoneGap
 *
 * @author Ally Ogilvie
 * @copyright 2012 WizCorp Inc. [ Incorporated Wizards ]
 * @file wizDevToolsPlugin.h for PhoneGap
 *
 */

#import <Foundation/Foundation.h>

#import <PhoneGap/PhoneGapDelegate.h>

@interface wizDevTools : PhoneGapDelegate {
    UIWebView* jsDebugView;
    UITextView* textView;
    bool consoleSmallMode;
    bool consoleVisible;
    NSTimer* wizLogWriter;
    
    
}



- (void) loadJSConsole:(PhoneGapDelegate*)phonegap;
- (void) showJSConsole;
- (void) hideJSConsole;


- (BOOL) redirectNSLog;
- (IBAction) writeLog:(id)sender;
- (void) logIt;
- (void) loadNativeConsole:(PhoneGapDelegate*)phonegap;
- (void) showNativeConsole;
- (void) hideNativeConsole;

- (void) loadRebootEnforcer:(UIWebView*)theWebView phonegap:(PhoneGapDelegate*)phonegap;

@end