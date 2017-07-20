//
//  DictionaryDefinitionViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 11/30/16.
//
//

#import "DictionaryDefinitionViewController.h"

@interface DictionaryDefinitionViewController ()
@property (strong, nonatomic) UITextView *definitionArea;
@property (strong, nonatomic) NSString *definition;
@property (strong, nonatomic) NSString *word;
@end

@implementation DictionaryDefinitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void) setDefinition:(NSString *)definition {
    _definition = definition;
    _definitionArea = [[UITextView alloc] init];
    [_definitionArea setEditable:NO];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height - self.navigationItem.accessibilityFrame.size.height;
    float yOrigin = self.navigationItem.accessibilityFrame.size.height;
    [_definitionArea setFrame:CGRectMake(0, yOrigin+10, width, height)];
    [_definitionArea setText:_definition];
    [self.view addSubview:_definitionArea];
}

-(void) setWordToDefine:(NSString *)word {
    _word = word;
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Definition for: %@", _word]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
