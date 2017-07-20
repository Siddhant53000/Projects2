//
//  TutViewController.m
//  LextTalk
//
//  Created by Winston Lee on 10/11/16.
//
//

#import <Foundation/Foundation.h>
#import "TutViewController.h"

@interface TutViewController ()
@property (nonatomic, strong) UIView * panel;
@property (nonatomic, strong) UIImageView *tutImgView;
@property (nonatomic, strong) UILabel *tutText;
@end

@implementation TutViewController
- (id) init
{
    self=[super init];
    if (self)
    {
        
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        //self.view.alpha = 0.5;
        self.panel = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-(100/2), 0, 100, 100)];
        self.tutImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.center.x)-(self.view.frame.size.width/4), 150.0, self.view.frame.size.width/2, self.view.frame.size.width/2)];
        [self.tutImgView setImage:[UIImage imageNamed:@"mapflags"]];
        [self.view addSubview:self.tutImgView];
        self.tutImgView.alpha = 1.0;
        //self.tutText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400.0, 50.0)];
        [self.view addSubview:self.tutText];
        
        self.tutText = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
        
        [self.tutText setTextColor:[UIColor whiteColor]];
        [self.tutText setBackgroundColor:[UIColor clearColor]];
        [self.tutText setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
        [self.tutText setText:
         @"Click on the flags on the map to view individual user profiles!"];
        [self.tutText setTextAlignment:UITextAlignmentCenter];

        [self.view addSubview:self.tutText];
        self.tutText.center = CGPointMake(self.tutImgView.center.x, self.tutImgView.center.y+(self.tutImgView.frame.size.height/2)+20.0);
        self.tutText.lineBreakMode = NSLineBreakByWordWrapping;
        self.tutText.numberOfLines = 0;
        
    }
    return self;
}

- (void) changeTutImage:(UIImage *)image{
    [self.tutImgView setImage:image];
}

- (void) changeTutText:(NSString *)text{
    [self.tutText setText:text];
    ;
}

- (void) doneLearning{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismissed");
    }];
}
@end

