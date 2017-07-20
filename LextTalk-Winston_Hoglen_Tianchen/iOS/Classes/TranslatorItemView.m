//
//  TranslatorItemView.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 6/22/13.
//
//

#import "TranslatorItemView.h"
#import "UIColor+ColorFromImage.h"

@interface TranslatorItemView ()

@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) NSMutableArray * buttonArray;
@property (nonatomic, strong) UIView * buttonArrayView;
@property (nonatomic, strong) UIButton * button;
@property (nonatomic, strong) UIView * buttonView;
@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation TranslatorItemView

- (void) initEverything
{
    self.backgroundColor = [UIColor whiteColor];
    
    //TextView
    self.textView = [[UITextView alloc] init];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.font=[UIFont fontWithName:@"Ubuntu-Bold" size:13];
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.textColor = [UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0];
    
    [self addSubview:self.textView];
    
    //Buttons, in this case, just a gray button not active
    self.buttonArrayView = [[UIView alloc] init];
    //self.buttonArrayView.backgroundColor = [UIColor colorFromImage:[UIImage imageNamed:@"button-gray"]];
    self.buttonArrayView.backgroundColor = [UIColor colorWithRed:0.874 green:0.874 blue:0.874 alpha:1.0];
    self.buttonArrayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.buttonArrayView];
    
    //Must init de array
    self.buttonArray = [NSMutableArray arrayWithCapacity:5];
    
    //Right button
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    UIImage * buttonImage=[UIImage imageNamed:@"button-blue"];
    buttonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    [self.button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:@"translator-bubble"] forState:UIControlStateNormal];
    self.button.adjustsImageWhenDisabled = NO;
    [self.button addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
    //sync property
    _buttonVisible = YES;
    
    self.buttonView = [[UIView alloc] init];
    self.buttonView.backgroundColor = [UIColor colorFromImage:[UIImage imageNamed:@"button-blue"]];
    self.buttonView.alpha = 0.0;
    self.buttonView.autoresizingMask = self.button.autoresizingMask;
    [self addSubview:self.buttonView];
    
    //ImageView
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"translator-audio"]];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    buttonImage=[UIImage imageNamed:@"button-green"];
    //buttonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    self.imageView.backgroundColor = [UIColor colorFromImage:buttonImage];
    [self addSubview:self.imageView];
}

- (void) layoutForFrame:(CGRect) frame
{
    /*
    if (frame.size.width < 60)
        frame.size.width = 60;
    if (frame.size.height < 80)
        frame.size.height = 80;
     */
    if ((frame.size.width>=60) && (frame.size.height>=51))
    {
        
        CGFloat textViewWidth = frame.size.width - 5 - 5 - 22.5;
        CGFloat textViewHeight = frame.size.height - 5 - 5 - 28.5;
        self.textView.frame = CGRectMake(5, 5, textViewWidth, textViewHeight);
        
        self.button.frame = CGRectMake(5 + textViewWidth + 5, 0, 22.5, frame.size.height - 28.5);
        self.buttonView.frame = self.button.frame;
        self.imageView.frame = CGRectMake(5 + textViewWidth + 5, frame.size.height - 28.5, 22.5, 28.5);
        
        //Calculate spacing for all the buttons
        //For the time being
        //for (UIButton * button in self.buttonArray)
        //    button.frame = CGRectMake(0, frame.size.height - 28.5, frame.size.width - 22.5, 28.5);
        
        self.buttonArrayView.frame = CGRectMake(0, frame.size.height - 28.5, frame.size.width - 22.5, 28.5);
        
        CGFloat width = frame.size.width - 22.5;
        CGFloat textWidth = 0;
        for (UIButton * button in self.buttonArray)
        {
            CGSize adjustedSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
            CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
            textWidth += size.width;
        }
        //does not take into accout the case where the texts are bigger than the space available
        //I remove from diff n-1 pixels to leave whites in the buttons
        CGFloat diff = width - textWidth - 1*([self.buttonArray count] -1);
        CGFloat margin = diff / [self.buttonArray count] / 2.0;
        CGFloat x=0;
        for (UIButton * button in self.buttonArray)
        {
            CGSize adjustedSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
            CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
            button.frame=CGRectMake(x, frame.size.height - 28.5, size.width + 2*margin, 28.5);
            x += size.width+2*margin + 1;//I add the pixel I removed before
        }
    }
}

- (void) setSpeakArray:(NSArray *)speakArray
{
    for (UIButton * button in self.buttonArray)
        [button removeFromSuperview];
    [self.buttonArray removeAllObjects];
    
    _speakArray = speakArray;
 
    
    //Just a disabled button to show a gray bar
    if ([_speakArray count]==0)
    {
        [self addSubview:self.buttonArrayView];
    }
    else
    {
        [self.buttonArrayView removeFromSuperview];
        
        NSInteger counter = 0;
        for (NSString * str in _speakArray)
        {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            UIImage * buttonImage=[UIImage imageNamed:@"button-gray"];
            buttonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
            [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"button-gray"] forState:UIControlStateNormal];
            button.enabled = YES;
            button.adjustsImageWhenDisabled = NO;
            
            [button setTitle:str forState:UIControlStateNormal];
            [button addTarget:self action:@selector(speakButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.textColor = [UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1.0];
            [button setTitleColor:[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:12];
            button.tag = counter;
            
            [self.buttonArray addObject:button];
            [self addSubview:button];
            
            counter++;
        }
    }

    //Adjust frame in any case
    [self layoutForFrame:self.frame];
}

- (void) setShowsDic:(BOOL)showsDic
{
    _showsDic = showsDic;
    
    if (showsDic)
        [self.button setImage:[UIImage imageNamed:@"translator-halfdic"] forState:UIControlStateNormal];
    else
        [self.button setImage:[UIImage imageNamed:@"translator-bubble"] forState:UIControlStateNormal];
}

- (void) setButtonVisible:(BOOL)buttonVisible
{
    _buttonVisible = buttonVisible;
    
    if (buttonVisible)
    {
        self.button.alpha = 1.0;
        self.buttonView.alpha = 0.0;
    }
    else
    {
        self.button.alpha = 0.0;
        self.buttonView.alpha = 1.0;
    }
}


#pragma mark - Calls to delegate
- (void) speakButtonPressed:(UIButton *) button
{
    if ([self.delegate respondsToSelector:@selector(speakButtonPressedIn:withId:)])
        [self.delegate speakButtonPressedIn:self withId:button.tag];
}

- (void) rightButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(dicOrChatButtonPressedIn:)])
        [self.delegate dicOrChatButtonPressedIn:self];
}


#pragma mark - UIView methods
- (id) init
{
    self = [super init];
    if (self)
    {
        [self initEverything];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //Nothing: If I call "initEverything" here, double views are added, and a ghost keyboard appears when tapping on certain areas
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self layoutForFrame:frame];
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutForFrame:self.frame];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
