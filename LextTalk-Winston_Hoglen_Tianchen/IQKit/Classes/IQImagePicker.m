//
//  IQImagePicker.m
//  ImagePicker
//
//  Created by David Romacho on 5/21/13.
//  Copyright (c) 2013 InQBarna Kenkyuu Jo. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "IQImagePicker.h"

static IQImagePicker *thePicker = nil;

@interface IQImagePicker()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
@property (strong, nonatomic) void (^completionBlock)(UIImage *img, NSDictionary *info, NSError *error);
@property (strong, nonatomic) UIPopoverController       *popover;
@property (strong, nonatomic) UIView                    *presentingView;
@property (strong, nonatomic) UIViewController          *presentingViewController;
@property (assign, nonatomic) BOOL                      fullScreen;
@end

@implementation IQImagePicker

#pragma mark -
#pragma mark IQImagePicker methods

+ (void)selectPictureFromView:(UIView*)view
     presentingViewController:(UIViewController*)pvc
                       source:(IQImagePickerSource)types
                   fullScreen:(BOOL)fs
               withCompletion:(void (^)(UIImage *img, NSDictionary *info, NSError *error))block
{
    if(thePicker) {
        NSLog(@"Picker already in use!");
        return;
    }
    
    thePicker = [[IQImagePicker alloc] init];
    
    thePicker.completionBlock = block;
    thePicker.presentingView = view;
    thePicker.presentingViewController = pvc;
    thePicker.fullScreen = fs;
    
    if(types == 0) {
        types = 0x0ff;
    }
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && (types & IQImagePickerSourceCamera)) {
        if(types == IQImagePickerSourceCamera) {
            [thePicker actionWithSource:IQImagePickerSourceCamera];
            return;
        } else {
            [buttons addObject:NSLocalizedString(@"Use Camera", @"Use Camera")];
        }
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] && (types & IQImagePickerSourceRoll)) {
        if(types == IQImagePickerSourceRoll) {
            [thePicker actionWithSource:IQImagePickerSourceRoll];
            return;            
        } else {
            [buttons addObject:NSLocalizedString(@"Camera Roll", @"Camera Roll")];
        }
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] && (types & IQImagePickerSourceAlbum)) {
        if(types == IQImagePickerSourceAlbum) {
            [thePicker actionWithSource:IQImagePickerSourceAlbum];
            return;            
        } else {
            [buttons addObject:NSLocalizedString(@"Photo Albums", @"Photo Albums")];
        }
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = NSLocalizedString(@"Take a Photo", @"Take a Photo");
    sheet.delegate = thePicker;
    
    for(NSString *title in buttons) {
        [sheet addButtonWithTitle:title];
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        [sheet showInView:view];
    }
    else {
        [sheet showFromRect:view.frame inView:view.superview animated:YES];
    }
}

- (void)cleanup {
    self.presentingViewController = nil;
    self.presentingView = nil;
    self.completionBlock = nil;
    self.popover = nil;
    thePicker = nil;    
}

- (void)actionWithSource:(IQImagePickerSource)source {
    UIImagePickerController *vc = [[NonRotatingUIImagePickerController alloc] init];
    vc.allowsEditing = YES;
    vc.delegate = (id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>) self;
    
    switch (source) {
        case IQImagePickerSourceCamera:
            vc.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case IQImagePickerSourceRoll:
            vc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        case IQImagePickerSourceAlbum:
            vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            return;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(self.fullScreen && source == IQImagePickerSourceCamera) {
            [self.presentingViewController presentViewController:vc animated:YES completion:nil];
        }
        else {
            self.popover = [[UIPopoverController alloc] initWithContentViewController: vc];
            self.popover.delegate = self;
            [self.popover presentPopoverFromRect:self.presentingView.frame
                                          inView:self.presentingView.superview
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
        }
    } else {
        [self.presentingViewController presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate methods

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self cleanup];
}

- (BOOL) popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if((buttonIndex >= 0) && (buttonIndex < actionSheet.numberOfButtons)) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"Use Camera", @"Use Camera")]) {
            [self actionWithSource:IQImagePickerSourceCamera];
            return;
        }
        
        if([title isEqualToString:NSLocalizedString(@"Camera Roll", @"Camera Roll")]) {
            [self actionWithSource:IQImagePickerSourceRoll];
            return;
        }
        
        if([title isEqualToString:NSLocalizedString(@"Photo Albums", @"Photo Albums")]) {
            [self actionWithSource:IQImagePickerSourceAlbum];
            return;
        }
    }
    
    [self cleanup];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if(self.popover) {
        [self.popover dismissPopoverAnimated: YES];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self cleanup];
}

- (void)doneWithImage:(UIImage*)img info:(NSDictionary*)info andError:(NSError*)error {
    if(self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        if(self.completionBlock) {
            self.completionBlock(img, info, error);
        }
        [self cleanup];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^
         {
             if(self.completionBlock) {
                 self.completionBlock(img, info, error);
             }
             [self cleanup];
         }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if(originalImage) {
        [self doneWithImage:originalImage info:info andError:nil];
    } else {
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        NSURL *assetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
        [assetslibrary assetForURL: assetUrl
                       resultBlock:^(ALAsset *asset) {
                           ALAssetRepresentation *rep = [asset defaultRepresentation];
                           NSLog(@"getJPEGFromAssetForURL: default asset representation for %@: uti: %@ size: %lld url: %@ orientation: %d scale: %f metadata: %@",
                                 assetUrl, [rep UTI], [rep size], [rep url], [rep orientation],
                                 [rep scale], [rep metadata]);
                           
                           CGImageRef iref = [rep fullResolutionImage];
                           if (iref) {
                               [self doneWithImage:[UIImage imageWithCGImage:iref] info:info andError:nil];
                           }
                       }
                      failureBlock:^(NSError *error) {
                          [self doneWithImage:nil info:info
                                     andError:error];
                      }];
    }
}

@end

//++HACK
@implementation NonRotatingUIImagePickerController
- (BOOL)shouldAutorotate
{
    return NO;
}
@end
//--HACK
