//
//  CustomTabBarController.h
//  LextTalk
//
//  Created by Yo on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBarController : UITabBarController
    {
        UIButton * mapButton;
        UIButton * chatButton;
        UIButton * profileButton;
        UIButton * translatorButton;
        UIButton * chatRoomButton;
        UIButton * settingsButton;
        
        BOOL notFirstTime;
    }
    
    @property (nonatomic, strong) UIButton * mapButton;
    @property (nonatomic, strong) UIButton * chatButton;
    @property (nonatomic, strong) UIButton * profileButton;
    @property (nonatomic, strong) UIButton * translatorButton;
    @property (nonatomic, strong) UIButton * chatRoomButton;
    @property (nonatomic, strong) UIButton * settingsButton;
    
-(void) hideExistingTabBar;
-(void) addCustomElements;
-(void) selectTab:(NSInteger)tabID;
    
-(void) setBadgeValue:(NSString *) str atPosition:(NSInteger) position;
-(void) setSecondBadgeAtPosition:(NSInteger) position;
-(void) removeAllBadges;
- (void) removeAllSecondBadges;
-(void) removeBadgeAtPosition:(NSInteger) pos;
-(void) removeSecondBadgeAtPosition:(NSInteger) pos;
    
@end
