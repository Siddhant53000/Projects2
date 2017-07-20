//
//  NewDictionaryViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 11/30/16.
//
//

#import "NewDictionaryViewController.h"
#import "DictionaryDBHandler.h"

@interface NewDictionaryViewController ()
@property (strong,nonatomic) UITextField *wordField;
@property (strong, nonatomic) UITextField *defField;
@end

@implementation NewDictionaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"New Word"];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
    float yOrigin = self.navigationItem.accessibilityFrame.size.height + 100;
    _wordField = [[UITextField alloc] init];
    [_wordField setFrame:CGRectMake(10, yOrigin, 200, 40)];
    [_wordField setText:@"Word to define"];
    _defField = [[UITextField alloc] init];
    [_defField setFrame:CGRectMake(10, yOrigin+60, 200, 40)];
    [_defField setText:@"Definition for word"];
    [_wordField setClearsOnBeginEditing:true];
    [_defField setClearsOnBeginEditing:true];
    [self.view addSubview:_wordField];
    [self.view addSubview:_defField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addItem:(id)sender {
    NSString *wordText;
    NSString *defText;
    if (![[_defField text] isEqualToString:@"Definition for word"]) defText = [_defField text];
    if (![[_wordField text] isEqualToString:@"Word to define"]) wordText = [_wordField text];
    
    if (wordText.length > 0 && defText.length > 0) {
        [[DictionaryDBHandler getSharedInstance] saveData:wordText forDefinition:defText];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
