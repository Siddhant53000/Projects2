//
//  TranslatorViewController2.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 6/20/13.
//
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "LanguageSelectorController.h"
#import "TranslatorItemView.h"
#import "BingTranslator.h"
#import "MBProgressHUD.h"
#import "TutViewController.h"
#import <Google/Analytics.h>

@interface TranslatorViewController2 : AdInheritanceViewController <LanguageSelectorControllerDelegate, TranslatorItemViewDelegate, BingTranslatorProtocol, MBProgressHUDDelegate, UITextViewDelegate>


@property (nonatomic, strong) NSString * fromLang;
@property (nonatomic, strong) NSString * toLang;
@property (nonatomic, strong) NSString * textToTranslate;
@property (nonatomic, strong) BingTranslator * bingTranslator;
@property (nonatomic, strong) TutViewController *tut;
@property (nonatomic,strong) UIButton *removeTutBtn;

@end
