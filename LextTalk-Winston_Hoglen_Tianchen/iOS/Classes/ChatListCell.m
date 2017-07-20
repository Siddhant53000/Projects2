//
//  ChatListCell.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 6/5/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "ChatListCell.h"

@implementation ChatListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //NSLog(@"Anchura contentView: %f", self.contentView.bounds.size.width);
        //NSLog(@"Anchura cell: %f", self.bounds.size.width);
        
        self.learningImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 12.5, 39, 35)];
        [self.contentView addSubview:self.learningImageView];
        
        self.userImageShadow=[[UIView alloc] initWithFrame:CGRectMake(45, 5, 50, 50)];
        self.userImageShadow.backgroundColor=[UIColor clearColor];
        self.userImageShadow.layer.cornerRadius = 25.0;
        self.userImageShadow.layer.shadowColor = [[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] CGColor];
        self.userImageShadow.layer.shadowOpacity = 1.0;
        self.userImageShadow.layer.shadowRadius = 3;
        self.userImageShadow.layer.shadowOffset = CGSizeMake(0, 0);
        [self.contentView addSubview:self.userImageShadow];
        
        self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.userImageView.layer.cornerRadius = 25.0;
        self.userImageView.layer.masksToBounds=YES;
        [self.userImageShadow addSubview:self.userImageView];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 0, 50, 50);
        _button.layer.cornerRadius = 25.0;
        _button.layer.masksToBounds=YES;
        [self.userImageShadow addSubview:_button];
        
        self.activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50 -13, 0, 13, 13)];
        [self.userImageShadow addSubview:self.activityImageView];
        
        self.speakingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(96, 12.5, 39, 43)];
        [self.contentView addSubview:self.speakingImageView];
        
        self.userLabel=[[UILabel alloc] initWithFrame:CGRectMake(140, 10, 175, 20)];
        self.userLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:18];
        self.userLabel.backgroundColor=[UIColor clearColor];
        self.userLabel.textColor=[UIColor blackColor];
        self.userLabel.textAlignment=NSTextAlignmentLeft;
        self.userLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.userLabel];
        //AO
        //self.messageLabel=[[UITextView alloc] initWithFrame:CGRectMake(140, 35, 175, 16)];
        //
        self.messageLabel=[[UILabel alloc] initWithFrame:CGRectMake(140, 35, 175, 16)];
        self.messageLabel.font=[UIFont fontWithName:@"Ubuntu-Medium" size:13];
        self.messageLabel.backgroundColor=[UIColor clearColor];
        //AO
        //self.messageLabel.editable=NO;
        //self.messageLabel.dataDetectorTypes=UIDataDetectorTypeLink;
        //
        self.messageLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.messageLabel.textAlignment=NSTextAlignmentLeft;
        self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.messageLabel];
    }
    return self;
}


- (void) setUnreadMessages:(NSInteger)unreadMessages
{
    _unreadMessages = unreadMessages;
    
    //Accesory View
    UIImageView * imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Disclosure"]];
    if (unreadMessages == 0)
    {
        imageView.frame=CGRectMake(0, 0, 9, 14);
        self.accessoryView=imageView;
    }
    else
    {
        UIView * accesoryView=[[UIView alloc] init];
        //NSString * badgeStr=[NSString stringWithFormat:@"%d", self.unreadMessages];
        NSString * badgeStr=[NSString stringWithFormat:@"%ld", (long)unreadMessages];
        
        UIFont *font = [UIFont fontWithName:@"Ubuntu-Bold" size:12];
        CGSize constraintSize ;
        constraintSize = CGSizeMake(100, CGFLOAT_MAX);
        CGRect textRect = [badgeStr boundingRectWithSize:constraintSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:font}
                                                 context:nil];
        CGSize labelSize = textRect.size;
        labelSize.height=labelSize.height + 2.0;
        labelSize.width=labelSize.width + 2.0;
        if (labelSize.width<20) labelSize.width=20;
        UILabel * label=[[UILabel alloc] init];
        label.font=font;
        label.text=badgeStr;
        label.textAlignment=NSTextAlignmentCenter;
        label.layer.cornerRadius=5.0;
        label.clipsToBounds=YES;
        //label.backgroundColor=[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
        label.backgroundColor=[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0];
        label.textColor=[UIColor whiteColor];
        
        //Rect para la view contenedora
        CGFloat height=labelSize.height;
        if (height<12) height=12;
        CGFloat width= labelSize.width + 9 + 4;
        accesoryView.frame=CGRectMake(0, 0, width, height);
        
        //Rect para la etiqueta
        label.frame=CGRectMake(0, (height -labelSize.height)/2.0, labelSize.width, labelSize.height);
        //Rect para el imageView
        imageView.frame=CGRectMake(labelSize.width + 4, (height - 14)/2.0, 9, 14);
        
        [accesoryView addSubview:label];
        [accesoryView addSubview:imageView];
        self.accessoryView=accesoryView;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    //NSLog(@"Anchura contentView: %f", self.contentView.bounds.size.width);
    //NSLog(@"Anchura cell: %f", self.bounds.size.width);
    CGRect frame = self.userLabel.frame;
    if ([self.messageLabel.text length] == 0)
        frame.origin.y = 20;
    else
        frame.origin.y = 10;
    self.userLabel.frame = frame;
}


+ (CGFloat) height
{
    return 60;
}


@end
