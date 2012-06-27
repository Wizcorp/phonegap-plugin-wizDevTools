/* wizDevTools - IOS debug toolkit for PhoneGap
 *
 * @author Ally Ogilvie
 * @copyright 2012 WizCorp Inc. [ Incorporated Wizards ]
 * @file wizDevToolsPlugin.m for PhoneGap
 *
 */


#import "wizDevTools.h"
#import "WizUtils.h"
#import "WizDebugLog.h"
#include <unistd.h>

@implementation wizDevTools

#define CONSOLEURL @"http://dev.wizcorp.jp:8585/client/"

/**
 
 TOOL : JS Console - add a Javascript console above the main view
 
 **/

-(void) loadJSConsole:(PhoneGapDelegate*)phonegap
{
    // get Device width and heigh
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    
    // create console and display logs
    jsDebugView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth, screenHeight/2)];
    jsDebugView.tag = 51;
    [[[jsDebugView subviews] lastObject] setScrollEnabled:NO];
    
    
    // get uuid
    NSString* deviceId = [WizUtils deviceId];
    
    // load source
    NSString *consoleURL = CONSOLEURL;
    NSString *urlString = [NSString stringWithFormat:@"%@#%@",consoleURL,deviceId];
    [jsDebugView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    // default start hidden
    jsDebugView.hidden = TRUE;
    
    // add console to window
    [phonegap.window addSubview:jsDebugView];
    
    UITapGestureRecognizer *tapForJSDebugView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleJSConsole:)];
    [tapForJSDebugView setNumberOfTouchesRequired:3];
    [phonegap.window addGestureRecognizer:tapForJSDebugView];
    [tapForJSDebugView release];
    
    UITapGestureRecognizer *rebootForJSDebugView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rebootJSConsole:)];
    [rebootForJSDebugView setNumberOfTouchesRequired:2];
    [jsDebugView addGestureRecognizer:rebootForJSDebugView];
    [rebootForJSDebugView release];
    
}

- (IBAction)rebootJSConsole:(id)sender
{
    WizLog(@"[DEV TOOLS] reboot JSConsole");
    // get uuid
    NSString* deviceId = [WizUtils deviceId];
    
    // reboot source
    NSString *consoleURL = CONSOLEURL;
    NSString *urlString = [NSString stringWithFormat:@"%@#%@",consoleURL,deviceId];
    [jsDebugView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
}


-(void) showJSConsole
{
    [jsDebugView setHidden:FALSE];
}

-(void) hideJSConsole
{
    [jsDebugView setHidden:TRUE];  
}


- (IBAction)toggleJSConsole:(id)sender {
    
    // get Device width and heigh
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    
    if ([jsDebugView isHidden] == 0) {
        if (consoleSmallMode){
            [self hideJSConsole];            
        } else {
            consoleSmallMode = TRUE;
            jsDebugView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight/4);
        }
    } else {
        consoleSmallMode = FALSE;
        jsDebugView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight/2);
        [self showJSConsole];
    }
}








/**
 
 TOOL : Native Console - - add a Native console above the main view
 
 **/

-(void) loadNativeConsole:(PhoneGapDelegate*)phonegap
{
    if ([self redirectNSLog]) {
        
        // get Device width and heigh
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        CGFloat screenWidth = screenRect.size.width;
        
        // create console and display logs
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth, screenHeight/3)];
        textView.backgroundColor = [UIColor blackColor];
        textView.textColor = [UIColor whiteColor];
        textView.editable = FALSE;
        textView.scrollEnabled = TRUE;
        textView.scrollsToTop = FALSE;
        textView.tag = 50;
        
        
        // default start hidden
        textView.hidden = TRUE;
        consoleVisible = FALSE;
        
        // add consolse to window
        [phonegap.window addSubview:textView];
        
        // add timer to write content out
        wizLogWriter = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(writeLog:) userInfo:nil repeats:TRUE]; 
        
        UILongPressGestureRecognizer *holdForNativeConsole = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNativeConsole:)];
        [holdForNativeConsole setNumberOfTouchesRequired:3];
        [phonegap.window addGestureRecognizer:holdForNativeConsole];
        [holdForNativeConsole release];
        
    }
    
}


- (BOOL)redirectNSLog
{
    
    
    // Create log file with path to app documents
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * gamePath = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString * filePath = [documentsPath stringByAppendingFormat:@"/%@/%@", gamePath, @"WizLog.txt"];
    
    
    [@"" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    id fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!fileHandle) {
        // NOT existing, try to create
        NSFileManager *filemgr;
        filemgr =[NSFileManager defaultManager];
        NSString * dirPath = [documentsPath stringByAppendingFormat:@"/%@", gamePath];
        
        // created new
        if ([filemgr createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error: NULL] == YES) {
            // write again
            [@"" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            // check again
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            if (!fileHandle) {
                return NSLog(@"no file found, Opening log failed"), NO;
            }
        } else {
            return NSLog(@"cannot create dir, Opening log failed"), NO;
        }
    } 
    
    [fileHandle retain];
    
    // Redirect stderr
    int err = dup2([fileHandle fileDescriptor], STDERR_FILENO);
    if (!err) {
        [fileHandle release];
        return	NSLog(@"Couldn't redirect stderr"), NO;
    }
    
    [fileHandle release];
    
    return YES;
}




- (void)logIt {
    
    // Create a pool  
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    // path to app documents
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * gamePath = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString * filePath = [documentsPath stringByAppendingFormat:@"/%@/%@", gamePath, @"WizLog.txt"];
    
    if (filePath) {  
        
        NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        if (myText) {  
            if (textView) {
                // [self updateWizConsole:myText];
                
                [self performSelectorOnMainThread:@selector(updateWizConsole:) withObject:myText waitUntilDone:YES];
            }
            
        }  
    }
    
    [pool release];
}


- (void) updateWizConsole:(NSString*)myText
{
    
    [textView setText:myText];
    // [self.window bringSubviewToFront:textView];
    
}


-(void) showNativeConsole
{
    [textView setHidden:FALSE];
}
-(void) hideNativeConsole
{
    [textView setHidden:TRUE];
}


- (IBAction)writeLog:(id)sender {
    
    [self performSelectorInBackground:@selector(logIt) withObject:NULL];
    
}

- (IBAction)toggleNativeConsole:(id)sender {
    
    
    // get Device width and heigh
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    if (consoleVisible) {
        if (consoleSmallMode){
            consoleVisible = FALSE;
            [self hideNativeConsole];            
        } else {
            consoleSmallMode = TRUE;
            textView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight/4);
        }
    } else {
        consoleVisible = TRUE;
        consoleSmallMode = FALSE;
        textView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight/2);
        [self showNativeConsole];
    }
}





/**
 
 TOOL : RebootEnforcer - main view rebooter
 
 **/

-(void) loadRebootEnforcer:(UIWebView*)theWebView phonegap:(PhoneGapDelegate*)phonegap
{
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:phonegap action:@selector(rebooter:)];
    [tapper setNumberOfTouchesRequired:2];
    [theWebView addGestureRecognizer:tapper];
    [tapper release];
}





@end