//
//  LTMessage.m
// LextTalk
//
//  Created by David on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LTMessage.h"
#import "LTDataSource.h"
#import "UICopyLabel.h"

@interface LTMessage (PrivateMethods)
- (UIView*) newViewForMessage:(BOOL) addTime withOrientation:(UIInterfaceOrientation) orientation isChatroom:(BOOL) chatroom withWholeWidth:(CGFloat) wholeWidth;
@end


@implementation LTMessage
@synthesize	messageId = _messageId;
@synthesize	senderId = _senderId;
@synthesize	senderName = _senderName;
@synthesize	destId = _destId;
@synthesize	destName = _destName;
@synthesize	timestamp = _timestamp;
@synthesize	body = _body;
@synthesize	deliverStatus = _deliverStatus;

@synthesize senderLearningLan, senderSpeakingLan, senderLearningFlag, senderSpeakingFlag, destLearningLan, destSpeakingLan, destLearningFlag ,destSpeakingFlag;

#pragma mark -
#pragma mark LTTableObjectProtocol methods

- (CGFloat) cellHeightInTableView:(UITableView *)tableView 
                  withOrientation:(UIInterfaceOrientation)orientation 
                         withTime:(BOOL)addTime
                       isChatroom:(BOOL)chatroom
{

	UITableViewCell *cell = [self cellInTableView: tableView withOrientation:orientation addTime:addTime isChatroom:chatroom];
	return cell.frame.size.height;
}

- (BOOL) shouldAppearInContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	return NO;
}

- (UITableViewCell*) cellInTableView: (UITableView *) tableView 
                     withOrientation: (UIInterfaceOrientation)orientation
                             addTime: (BOOL) addTime
                          isChatroom: (BOOL)chatroom
{
	
    static NSString *CellIdentifier = @"MessageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	
	for(UIView *v in cell.contentView.subviews) {
		[v removeFromSuperview];
	}
	
    //La anchura ya viene dada de este método
	UIView *msgView = [self newViewForMessage: addTime withOrientation:orientation isChatroom:chatroom withWholeWidth:tableView.bounds.size.width];
    
    CGRect frame = msgView.frame;
	frame.origin.y = 3;
	
	[msgView setFrame: frame];
	
	// resize cell
	frame = cell.frame;
	
	frame.size.height = msgView.frame.size.height + 6;
	
    
    [cell.contentView addSubview: msgView];
    
    [cell setFrame: frame];
    
    cell.backgroundColor = [UIColor clearColor];
    
    
	return cell;
	
}

#pragma mark -
#pragma mark LTMessage methods
+ (LTMessage*) newMessageWithDict: (NSDictionary*) d {
    LTMessage *result = [[LTMessage alloc] init];
    
    result.messageId = [result integerForKey: @"id" inDict: d];
    result.senderId = [result integerForKey: @"from_id" inDict: d];
    if (result.senderId == 0) {
        result.senderId = [result integerForKey: @"user_id" inDict: d];
    }
    result.senderName = [result stringForKey: @"sender_name" inDict: d];
    if (!result.senderName) {
        result.senderName = [result stringForKey: @"user_name" inDict: d];
    }
    result.destId = [result integerForKey: @"to_id" inDict: d];
    result.destName = [result stringForKey: @"dest_name" inDict: d];	
    result.timestamp = [result stringForKey: @"sent_time" inDict: d];
    if (!result.timestamp) {
        result.timestamp = [result stringForKey: @"date_send" inDict: d];
    }
    result.body = [result stringForKey: @"body" inDict: d];
    if (!result.body) {
        result.body = [result stringForKey: @"message" inDict: d];
    }
    result.deliverStatus = [result integerForKey: @"deliver_status" inDict: d];	
    
    //Languages
    result.destLearningLan=[result stringForKey:@"dest_learning_lan" inDict:d];
    result.destSpeakingLan=[result stringForKey:@"dest_native_lan" inDict:d];
    result.destLearningFlag=[result integerForKey:@"dest_learning_flag" inDict:d];
    result.destSpeakingFlag=[result integerForKey:@"dest_native_flag" inDict:d];
    
    result.senderLearningLan=[result stringForKey:@"sender_learning_lan" inDict:d];
    result.senderSpeakingLan=[result stringForKey:@"sender_native_lan" inDict:d];
    result.senderLearningFlag=[result integerForKey:@"sender_learning_flag" inDict:d];
    result.senderSpeakingFlag=[result integerForKey:@"sender_native_flag" inDict:d];

    result.translatedText=nil;

	return result;	
}

- (NSComparisonResult)compare:(LTMessage *)anotherMessage {
	return [self.timestamp compare: anotherMessage.timestamp];
}



- (UIView*) newViewForMessage: (BOOL) addTime withOrientation:(UIInterfaceOrientation)orientation isChatroom:(BOOL)chatroom withWholeWidth:(CGFloat)wholeWidth
{
    CGFloat width;
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (orientation==UIInterfaceOrientationPortrait || orientation==UIInterfaceOrientationPortraitUpsideDown)
            width = 374;
        else
            width = 524;
    }
    else
    {
        if (orientation==UIInterfaceOrientationPortrait || orientation==UIInterfaceOrientationPortraitUpsideDown)
            width = 168;
        else
        {
            width = 248;
            if (wholeWidth>560)
                width=336;//iPhone 5
        }
    }
    
	// add header	
	UIImageView *balloonImageView;
    UIImage * balloon;
    CGFloat addToY=0;
    if (self.senderId==[[LTDataSource sharedDataSource] localUser].userId)
    {
        balloon=[UIImage imageNamed:@"BalloonFromMe"];
        balloon=[balloon stretchableImageWithLeftCapWidth:17 topCapHeight:15];
    }
    else
    {
        if (self.translatedText==nil)
            balloon=[UIImage imageNamed:@"BalloonFromOther"];
        else
            balloon=[UIImage imageNamed:@"BalloonFromOtherTranslated"];
        balloon=[balloon stretchableImageWithLeftCapWidth:25 topCapHeight:15];
    }
    balloonImageView=[[UIImageView alloc] initWithImage:balloon];
    
    //I must do this in order for the gesture recognizer in this child UICopyLabel to work
    [balloonImageView setUserInteractionEnabled:YES];
    
    
    //So that there is space for the time stamp if needed
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake( 0, 0, wholeWidth, 60)];
    
    
	[view addSubview: balloonImageView];

    
    if (addTime)
    {
        UIFont * font=[UIFont fontWithName:@"Ubuntu" size:12];
        NSString * dateString=[LTMessage utcTimeToLocalTime:self.timestamp];
        CGSize constraintSize=CGSizeMake(300, 40);
        
        CGRect textRect = [dateString boundingRectWithSize:constraintSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:font}
                                                        context:nil];
        CGSize labelSize = textRect.size;
        
        CGRect labelRect=CGRectMake(0, 0, wholeWidth, labelSize.height);
        
        UILabel * timeLabel=[[UILabel alloc] initWithFrame:labelRect];
        timeLabel.textAlignment=NSTextAlignmentCenter;
        timeLabel.font=font;
        timeLabel.backgroundColor=[UIColor clearColor];
        timeLabel.textColor=[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0];
        timeLabel.text=[LTMessage utcTimeToLocalTime:self.timestamp];
        
        addToY=labelSize.height + 3;
        [view addSubview:timeLabel];
    }
    
    if (chatroom && (self.senderId!=[[LTDataSource sharedDataSource] localUser].userId))
    {
        UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(20, addToY, width -9, 13)];
        label.numberOfLines=1;
        label.font=[UIFont fontWithName:@"Ubuntu-Medium" size:11];
        //label.text=[self.senderName stringByAppendingString:@":"];
        label.textColor = [UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0];
        label.text = self.senderName;
        label.backgroundColor=[UIColor clearColor];
        [view addSubview:label];
        addToY+=13;
    }
    
    UIFont * font=[UIFont fontWithName:@"Ubuntu" size:14];;
    
    //AO
    //self.body.editable=NO;
    //AO To make links clickable
    //self.body.dataDetectorTypes=UIDataDetectorTypeLink;
    //AO

    CGSize constraintSize ;
    constraintSize = CGSizeMake(width, CGFLOAT_MAX);
    NSString *string;
    if (self.translatedText==nil) {
        string = self.body;
    } else {
        string = self.translatedText;
    }
    
    CGRect textRect = [string boundingRectWithSize:constraintSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:font}
                                           context:nil];
    CGSize labelSize = textRect.size;
    
    //Add offset?
    CGRect labelRect;
    CGRect imageViewRect;
    
    if (self.senderId==[[LTDataSource sharedDataSource] localUser].userId)//Rojo
    {
        CGFloat x=wholeWidth - labelSize.width - 26;
        labelRect=CGRectMake(10, 3, labelSize.width, labelSize.height);
        imageViewRect=CGRectMake(x -8.0, addToY + 0, labelSize.width + 26, labelSize.height+9);
    }
    else//Verde
    {
        labelRect=CGRectMake(16, 3, labelSize.width, labelSize.height);
        imageViewRect=CGRectMake(8.0, addToY + 0, labelSize.width + 26, labelSize.height+9);
    }
    
    //imageViewRect=CGRectMake(0, addToY + 0, labelSize.width + 26, labelSize.height+9);
    
	UICopyLabel *textLabel = [[UICopyLabel alloc] initWithFrame: labelRect];
    textLabel.tag=111;
	textLabel.font=font;
    //AO added back
    [textLabel setNumberOfLines: 0];
    //AO Making the links clickable. The object is now UITextView
    // textLabel.editable=NO;
    // textLabel.dataDetectorTypes=UIDataDetectorTypeLink;
    //AO
    //AO
    textLabel.numberOfLines=0;
    //AO
    
   	//textLabel.scrollEnabled = false;
   	
    
	[balloonImageView addSubview: textLabel];
    if (self.translatedText==nil)
        [textLabel setText: self.body];
    else
        textLabel.text=self.translatedText;
   	textLabel.backgroundColor=[UIColor clearColor];
    
    //AO some ugly hacks so that things display well

    // textLabel.textAlignment = NSTextAlignmentLeft;
    // textLabel.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
   
    //textLabel.contentSize = labelRect.size;
    //textLabel.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    //[textLabel sizeToFit];
    
    //textLabel.sizeToFit();
    

	balloonImageView.frame=imageViewRect;
    
    //Button for translation, only for the messages received
    if (self.senderId!=[[LTDataSource sharedDataSource] localUser].userId)//Verde
    {
        //Buttons to translate
        if (self.translatedText==nil)
        {
            //UIMenuController can show the translate option
            textLabel.showTranslate=YES;
            
            //Button for toggling to the TranslatorViewController
            UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"TranslatorButton"] forState:UIControlStateNormal];
            button.tag=222;//I'll have to run through the subviews later
            button.frame=CGRectMake(imageViewRect.origin.x + imageViewRect.size.width + 10,
                                    imageViewRect.origin.y + imageViewRect.size.height/2 -16,
                                    32, 32);
            [view addSubview:button];
            
            //Shadow
            /*
            button.layer.shadowColor=[[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] CGColor];
            button.layer.shadowOpacity = 1.0;
            button.layer.shadowRadius = 1;
            button.layer.shadowOffset = CGSizeMake(0, 1);
            button.clipsToBounds=NO;
             */
            
            
            //Button for translation in chat itslef
            button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"TranslateInChatButton"] forState:UIControlStateNormal];
            button.tag=333;//I'll have to run through the subviews later
            button.frame=CGRectMake(imageViewRect.origin.x + imageViewRect.size.width + 10 + 32.0 + 8,
                                    imageViewRect.origin.y + imageViewRect.size.height/2 -16,
                                    32, 32);
            [view addSubview:button];
            
            //Shadow
            /*
            button.layer.shadowColor=[[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] CGColor];
            button.layer.shadowOpacity = 1.0;
            button.layer.shadowRadius = 1;
            button.layer.shadowOffset = CGSizeMake(0, 1);
            button.clipsToBounds=NO;
             */
        }
        else //button to remove translation
        {
            //Button for toggling to the TranslatorViewController
            UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"RemoveTranslationButton"] forState:UIControlStateNormal];
            button.tag=444;//I'll have to run through the subviews later
            button.frame=CGRectMake(imageViewRect.origin.x + imageViewRect.size.width + 10,
                                    imageViewRect.origin.y + imageViewRect.size.height/2 -16,
                                    32, 32);
            [view addSubview:button];
            
            //Shadow
            /*
            button.layer.shadowColor=[[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] CGColor];
            button.layer.shadowOpacity = 1.0;
            button.layer.shadowRadius = 1;
            button.layer.shadowOffset = CGSizeMake(0, 1);
            button.clipsToBounds=NO;
             */
        }
    }
    
    view.frame=CGRectMake(0, 0, wholeWidth, imageViewRect.size.height + addToY);
	return view;
}

#pragma mark -
#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSAssert1([encoder allowsKeyedCoding], @"[%@] Does not support sequential archiving.", [self class]);
    
    [encoder encodeInteger: self.messageId forKey: @"messageId"];
    [encoder encodeInteger: self.senderId forKey: @"senderId"];
    [encoder encodeInteger: self.destId forKey: @"destId"];
    [encoder encodeInt: self.deliverStatus forKey: @"deliverStatus"];    
    
    [encoder encodeObject: self.senderName forKey:@"senderName"];
    [encoder encodeObject: self.destName forKey:@"destName"];
    [encoder encodeObject: self.timestamp forKey:@"timestamp"];
    [encoder encodeObject: self.body forKey:@"body"];
    
    [encoder encodeObject:self.senderLearningLan forKey:@"senderLearningLan"];
    [encoder encodeObject:self.senderSpeakingLan forKey:@"senderSpeakingLan"];
    [encoder encodeInteger:self.senderLearningFlag forKey:@"senderLearningFlag"];
    [encoder encodeInteger:self.senderSpeakingFlag forKey:@"senderSpeakingFlag"];
    
    [encoder encodeObject:self.destLearningLan forKey:@"destLearningLan"];
    [encoder encodeObject:self.destSpeakingLan forKey:@"destSpeakingLan"];
    [encoder encodeInteger:self.destLearningFlag forKey:@"destLearningFlag"];
    [encoder encodeInteger:self.destSpeakingFlag forKey:@"destSpeakingFlag"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) return nil;
    
    // now use the coder to initialize your state
    [self setMessageId: [decoder decodeIntForKey: @"messageId"]];
    [self setSenderId: [decoder decodeIntForKey: @"senderId"]];
    [self setDestId: [decoder decodeIntForKey: @"destId"]];
    [self setDeliverStatus: [decoder decodeIntForKey: @"deliverStatus"]];
    
    [self setSenderName: [decoder decodeObjectForKey: @"senderName"]];
    [self setDestName: [decoder decodeObjectForKey: @"destName"]];
    [self setTimestamp: [decoder decodeObjectForKey: @"timestamp"]];
    [self setBody: [decoder decodeObjectForKey: @"body"]];
    
    self.senderLearningLan=[decoder decodeObjectForKey:@"senderLearningLan"];
    self.senderSpeakingLan=[decoder decodeObjectForKey:@"senderSpeakingLan"];
    self.senderLearningFlag=[decoder decodeIntForKey:@"senderLearningFlag"];
    self.senderSpeakingFlag=[decoder decodeIntForKey:@"senderSpeakingFlag"];
    
    self.destLearningLan=[decoder decodeObjectForKey:@"destLearningLan"];
    self.destSpeakingLan=[decoder decodeObjectForKey:@"destSpeakingLan"];
    self.destLearningFlag=[decoder decodeIntForKey:@"destLearningFlag"];
    self.destSpeakingFlag=[decoder decodeIntForKey:@"destSpeakingFlag"];
    
    self.translatedText=nil;
    
    return self;
}

#pragma mark -
#pragma mark NSObject methods


@end
