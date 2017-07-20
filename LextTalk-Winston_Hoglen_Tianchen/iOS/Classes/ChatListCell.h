//
//  ChatListCell.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 6/5/13.
//
//

#import <UIKit/UIKit.h>

@interface ChatListCell : UITableViewCell

@property (nonatomic, strong) UILabel * userLabel;
@property (nonatomic, strong) UILabel * messageLabel;
@property (nonatomic, strong) UIImageView * userImageView;
@property (nonatomic, strong) UIView * userImageShadow;
@property (nonatomic, strong) UIImageView * activityImageView;
@property (nonatomic, strong) UIImageView * learningImageView;
@property (nonatomic, strong) UIImageView * speakingImageView;
@property (nonatomic, assign) NSInteger unreadMessages;

@property (nonatomic, strong, readonly) UIButton * button;

+ (CGFloat) height;

@end
