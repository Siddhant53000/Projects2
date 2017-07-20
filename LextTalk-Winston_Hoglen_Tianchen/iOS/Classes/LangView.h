//
//  LangView.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 5/5/13.
//
//

#import <UIKit/UIKit.h>
@class LangView;

@protocol LangViewDelegate <NSObject>
@optional

- (void) langView:(LangView *) langView selectedLang:(NSString *) lang withFlag:(NSInteger) flag;

@end

@interface LangView : UIView

- (CGFloat) setLanguages:(NSArray *) langs2 withFlags:(NSArray *) flags2 speaking:(BOOL) speaking withButton:(BOOL) button;
- (CGFloat) width;
- (CGFloat) enableButton:(BOOL) enabled;

@property (nonatomic, strong, readonly) UIButton * selectButton;

@property (nonatomic, strong, readonly) NSArray * langs;
@property (nonatomic, strong, readonly) NSArray * flags;

@property (nonatomic, weak) id<LangViewDelegate> delegate;

@end
