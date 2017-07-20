//
//  IQImagePicker.h
//  ImagePicker
//
//  Created by David Romacho on 5/21/13.
//  Copyright (c) 2013 InQBarna Kenkyuu Jo. All rights reserved.
//

// UIImagePickerController has some limitations, like not being able to pick the latest photo
// We can use https://github.com/elc/ELCImagePickerController to gain access to files
// And use this post to get last pictures http://stackoverflow.com/questions/14039279/how-to-make-recent-images-on-top-of-uiimagepickercontroller

#import <Foundation/Foundation.h>

typedef enum {
    IQImagePickerSourceCamera = 0x01,
    IQImagePickerSourceRoll = 0x02,
    IQImagePickerSourceAlbum = 0x04,
    IQImagePickerSourceAll = 0x07
} IQImagePickerSource;

@interface IQImagePicker : NSObject

+ (void)selectPictureFromView:(UIView*)view
     presentingViewController:(UIViewController*)pvc
                       source:(IQImagePickerSource)types
                   fullScreen:(BOOL)fs
               withCompletion:(void (^)(UIImage *img, NSDictionary *info, NSError *error))block;
@end

//++HACK
@interface NonRotatingUIImagePickerController : UIImagePickerController
@end
//--HACK
