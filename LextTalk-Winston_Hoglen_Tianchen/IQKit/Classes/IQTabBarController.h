//
//  IQTabBarController.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQSkin.h"

@interface IQTabBarController: UITabBarController <IQSkinProtocol>{
	IBOutlet UITabBar *tabBar1;
}
@property(nonatomic, strong) UITabBar *tabBar1;
@end