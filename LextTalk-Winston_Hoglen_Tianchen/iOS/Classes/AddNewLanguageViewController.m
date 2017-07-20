//
//  AddNewLanguageViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 12/11/16.
//
//

#import "AddNewLanguageViewController.h"
#import "LTDataSource.h"

@interface AddNewLanguageViewController ()
@property (strong, nonatomic) UITextField *addSpeakingLangTF;
@property (strong, nonatomic) UITextField *addLearningLangTF;
@end

@implementation AddNewLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Add New Languages"];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
    float yOrigin = self.navigationItem.accessibilityFrame.size.height + 100;
//    UILabel *addSpeakingLang = [[UILabel alloc] init];
//    [addSpeakingLang setFrame:CGRectMake(10, yOrigin, 250, 20)];
//    [addSpeakingLang setTextColor:[UIColor blackColor]];
//    [addSpeakingLang setBackgroundColor:[UIColor clearColor]];
//    [addSpeakingLang setText:@"Add a new native speaking language:"];
    
    _addSpeakingLangTF = [[UITextField alloc] init];
    [_addSpeakingLangTF setFrame:CGRectMake(10, yOrigin, 300, 40)];
    [_addSpeakingLangTF setText:@"Add a new native/fluent language"];
    [_addSpeakingLangTF setTextColor:[UIColor blackColor]];
    [_addSpeakingLangTF setEnabled:true];
    [_addSpeakingLangTF setClearsOnBeginEditing:true];
    
    _addLearningLangTF = [[UITextField alloc] init];
    [_addLearningLangTF setFrame:CGRectMake(10, yOrigin+50, 300, 40)];
    [_addLearningLangTF setText:@"Add a new learning language"];
    [_addLearningLangTF setTextColor:[UIColor blackColor]];
    [_addLearningLangTF setEnabled:true];
    [_addLearningLangTF setClearsOnBeginEditing:true];
    
    [self.view addSubview:_addLearningLangTF];
    [self.view addSubview:_addSpeakingLangTF];
    
}

- (void) addItem: (id) sender {
    NSString *learnLangString= [_addLearningLangTF text];
    NSString *nativeLangString = [_addSpeakingLangTF text];
    if (![learnLangString isEqualToString:@"Add a new learning language"] && learnLangString.length >0){
        NSArray *tempLearningLangArray = [[LTDataSource sharedDataSource] localUser].learningLanguages;
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:tempLearningLangArray copyItems:YES];
        [mutableArray addObject:learnLangString];
        [[[LTDataSource sharedDataSource] localUser] setLearningLanguages:(NSArray *)mutableArray];
    }
    if (![nativeLangString isEqualToString:@"Add a new native/fluent language"] && nativeLangString.length >0){
        NSArray *tempLearningLangArray = [[LTDataSource sharedDataSource] localUser].speakingLanguages;
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:tempLearningLangArray copyItems:YES];
        [mutableArray addObject:nativeLangString];
        [[[LTDataSource sharedDataSource] localUser] setSpeakingLanguages:(NSArray *)mutableArray];
//        [[LTDataSource sharedDataSource] localUser].speakingLanguages = (NSArray*)mutableArray;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
