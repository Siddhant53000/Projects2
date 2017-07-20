//
//  UICopyLabel.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 2/10/13.
//
//

#import <UIKit/UIKit.h>

//AO The original version created a UILabel object, replaced this with UITextView to make URLs clickable
@interface UICopyLabel : UILabel
//
//@interface UICopyLabel : UITextView
//
//AO

@property (nonatomic) BOOL showTranslate;

- (void) translate:(id)sender;

@end
