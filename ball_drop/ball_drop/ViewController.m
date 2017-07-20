//
//  ViewController.m
//  ball_drop
//
//  Created by Siddhant Gupta on 1/30/17.
//  Copyright © 2017 Siddhant Gupta. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()
//@property (weak,nonatomic) IBOutlet UIView * ball;
@end

@implementation ViewController{
    UIDynamicAnimator * _animator;
    UIGravityBehavior * _gravity;
    UICollisionBehavior * _collision;
    UIDynamicItemBehavior * _dynamic_behavior;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    
    _gravity =[[UIGravityBehavior alloc]init];
    _collision=[[UICollisionBehavior alloc]init];
    _collision.translatesReferenceBoundsIntoBoundary= YES;
    _dynamic_behavior =[[UIDynamicItemBehavior alloc]init];
    _dynamic_behavior.elasticity=0.6;
    [_animator addBehavior:_gravity];
    [_animator addBehavior:_collision];
    [_animator addBehavior:_dynamic_behavior];
    
    
    
}
- (IBAction)drop_ball:(id)sender {
    UIView * ball=[[UIView alloc]initWithFrame:CGRectMake(100, 20, 50, 50)];
    [self.view addSubview:ball];
    [ball setBackgroundColor:[UIColor redColor]];
    ball.layer.cornerRadius=25;
    [_gravity addItem:ball];
    [_collision addItem:ball];
    [_dynamic_behavior addItem:ball];
    //[self.view addSubview:_ball];
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
