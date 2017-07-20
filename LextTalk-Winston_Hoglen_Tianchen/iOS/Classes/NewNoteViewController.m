//
//  NewNoteViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 11/13/16.
//
//

#import "NewNoteViewController.h"
#import "NotepadHandler.h"

@interface NewNoteViewController ()
@property (strong, nonatomic) UITextView *noteArea;
@end

@implementation NewNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"New Note"];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
    _noteArea = [[UITextView alloc] init];
    [_noteArea setEditable:YES];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height - self.navigationItem.accessibilityFrame.size.height;
    float yOrigin = self.navigationItem.accessibilityFrame.size.height;
    [_noteArea setFrame:CGRectMake(0, yOrigin+10, width, height)];
    
    [self.view addSubview:_noteArea];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addItem:(id)sender {
    if (_noteArea.text.length > 0)
    {
        [[NotepadHandler getSharedInstance] saveData:_noteArea.text];
    }
    [_noteArea removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
