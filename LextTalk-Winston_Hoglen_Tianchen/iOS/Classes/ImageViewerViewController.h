//
//  ImageViewerViewController.h
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 10/27/13.
//
//

#import <UIKit/UIKit.h>
#import "AdInheritanceViewController.h"

@interface ImageViewerViewController : AdInheritanceViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIImage * image;

@end
