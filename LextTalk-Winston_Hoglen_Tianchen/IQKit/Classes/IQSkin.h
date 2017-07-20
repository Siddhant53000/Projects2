//
//  IQSkin.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQSkinProtocol;

@interface IQSkin : NSObject {
	BOOL		_active;
	NSString	*_name;
	
	UIColor		*_navBarColor;
	UIColor		*_navBarTextColor;
	UIColor		*_tabBarColor;	

	UIColor		*_cellSeparatorColor;	
	UIColor		*_cellBackgroundColor;	
	UIColor		*_cellTitleColor;	
	UIColor		*_cellTextColor;	
	UIColor		*_sectionTextColor;
    
    UIColor     *_textColor;
	
	UIColor		*_alertFillColor;
	UIColor		*_alertBorderColor;	
	
	UIImage		*_image;
	UIImage		*_tabBarImage;
}

@property (nonatomic, assign) BOOL		active;
@property (nonatomic, strong) NSString	*name;

@property (nonatomic, strong) UIColor	*navBarColor;
@property (nonatomic, strong) UIColor	*navBarTextColor;
@property (nonatomic, strong) UIColor	*tabBarColor;	

@property (nonatomic, strong) UIColor	*cellSeparatorColor;	
@property (nonatomic, strong) UIColor	*cellBackgroundColor;	
@property (nonatomic, strong) UIColor	*cellTitleColor;	
@property (nonatomic, strong) UIColor	*cellTextColor;	
@property (nonatomic, strong) UIColor	*sectionTextColor;		

@property (nonatomic, strong) UIColor	*textColor;	

@property (nonatomic, strong) UIColor	*alertFillColor;	
@property (nonatomic, strong) UIColor	*alertBorderColor;	

@property (nonatomic, strong) UIImage	*image;
@property (nonatomic, strong) UIImage	*tabBarImage;

- (id) initWithXMLData: (NSData*) data;
- (id) initWithXMLFile: (NSString*) path;

+ (IQSkin*) defaultSkin;
+ (void) setDefaultSkin: (IQSkin*) skin;

+ (void) setTitle: (NSString*) title ofColor: (UIColor*) color inViewController: (UIViewController*) vc;
+ (UIImage *) applyColor: (UIColor*) color toGrayscaleImage: (UIImage*) img;

@end

@protocol IQSkinProtocol
@required
- (void) applySkin: (IQSkin*) skin;
@end
