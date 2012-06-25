/* OpenFeintPlugin - IOS side of the bridge to openFeintPlugin JavaScript for PhoneGap
 *
 * @author WizCorp Inc. [ Incorporated Wizards ] 
 * @copyright 2011
 * @file OpenFeintPlugin.m for PhoneGap
 *
 */ 

#import "OpenFeintPlugin.h"
#import <OpenFeint/OpenFeint.h>
#import <OpenFeint/OFUser.h>
#import "WizDebugLog.h"

#import <PhoneGap/JSON.h>


@implementation OpenFeintPlugin

@synthesize window;
@synthesize currentUser;
@synthesize	friends;
@synthesize getFriendCBid;



- (void)invoke:(NSArray*)arguments withDict:(NSDictionary*)options
{
    WizLog(@"[OpenFeintPlugin] ******* invoke OpenFeint ");
    
    NSString *ofKey;
    NSString *ofSecret;
    NSString *gameName;
    NSString *callbackId = [arguments objectAtIndex:0];
    
    PluginResult* pluginResult;

    WizLog(@"Options:%@", options);
    
    if (options) 
	{
        ofKey    = [options objectForKey:@"gameKey"];
        ofSecret = [options objectForKey:@"gameSecret"];
        gameName = [options objectForKey:@"gameName"];
    
    
    window.frame = [UIScreen mainScreen].bounds;
    //[window addSubview:rootController.view];
    [window makeKeyAndVisible];
	
	NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:UIInterfaceOrientationPortrait], OpenFeintSettingDashboardOrientation,
							  @"SampleApp", OpenFeintSettingShortDisplayName,
							  [NSNumber numberWithBool:YES], OpenFeintSettingEnablePushNotifications,
							  [NSNumber numberWithBool:NO], OpenFeintSettingDisableUserGeneratedContent,
  							  [NSNumber numberWithBool:NO], OpenFeintSettingAlwaysAskForApprovalInDebug,
                              //  [NSNumber numberWithInt:OFDevelopmentMode_DEVELOPMENT], OpenFeintSettingDevelopmentMode,
                              [NSNumber numberWithInt:OFDevelopmentMode_RELEASE], OpenFeintSettingDevelopmentMode,
							  window, OpenFeintSettingPresentationWindow,
							  nil
							  ];
    


    
    /*
     ofDelegate = [SampleOFDelegate new];
     ofNotificationDelegate = [SampleOFNotificationDelegate new];
     ofChallengeDelegate = [SampleOFChallengeDelegate new];
     ofBragDelegate = [SampleOFBragDelegate new];
     */
    
    /*
     OFDelegatesContainer* delegates = [OFDelegatesContainer containerWithOpenFeintDelegate:ofDelegate
     andChallengeDelegate:ofChallengeDelegate
     andNotificationDelegate:ofNotificationDelegate];
     delegates.bragDelegate = ofBragDelegate;
     */
    
    
    
	[OpenFeint initializeWithProductKey:ofKey
							  andSecret:ofSecret
						 andDisplayName:gameName
							andSettings:settings
						   andDelegates:nil];
    
    // [OFUser setDelegate:self];
    // [OFCurrentUser setDelegate:self];
    
    // Initialize some dictionaries
    // getFriendCallbackArray = [[NSMutableDictionary alloc] init];
    
        pluginResult = [PluginResult resultWithStatus:PGCommandStatus_OK];
   
    } else {
        pluginResult = [PluginResult resultWithStatus:PGCommandStatus_ERROR messageAsString:@"noParam"];
    }
    
    
    
    [self writeJavascript: [pluginResult toSuccessCallbackString:callbackId]];
    
    
}


- (void) openDashboard:(NSArray*)arguments withDict:(NSDictionary*)options
{
     WizLog(@"[OpenFeintPlugin] ******* Opening OpenFeint Dashboard");
    [OpenFeint launchDashboard];
}


- (void) getCurrentUser:(NSArray*)arguments withDict:(NSDictionary*)options
{
    WizLog(@"[OpenFeintPlugin] ******* getCurrentUser OpenFeint ");
    
    NSUInteger argc = [arguments count];
    NSString *callbackId = [arguments objectAtIndex:0];
    if (argc < 1) {
        // Send Exception
        PluginResult* pluginResult = [PluginResult resultWithStatus:PGCommandStatus_ERROR messageAsString:@"noParam"];
        [self writeJavascript: [pluginResult toSuccessCallbackString:callbackId]];
        
		return;	
	}
    
    
    currentUser = [OFCurrentUser currentUser];
                          
    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:
                              currentUser.userId,                                                             @"userId",
                              currentUser.name,                                                               @"name",
                              [NSString stringWithFormat:@"%f",currentUser.latitude],                         @"latitude",
                              [NSString stringWithFormat:@"%f",currentUser.longitude],                        @"longitude",
                              [NSString stringWithFormat:@"%d",currentUser.followsLocalUser],                 @"followsLocalUser",
                              currentUser.resourceId,                                                         @"mId",
                              [NSString stringWithFormat:@"%d",currentUser.usesFacebookProfilePicture],       @"usesFacebookProfilePicture",
                              [NSString stringWithFormat:@"%d",currentUser.gamerScore],                       @"score",
                              [NSString stringWithFormat:@"%@",currentUser.profilePictureUrl],                @"pictureUrl",
                              [NSString stringWithFormat:@"%d",currentUser.online],                           @"online",
                              nil];
   
    
    WizLog(@"User Data:%@", userData);
    
    PluginResult* pluginResult = [PluginResult resultWithStatus:PGCommandStatus_OK messageAsDictionary:userData];
    [self writeJavascript: [pluginResult toSuccessCallbackString:callbackId]];
    
}


- (void) getFriends:(NSArray *)arguments withDict:(NSDictionary *)options
{
    WizLog(@"[OpenFeintPlugin] ******* getFriends OpenFeint ");
    
    NSString *callbackId = [arguments objectAtIndex:0];
    NSString *resourceId;
    
    // NSMutableArray *currentUserGetFriendArray;
    // WizLog(@"Options:%@", arguments);
    
    
    self.getFriendCBid = callbackId;
    [OFUser setDelegate: self];
    
    
    if ([arguments count] > 0) 
	{
        // take out resource id from array.
        resourceId = [[arguments objectAtIndex:1]stringValue]; 
        
        WizLog(@"extracted resourceId: %@", resourceId);
        [OFUser getUser : resourceId];
        
    } else {
        
        // no resourceId specified, fetch and use current users id.
        currentUser = [OFCurrentUser currentUser];
        // resourceId = currentUser.resourceId;
        // WizLog(@"fetch resourceId:%@", resourceId);
        [currentUser getFriends];
    }

    WizLog(@"[OpenFeintPlugin] ******* getFriends - waiting result... callbackId:%@", callbackId);
    
    
    /*
    WizLog(@"currentUserGetFriendArray:%@", currentUserGetFriendArray);
    currentUserGetFriendArray = [getFriendCallbackArray objectForKey:resourceId];
    WizLog(@"currentUserGetFriendArray: %@", currentUserGetFriendArray);
    
    if([currentUserGetFriendArray count] == 0){
        
        OFRequestHandle* handle = [currentUser getFriends];
        
        if(!handle)
        {
            WizLog(@"Did not get request handle from OFUser's getFriends");
        }
        [getFriendCallbackArray setObject:[NSMutableArray arrayWithObject:callbackId] forKey:currentUser.userId];
    }
    else if([currentUserGetFriendArray indexOfObject:callbackId] == NSNotFound)
    {
        [currentUserGetFriendArray addObject:callbackId];
    }
     */
    
}


- (void)didGetFriendsWithThisApplication:(NSArray*)follows OFUser:(OFUser*)myFriends {
    
    WizLog(@"myFrineds:%@", follows);
}


- (void)didFailGetFriendsWithThisApplication:(NSArray*)follows OFUser:(OFUser*)myFriends{
    
    WizLog(@"Failed to get frineds:%@", myFriends);
}


- (void)didGetUser:(OFUser*)user {
    WizLog(@"[OpenFeintPlugin] ******* Got user success");

    // NSString *resourceId = user.resourceId;
    // WizLog(@"fetch resourceId:%@", resourceId);
    [user getFriends];
    
}


- (void)didFailGetUser {
    WizLog(@"[OpenFeintPlugin] ******* Fail to get user");
    
    PluginResult* pluginResult = [PluginResult resultWithStatus:PGCommandStatus_ERROR];
    WizLog(@"[OpenFeintPlugin] ******* getFriends - returning result...callbackId: %@", self.getFriendCBid);
    [self writeJavascript: [pluginResult toSuccessCallbackString:self.getFriendCBid]];
}


- (void)didFailGetFriendsOFUser:(OFUser*)user
{
    WizLog(@"[did NOT get friends] **** function: ");
}


- (void)didGetFriends:(NSArray*)follows OFUser:(OFUser*)user
{

    // NSMutableArray *friendsHolder = [[NSMutableArray alloc] init];
    
    if ([follows count] > 1){
        // More than one friend
        NSMutableArray *friendList = [[NSMutableArray alloc] init];
        for (OFUser *follower in follows)
        {
            
            [friendList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   follower.userId,                                                             @"userId",
                                   follower.name,                                                               @"name",
                                   [NSString stringWithFormat:@"%f",follower.latitude],                         @"latitude",
                                   [NSString stringWithFormat:@"%f",follower.longitude],                        @"longitude",
                                   [NSString stringWithFormat:@"%d",follower.followsLocalUser],                 @"followsLocalUser",
                                   follower.resourceId,                                                         @"mId",
                                   [NSString stringWithFormat:@"%d",follower.usesFacebookProfilePicture],       @"usesFacebookProfilePicture",
                                   [NSString stringWithFormat:@"%d",follower.gamerScore],                       @"score",
                                   [NSString stringWithFormat:@"%@",follower.profilePictureUrl],                @"pictureUrl",
                                   [NSString stringWithFormat:@"%d",follower.online],                           @"online",
                                   nil]];

        }
        WizLog(@"Friend Data:%@", friendList);

        NSArray *friendsHolder = [[NSArray alloc] initWithArray:friendList copyItems:YES];
        
        PluginResult* pluginResult = [PluginResult resultWithStatus:PGCommandStatus_OK messageAsArray:friendsHolder];
        WizLog(@"[OpenFeintPlugin] ******* getFriends - returning result...callbackId: %@", self.getFriendCBid);
        [self writeJavascript: [pluginResult toSuccessCallbackString:self.getFriendCBid]];
        
        
        [friendsHolder release];
        [friendList release];
        
    } else {
        
        // 1 or less friends hahaha
        for (OFUser *follower in follows)
        {
            
           NSDictionary *friendList = [NSDictionary dictionaryWithObjectsAndKeys:
                                       follower.userId,                                                             @"userId",
                                       follower.name,                                                               @"name",
                                       [NSString stringWithFormat:@"%f",follower.latitude],                         @"latitude",
                                       [NSString stringWithFormat:@"%f",follower.longitude],                        @"longitude",
                                       [NSString stringWithFormat:@"%d",follower.followsLocalUser],                 @"followsLocalUser",
                                       follower.resourceId,                                                         @"mId",
                                       [NSString stringWithFormat:@"%d",follower.usesFacebookProfilePicture],       @"usesFacebookProfilePicture",
                                       [NSString stringWithFormat:@"%d",follower.gamerScore],                       @"score",
                                       [NSString stringWithFormat:@"%@",follower.profilePictureUrl],                @"pictureUrl",
                                       [NSString stringWithFormat:@"%d",follower.online],                           @"online",
                                       nil];
            
            WizLog(@"Friend Data:%@", friendList);
            PluginResult* pluginResult = [PluginResult resultWithStatus:PGCommandStatus_OK messageAsDictionary:friendList];
            
            WizLog(@"[OpenFeintPlugin] ******* getFriends - returning result...callbackId: %@", self.getFriendCBid);
            [self writeJavascript: [pluginResult toSuccessCallbackString:self.getFriendCBid]];
           
        }
        
    }
	
       
    
    /*
    NSMutableArray *callbackArray = [getFriendCallbackArray objectForKey:user.userId];
    
    if([callbackArray count] > 0)
    {
        NSMutableArray *to_delete = [[NSMutableArray alloc] init];
        
        for(NSString *callbackId in callbackArray)
        {
            NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
            
            PluginResult* pluginResult = [PluginResult resultWithStatus:PGCommandStatus_OK messageAsString: [[friendList JSONRepresentation] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            
            [self writeJavascript: [pluginResult toSuccessCallbackString:callbackId]];
            
            [to_delete addObject:callbackId];
            
            [loopPool drain];
        }
        
        for (NSString *callbackId in to_delete)
        {
            [callbackArray removeObject:callbackId];
        }
        
        [to_delete release];
        
        if([callbackArray count] == 0)
        {
            [getFriendCallbackArray removeObjectForKey:user.userId];
        }
        
        
    }

    [friendList release];
     
     */
}


@end