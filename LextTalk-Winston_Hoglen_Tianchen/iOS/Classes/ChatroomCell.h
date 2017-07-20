//
//  ChatroomCell.h
//  LextTalk
//
//  Created by Yo on 8/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatroomCell : UITableViewCell

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * usersLabel;
@property (nonatomic, strong) UIImageView * langImageView;
@property (nonatomic) NSString * disclosureText;

+ (CGFloat) height;

@end
