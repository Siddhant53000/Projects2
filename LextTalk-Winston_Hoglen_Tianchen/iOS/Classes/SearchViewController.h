//
//  SearchViewController.h
// LextTalk
//
//  Created by nacho on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"
#import "LTDataSource.h"
#import "IQKit.h"
#import "LanguageSelectorViewController.h"
#import "LanguageSelectorController.h"
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController : AdInheritanceViewController < LTDataDelegate, IQLocalizableProtocol, LanguageSelectorControllerDelegate, LanguageSelectorViewControllerDelegate, UITextFieldDelegate, MBProgressHUDDelegate>{
    
    IBOutlet UITableView * learningTable;
    IBOutlet UITableView * speakingTable;
    IBOutlet UIButton * searchButton;
    IBOutlet UILabel * nameLabel;
    IBOutlet UITextField * nameTextField;
    IBOutlet UILabel * textLabel;
    
    IBOutlet UILabel * learningLabel;
    IBOutlet UILabel * speakingLabel;
    IBOutlet UIView  * learningBackgroundView;
    IBOutlet UIView  * speakingBackgroundView;
    
    IBOutlet UISegmentedControl * searchTypeControl;
    IBOutlet UIView * searchTypeBackgroundView;
    
    NSString * learningLan;
    NSString * SpeakingLan;
    
    LanguageSelectorController * learningController;
    LanguageSelectorController * speakingController;
    
    MKCoordinateRegion  region;
    
    MBProgressHUD * HUD;
}

@property (nonatomic, strong) IBOutlet UITableView * learningTable;
@property (nonatomic, strong) IBOutlet UITableView * speakingTable;
@property (nonatomic, strong) IBOutlet UIButton * searchButton;
@property (nonatomic, strong) IBOutlet UILabel * nameLabel;
@property (nonatomic, strong) IBOutlet UITextField * nameTextField;
@property (nonatomic, strong) IBOutlet UILabel * textLabel;

@property (nonatomic, strong) IBOutlet UISegmentedControl * searchTypeControl;
@property (nonatomic, strong) IBOutlet UIView * searchTypeBackgroundView;

@property (nonatomic, strong) NSString * learningLan;
@property (nonatomic, strong) NSString * speakingLan;

@property (nonatomic, strong) LanguageSelectorController * learningController;
@property (nonatomic, strong) LanguageSelectorController * speakingController;

@property (nonatomic, strong) IBOutlet UILabel * learningLabel;
@property (nonatomic, strong) IBOutlet UILabel * speakingLabel;
@property (nonatomic, strong) IBOutlet UIView  * learningBackgroundView;
@property (nonatomic, strong) IBOutlet UIView  * speakingBackgroundView;

@property (nonatomic, assign) MKCoordinateRegion region;



@end
