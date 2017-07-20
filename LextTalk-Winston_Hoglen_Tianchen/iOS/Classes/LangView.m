//
//  LangView.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 5/5/13.
//
//

#import "LangView.h"
#import "IconGeneration.h"
#import <QuartzCore/QuartzCore.h>

#define kOffset 2.0

@interface LangView ()

@property (nonatomic, strong) NSArray * flagButtons;
@property (nonatomic, strong) UIButton * selectButton;

@property (nonatomic, strong) NSArray * langs;
@property (nonatomic, strong) NSArray * flags;

@end

@implementation LangView

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

- (CGFloat) setLanguages:(NSArray *) langs2 withFlags:(NSArray *) flags2 speaking:(BOOL) speaking withButton:(BOOL) button
{
    [self.flagButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.flagButtons=nil;
    self.langs=nil;
    self.flags=nil;
    
    CGFloat width=0.0;
    if (([langs2 count] == [flags2 count]))
    {
        CGFloat x=0, y;
        if (speaking)
            y=(self.bounds.size.height - 43.0) / 2.0;
        else
            y=(self.bounds.size.height - 35.0) / 2.0;
        
        NSMutableArray * mut=[NSMutableArray arrayWithCapacity:[langs2 count]];
        for (NSInteger i=0; i<[langs2 count]; i++)
        {
            UIImage * image;
            if (speaking)
                image = [IconGeneration smallWithGlowIconForSpeakingLan:[langs2 objectAtIndex:i] withFlag:[[flags2 objectAtIndex:i] integerValue]];
            else
                image = [IconGeneration smallWithGlowIconForLearningLan:[langs2 objectAtIndex:i] withFlag:[[flags2 objectAtIndex:i] integerValue]];
            
            UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:image forState:UIControlStateNormal];
            button.adjustsImageWhenDisabled=NO;
            button.tag=i;
            [button addTarget:self action:@selector(flagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

            if (speaking)
            {
                button.frame=CGRectMake(x, y, 39.0, 43.0);
                x += 39.0 + kOffset;
            }
            else
            {
                button.frame=CGRectMake(x, y, 39.0, 35.0);
                x += 39.0 + kOffset;
            }
            [self addSubview:button];
            [mut addObject:button];
        }
        self.flagButtons=mut;
        self.langs=langs2;
        self.flags=flags2;
        
        width = x - kOffset;
    }
    
    //Button
    if (self.selectButton==nil)
    {
        self.selectButton=[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * image=[UIImage imageNamed:@"button-profile-gray"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        [self.selectButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.selectButton setTitle:NSLocalizedString(@"SELECT", @"Profile") forState:UIControlStateNormal];
        self.selectButton.titleLabel.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
        self.selectButton.titleLabel.textColor=[UIColor whiteColor];
        [self addSubview:self.selectButton];
        
        self.selectButton.layer.shadowColor=[[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        self.selectButton.layer.shadowOpacity = 1.0;
        self.selectButton.layer.shadowRadius = 2;
        self.selectButton.layer.shadowOffset = CGSizeMake(0, 2);
        self.selectButton.clipsToBounds=NO;
    }
    self.selectButton.frame=CGRectMake(width + 10, (self.bounds.size.height - 28) / 2.0, 75, 28);
    
    if (button)
    {
        self.selectButton.alpha=1.0;
        width = width + 10 + 75;
        
        for (UIButton * button in self.flagButtons)
            button.enabled=YES;
    }
    else
    {
        self.selectButton.alpha=0.0;
        
        for (UIButton * button in self.flagButtons)
            button.enabled=NO;
    }
    return width;
}

- (CGFloat) width
{
    CGFloat result=0.0;
    for (UIButton * button in self.flagButtons)
    {
        result += button.bounds.size.width + kOffset;
    }
    if (result > 0.1)
        result -= kOffset;
    if (self.selectButton.alpha>0.1)
        result += self.selectButton.bounds.size.width + 20.0;
    
    return result;
}

- (CGFloat) enableButton:(BOOL) enabled
{
    CGFloat result=0.0;
    
    for (UIButton * button in self.flagButtons)
    {
        result += button.bounds.size.width + kOffset;
    }
    if (result > 0.1)
        result -= kOffset;
    
    if (enabled)
    {
        result+=10;
        
        self.selectButton.alpha=1.0;
        
        result += 10 + 75;
        
        for (UIButton * button in self.flagButtons)
            button.enabled=YES;
    }
    else
    {
        self.selectButton.alpha=0.0;
        
        for (UIButton * button in self.flagButtons)
            button.enabled=NO;
    }
    
    return result;
}

- (void) flagButtonPressed:(UIButton *) button
{
    NSInteger index=button.tag;
    if ([self.delegate respondsToSelector:@selector(langView:selectedLang:withFlag:)])
        [self.delegate langView:self selectedLang:[self.langs objectAtIndex:index] withFlag:[[self.flags objectAtIndex:index] integerValue]];
}

@end
