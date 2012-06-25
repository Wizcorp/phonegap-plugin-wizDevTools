/* OpenFeintPlugin - IOS side of the bridge to openFeintPlugin JavaScript for PhoneGap
 *
 * @author WizCorp Inc. [ Incorporated Wizards ] 
 * @copyright 2011
 * @file OpenFeintPlugin.h for PhoneGap
 *
 */ 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PhoneGap/PGPlugin.h>
#import <OpenFeint/OFUser.h>
#import <OpenFeint/OFCurrentUser.h>


@interface OpenFeintPlugin : PGPlugin <OFUserDelegate>{
	UIWindow* window;
	OFUser* currentUser;
    NSArray *friends;
    NSString *getFriendCBid;
    
    NSMutableDictionary *getFriendCallbackArray;
    
    
    
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) OFUser *currentUser;
@property (nonatomic, retain) NSArray *friends;
@property (nonatomic, retain) NSString *getFriendCBid;


/* OpenFeint methods
 */
- (void)invoke:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)openDashboard:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)getCurrentUser:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)getFriends:(NSArray*)arguments withDict:(NSDictionary*)options;

@end
