//
//  IQSkin.h
//
//  Created by David Romacho on 2/4/11.
//  Copyright 2011 InQBarna. All rights reserved.
//

#import "IQSkin.h"
#import "XMLReader.h"
#import "IQVerbose.h"

static IQSkin *theSkin = nil;

@implementation IQSkin
@synthesize active = _active;
@synthesize name = _name;
@synthesize navBarColor = _navBarColor;
@synthesize navBarTextColor = _navBarTextColor;
@synthesize tabBarColor = _tabBarColor;	
@synthesize cellSeparatorColor = _cellSeparatorColor;	
@synthesize cellBackgroundColor = _cellBackgroundColor;	
@synthesize cellTitleColor = _cellTitleColor;	
@synthesize cellTextColor = _cellTextColor;	
@synthesize sectionTextColor = _sectionTextColor;
@synthesize textColor = _textColor;	
@synthesize alertFillColor = _alertFillColor;
@synthesize alertBorderColor = _alertBorderColor;
@synthesize image = _image;
@synthesize tabBarImage = _tabBarImage;

- (UIColor*) colorWithDict: (NSDictionary*) d {
	CGFloat red = [[d objectForKey: @"red"] floatValue];
	CGFloat green = [[d objectForKey: @"green"] floatValue];
	CGFloat blue = [[d objectForKey: @"blue"] floatValue];
	CGFloat alpha = [[d objectForKey: @"alpha"] floatValue];	
	
	return [UIColor colorWithRed: red/255.0
						   green: green/255.0
							blue: blue/255.0
						   alpha: alpha/255.0];
}

- (NSBundle*) skinBundle: (IQSkin*) skin {
	NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];	
	NSString *bundlePath = [documentsDir stringByAppendingPathComponent: skin.name];		
    
	if(![[NSFileManager defaultManager] fileExistsAtPath: bundlePath]) {
		NSLog(@"[%@] Warning: skin bundle %@ does not exists", [self class], skin.name);
		return nil;
	}
	
	return [NSBundle bundleWithPath: bundlePath];
}

- (id) initWithXMLData: (NSData*) data {
	if(self = [self init]) {
		NSError *parseError = nil;
		NSDictionary *root = [XMLReader dictionaryForXMLData: data error: &parseError];
		
		if(parseError != nil) {
			IQVerbose(VERBOSE_ERROR, @"[%@] Could not initialize with XML data",[self class]);
		} else {
			NSDictionary *d = [root objectForKey:@"skin"];
			self.name = [d objectForKey: @"name"];
			self.active = [[d objectForKey: @"active"] boolValue];
			
			NSDictionary *colors = [d objectForKey:@"colors"];
			self.navBarColor = [self colorWithDict: [colors objectForKey: @"navigationBar"]];
			self.navBarTextColor = [self colorWithDict: [colors objectForKey: @"navigationBarText"]];
			self.tabBarColor = [self colorWithDict: [colors objectForKey: @"tabBar"]];			
			self.cellSeparatorColor = [self colorWithDict: [colors objectForKey: @"cellSeparator"]];			
			self.cellBackgroundColor = [self colorWithDict: [colors objectForKey: @"cellBackground"]];
			self.cellTitleColor = [self colorWithDict: [colors objectForKey: @"cellTitle"]];
			self.cellTextColor = [self colorWithDict: [colors objectForKey: @"cellText"]];
			self.sectionTextColor = [self colorWithDict: [colors objectForKey: @"sectionText"]];
			self.textColor = [self colorWithDict: [colors objectForKey: @"normalText"]];
			self.alertFillColor = [self colorWithDict: [colors objectForKey: @"alertFill"]];
			self.alertBorderColor = [self colorWithDict: [colors objectForKey: @"alertBorder"]];

			NSDictionary *images = [d objectForKey:@"images"];
			self.tabBarImage = [UIImage imageNamed: [[images objectForKey: @"tabBar"] objectForKey: @"file"]];
		}
	}
	return self;
}

- (id) initWithXMLFile: (NSString*) path {
	return [self initWithXMLData: [NSData dataWithContentsOfFile: path]];
}

+ (void) setDefaultSkin: (IQSkin*) skin {
	if(skin == theSkin) return;
	
	if(theSkin != nil) {
		theSkin = nil;
	}
	theSkin = skin;
}

+ (IQSkin*) defaultSkin {
	if(theSkin == nil) {
		theSkin = [[IQSkin alloc] init];
		[theSkin setActive: NO];
		[theSkin setName: @"Default skin"];
		[theSkin setImage: nil];
		[theSkin setTabBarImage: nil];
		
		[theSkin setNavBarColor: [UIColor purpleColor]];
		[theSkin setNavBarTextColor: [UIColor whiteColor]];		
		[theSkin setTabBarColor: [UIColor purpleColor]];
		[theSkin setCellSeparatorColor: [UIColor grayColor]];
		[theSkin setCellBackgroundColor: [UIColor whiteColor]];
		[theSkin setCellTextColor: [UIColor blackColor]];
		[theSkin setCellTitleColor: [UIColor grayColor]];
		[theSkin setSectionTextColor: [UIColor purpleColor]];
        
        [theSkin setTextColor: [UIColor blackColor]];
		
		[theSkin setAlertFillColor: [UIColor purpleColor]];
		[theSkin setAlertBorderColor: [UIColor grayColor]];
	}
	
	return theSkin;
}

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

+ (void) setTitle: (NSString*) title ofColor: (UIColor*) color inViewController: (UIViewController*) vc {
	CGRect frame = CGRectMake(0, 0, 400, 44);
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:20.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = color;

	label.text = title;
	[label sizeToFit];
	vc.navigationItem.titleView = label;	
}


+ (UIImage *) applyColor: (UIColor*) color toGrayscaleImage: (UIImage*) img {
	CGSize size = [img size];
	int width = size.width;
	int height = size.height;
	
	// the pixels will be painted to this array
	uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
	// clear the pixels so any transparency is preserved
	memset(pixels, 0, width * height * sizeof(uint32_t));
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create a context with RGBA pixels
	CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
	// paint the bitmap to our context which will fill in the pixels array
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
	
	// get colors
	CGColorRef refColor = [color CGColor];
	
	int numComponents = CGColorGetNumberOfComponents(refColor);
	CGFloat red = 0;
	CGFloat green = 0;
	CGFloat blue  = 0;
	
	if (numComponents == 4) {
		const CGFloat *components = CGColorGetComponents(refColor);
		red = components[0];
		green = components[1];
		blue = components[2];
		//IQVerbose(VERBOSE_DEBUG,@"%f,%f,%f", red,green,blue);
	}
	
	for(int y = 0; y < height; y++) {
		for(int x = 0; x < width; x++) {
			uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			//rgbaPixel[ALPHA] = 255;
			rgbaPixel[RED] = (rgbaPixel[RED] * red);
			rgbaPixel[GREEN] = (rgbaPixel[GREEN] * green);
			rgbaPixel[BLUE] = (rgbaPixel[BLUE] * blue);
		}
	}
	
	// create a new CGImageRef from our context with the modified pixels
	CGImageRef image = CGBitmapContextCreateImage(context);
	
	// we're done with the context, color space, and pixels
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	free(pixels);
	
	// make a new UIImage to return
	UIImage *resultUIImage = [UIImage imageWithCGImage:image];
	
	// we're done with image now too
	CGImageRelease(image);
	
	return resultUIImage;
}


@end
