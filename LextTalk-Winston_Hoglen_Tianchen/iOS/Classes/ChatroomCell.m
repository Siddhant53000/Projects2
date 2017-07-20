//
//  ChatroomCell.m
//  LextTalk
//
//  Created by Yo on 8/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChatroomCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ChatroomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //NSLog(@"Anchura contentView: %f", self.contentView.bounds.size.width);
        //NSLog(@"Anchura cell: %f", self.bounds.size.width);
        
        self.langImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7.5, 39, 35)];
        [self.contentView addSubview:self.langImageView];
        
        
        self.nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(45, 5, 270, 20)];
        self.nameLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:18];
        self.nameLabel.backgroundColor=[UIColor clearColor];
        self.nameLabel.textColor=[UIColor blackColor];
        self.nameLabel.textAlignment=NSTextAlignmentLeft;
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.nameLabel];
        
        self.usersLabel=[[UILabel alloc] initWithFrame:CGRectMake(45, 30, 270, 16)];
        self.usersLabel.font=[UIFont fontWithName:@"Ubuntu-Medium" size:13];
        self.usersLabel.backgroundColor=[UIColor clearColor];
        self.usersLabel.textColor=[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.usersLabel.textAlignment=NSTextAlignmentLeft;
        self.usersLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.usersLabel];
    }
    return self;
}


- (void) setDisclosureText:(NSString *)disclosureText
{
    _disclosureText = disclosureText;
    
    //Accesory View
    UIImageView * imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Disclosure"]];
    if ([_disclosureText length] == 0)
    {
        imageView.frame=CGRectMake(0, 0, 9, 14);
        self.accessoryView=imageView;
    }
    else
    {
        UIView * accesoryView=[[UIView alloc] init];
        
        UIFont *font = [UIFont fontWithName:@"Ubuntu-Bold" size:12];
        CGSize constraintSize ;
        constraintSize = CGSizeMake(100, CGFLOAT_MAX);
        CGRect textRect = [_disclosureText boundingRectWithSize:constraintSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:font}
                                                        context:nil];
        CGSize labelSize = textRect.size;
        labelSize.height=labelSize.height + 2.0;
        labelSize.width=labelSize.width + 2.0;
        if (labelSize.width<20) labelSize.width=20;
        UILabel * label=[[UILabel alloc] init];
        label.font=font;
        label.text=_disclosureText;
        label.textAlignment=NSTextAlignmentCenter;
        label.layer.cornerRadius=5.0;
        label.clipsToBounds=YES;
        //label.backgroundColor=[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
        label.backgroundColor=[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0];
        label.textColor=[UIColor whiteColor];
        
        //Rect para la view contenedora
        CGFloat height=labelSize.height;
        if (height<12) height=12;
        CGFloat width= labelSize.width + 9 + 4;//9 de la felcha y 4 de separación
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

/*
 - (void) layoutSubviews
 {
 [super layoutSubviews];
 //NSLog(@"Anchura contentView: %f", self.contentView.bounds.size.width);
 //NSLog(@"Anchura cell: %f", self.bounds.size.width);
 }
 */

+ (CGFloat) height
{
    return 50;
}

@end
