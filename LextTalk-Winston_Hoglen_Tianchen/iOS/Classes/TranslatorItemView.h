//
//  TranslatorItemView.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 6/22/13.
//
//

#import <UIKit/UIKit.h>

@class TranslatorItemView;

@protocol TranslatorItemViewDelegate <NSObject>

@optional
- (void) speakButtonPressedIn:(TranslatorItemView *) trans withId:(NSInteger) index;
- (void) dicOrChatButtonPressedIn: (TranslatorItemView *) trans;

@end

@interface TranslatorItemView : UIView

@property (nonatomic, strong) NSArray * speakArray;
@property (nonatomic, assign) BOOL showsDic;
@property (nonatomic, assign) BOOL buttonVisible;

@property (nonatomic, strong, readonly) UITextView * textView;

@property (nonatomic, weak) id<TranslatorItemViewDelegate> delegate;


@end
