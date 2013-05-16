/* wizDevTools - IOS debug toolkit for PhoneGap
 *
 * @author Ally Ogilvie
 * @copyright 2012 WizCorp Inc. [ Incorporated Wizards ]
 * @file wizDevToolsPlugin.m for PhoneGap
 *
 */


#import "wizDevToolsPlugin.h"

@interface wizDevToolsPlugin()
- (void) fireExceptionDebugEventWithJSONString:(NSString*)jsonString;
@end

#ifndef NDEBUG // Never build this plugin in RELEASE (will otherwise get rejected by Apple) !
#import <Cordova/CDVJSON.h>
#import <objc/runtime.h>


@class WebView;
@class WebScriptCallFrame;
@class WebFrame;

NSMutableDictionary* SOURCES = nil;

@interface Source : NSObject
@property (nonatomic)         int       baseLine;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSArray*  lines;
@end

@interface CallFrameInfo : NSObject
@property (nonatomic) int sid;
@property (nonatomic) int lineNumber;
@end

@implementation Source
@synthesize baseLine;
@synthesize url;
@synthesize lines;

- (void) dealloc
{
    self.url = nil;
    self.lines = nil;
    [super dealloc];
}
@end

@implementation CallFrameInfo
@synthesize sid;
@synthesize lineNumber;
@end

char callFramesKey;

@implementation UIWebView(ExceptionDebug)
- (void)    webView:(WebView *)webView
failedToParseSource:(NSString *)source
     baseLineNumber:(NSUInteger)lineNumber
            fromURL:(NSURL *)url
          withError:(NSError *)error
        forWebFrame:(WebFrame *)webFrame
{
    int lineno = 0;
    id lineValue = [[error userInfo] objectForKey:@"WebScriptErrorLineNumber"];
    if (lineValue) {
        lineno = [lineValue integerValue] - lineNumber;
    }

    NSString* line = [[source componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] objectAtIndex:lineno];

    id exception = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"Failed to parse JavaScript at line %d: %@", lineno, line], @"message",
                    @"ParseError", @"type",
                    nil];

    id documentURL = [[webFrame performSelector:@selector(DOMDocument)] URL];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [webView performSelector:@selector(mainFrameTitle)], @"mainFrameTitle",
                          documentURL,              @"documentURL",
                          exception,                @"exception",
                          nil];
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&err];
    __block NSString* json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[wizDevToolsPlugin sharedInstance] fireExceptionDebugEventWithJSONString:json];
        [json release];
    }];
}

- (void)webView:(WebView *)webView
 didParseSource:(NSString *)source
 baseLineNumber:(int)lineNumber
        fromURL:(NSURL *)url
       sourceId:(int)sid
    forWebFrame:(WebFrame *)webFrame
{
    Source* src  = [[[Source alloc] init] autorelease];
    src.baseLine = lineNumber;
    src.url      = [url absoluteString];
    src.lines    = [source componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (!src.url) src.url = @"<evaluated>";

    NSLog(@"PARSED SOME JAVASCRIPT!");
    NSLog(@"            Web view: %@", webView);
    NSLog(@"    Base line number: %d", lineNumber);
    NSLog(@"                  ID: %d", sid);
    NSLog(@"                 URL: %@", url);
    NSLog(@"     Number of lines: %i", [src.lines count]);
#ifdef EXCEPTION_DEBUG_LOG_SOURCE
    NSLog(@"         Source code: %@", src.lines);
#endif

    if (!SOURCES) {
        SOURCES = [[NSMutableDictionary alloc] init];
    }

    [SOURCES setObject:src forKey:[NSNumber numberWithInt:sid]];
}

- (void)  webView:(WebView *)webView
didEnterCallFrame:(WebScriptCallFrame *)frame
         sourceId:(int)sid
             line:(int)lineno
      forWebFrame:(WebFrame *)webFrame
{
    NSMutableDictionary* callFrames = objc_getAssociatedObject(webView, &callFramesKey);
    if (!callFrames) {
        callFrames = [[[NSMutableDictionary alloc] init] autorelease];
        objc_setAssociatedObject(webView, &callFramesKey, callFrames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    CallFrameInfo* callFrameInfo = [[[CallFrameInfo alloc] init] autorelease];
    callFrameInfo.sid = sid;
    callFrameInfo.lineNumber = lineno;
    [callFrames setObject:callFrameInfo forKey:[NSValue valueWithNonretainedObject:frame]];
}

- (void)   webView:(WebView *)webView
willLeaveCallFrame:(WebScriptCallFrame *)frame
          sourceId:(int)sid
              line:(int)lineno
       forWebFrame:(WebFrame *)webFrame
{
    NSMutableDictionary* callFrames = objc_getAssociatedObject(webView, &callFramesKey);
    if (callFrames)
        [callFrames removeObjectForKey:[NSValue valueWithNonretainedObject:frame]];
}

- (void)   webView:(WebView *)webView
exceptionWasRaised:(WebScriptCallFrame *)frame
        hasHandler:(BOOL)hasHandler
          sourceId:(int)sid
              line:(int)lineno
       forWebFrame:(WebFrame *)webFrame
{
    // Ignore exeptions that are handled
    if (hasHandler) {
        return;
    }

    // Ignore errors triggered by Cordova in blank pages
    id documentURL = [[webFrame performSelector:@selector(DOMDocument)] URL];
    if ([documentURL isEqualToString:@"about:blank"]) {
        return;
    }

    id exception = [frame  performSelector:@selector(exception)];
    NSString* type = nil;
    NSString* message = nil;

    @try  {
        type = [exception valueForKey:@"name"];
        message = [exception valueForKey:@"message"];
    }
    @catch (NSException* exc) {
        if ([exception isKindOfClass:[NSString class]]) {
            message = exception;
            type = @"String";
        }
    }

    if (!type) type = @"Error";
    if (!message) message = @"<unknown error>";

    exception = [NSDictionary dictionaryWithObjectsAndKeys:
                 message, @"message",
                 type, @"type",
                 nil];

    // Build the callstack
    NSMutableDictionary* callFrames = objc_getAssociatedObject(webView, &callFramesKey);
    WebScriptCallFrame* tmp = frame;
    NSMutableArray* callStack = [[[NSMutableArray alloc] init] autorelease];
    while (tmp) {
        NSString* functionName = [tmp performSelector:@selector(functionName)];
        if (!functionName) functionName = @"<anonymous>";
        CallFrameInfo* callFrameInfo = [callFrames objectForKey:[NSValue valueWithNonretainedObject:tmp]];
        Source* callFrameSource = [SOURCES objectForKey:[NSNumber numberWithInt:callFrameInfo.sid]];
        int realLineNumber = callFrameInfo.lineNumber - callFrameSource.baseLine;
        NSNumber* callFrameLineNumber = [NSNumber numberWithInt:realLineNumber];
        NSString* callFrameLine = nil;
        // incase real line number and lines of source code are out of sync, make this check. (Thanks Apple.. T-T)
        if (realLineNumber >=0 && realLineNumber<[callFrameSource.lines count])
            callFrameLine = [callFrameSource.lines objectAtIndex:realLineNumber];

        [callStack addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              functionName,        @"functionName",
                              callFrameSource.url, @"url",
                              callFrameLineNumber, @"lineNumber",
                              callFrameLine,       @"line",
                              nil]];
        tmp = [tmp performSelector:@selector(caller)];
    }

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          callStack,                @"callStack",
                          [webView performSelector:@selector(mainFrameTitle)], @"mainFrameTitle",
                          documentURL,              @"documentURL",
                          exception,                @"exception",
                          nil];
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&err];
    __block NSString* json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[wizDevToolsPlugin sharedInstance] fireExceptionDebugEventWithJSONString:json];
        [json release];
    }];
}

- (void)webView:(id)sender didClearWindowObject:(id)windowObject forFrame:(WebFrame*)frame
{
    if ([sender respondsToSelector:@selector(setScriptDebugDelegate:)]) {
        [sender performSelector:@selector(setScriptDebugDelegate:) withObject:self];
    }
}
@end
#endif

static wizDevToolsPlugin* instance = nil;


#import "WizDebugLog.h"
#include <unistd.h>

@implementation wizDevToolsPlugin


+ (wizDevToolsPlugin*)sharedInstance {
    return instance;
}



- (CDVPlugin*)initWithWebView:(UIWebView*)webView {
    self = [super initWithWebView:webView];
    if (self) {
        if (instance)
            [instance dealloc];

        instance = self;
        NSLog(@"wizDevToolsPlugin initialized.");
    }
    return self;
}

- (void)dealloc {
    instance = nil;
    [super dealloc];
}




- (void)ready:(CDVInvokedUrlCommand*)command {
    // Function called by Javascript to have PhoneGap load the plugin
    [self writeJavascript: [[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] toSuccessCallbackString:command.callbackId]];
}

- (void) fireExceptionDebugEventWithJSONString:(NSString*)jsonString {
    NSLog(@"*** EXCEPTION_DEBUG: %@", jsonString);

    NSString* script = [NSString stringWithFormat:@"setTimeout(function(){var e=window.document.createEvent('Events');e.initEvent('exceptionDebug',true,true);e.data=%@;window.dispatchEvent(e)},0)", jsonString];

    [[self webView] stringByEvaluatingJavaScriptFromString:script];
}

@end
