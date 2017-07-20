//
//  BallView.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 5/5/13.
//
//

#import "BallView.h"

@interface BallView ()

@property (nonatomic, strong) NSArray * yArray;
@property (nonatomic, strong) NSArray * ballImageViewArray;
@property (nonatomic, strong) UIImageView * barImageView;

@end

@implementation BallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//array with the y coordinates as NSNumber
- (void) setYCoor:(NSArray *) array
{
    self.yArray=nil;
    [self.ballImageViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.barImageView removeFromSuperview];
    self.ballImageViewArray=nil;
    self.barImageView=nil;
    
    if ([array count]>=2)
    {
        array = [array sortedArrayUsingSelector:@selector(compare:)];
        CGFloat min = [[array objectAtIndex:0] floatValue];
        CGFloat max= [[array lastObject] floatValue];
        
        UIImage * barImage=[UIImage imageNamed:@"BallBar"];
        barImage = [barImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 0, 0, 0)];
        self.barImageView=[[UIImageView alloc] initWithImage:barImage];
        self.barImageView.frame=CGRectMake(3.5, min, 3, max-min);
        [self addSubview:self.barImageView];
        
        NSMutableArray * mut=[NSMutableArray arrayWithCapacity:[array count]];
        for (NSNumber * number in array)
        {
            CGFloat y=[number floatValue];
            UIImageView * imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ball"]];
            imageView.frame=CGRectMake(0, y - 5, 10, 10);
            [self addSubview:imageView];
            
            [mut addObject:imageView];
        }
        self.ballImageViewArray=mut;
        self.yArray=array;
    }
}

- (void) adjustExistingYCoor:(NSArray *) array
{
    if (([self.yArray count]==[array count]) && ([array count]>=2))
    {
        array = [array sortedArrayUsingSelector:@selector(compare:)];
        CGFloat min = [[array objectAtIndex:0] floatValue];
        CGFloat max= [[array lastObject] floatValue];
        
        self.barImageView.frame=CGRectMake(3.5, min, 3, max-min);
        
        for (NSInteger i=0; i < [self.ballImageViewArray count]; i++)
        {
            CGFloat y = [[array objectAtIndex:i] integerValue];
            UIImageView * imageView=[self.ballImageViewArray objectAtIndex:i];
            imageView.frame=CGRectMake(0, y - 5, 10, 10);
        }

        self.yArray=array;
    }
}

@end
