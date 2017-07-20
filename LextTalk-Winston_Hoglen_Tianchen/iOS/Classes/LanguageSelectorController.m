//
//  LanguageSelectorController.m
// LextTalk
//
//  Created by Yo on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LanguageSelectorController.h"
#import "LanguageReference.h"
#import "LextTalkAppDelegate.h"
#import "IconGeneration.h"
#import "UIColor+ColorFromImage.h"

@implementation MySegmentedControl

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (current == self.selectedSegmentIndex)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end

@interface LanguageSelectorController()

@property (strong) NSMutableArray * selected;
@property (strong) NSMutableDictionary * selectedFlags;
@property BOOL multiple;
@property BOOL showFlags;

- (void) sendMultipleDelegate;

@end

@implementation LanguageSelectorController
@synthesize myTableView;
@synthesize textArray, selected, multiple, delegate, selectedItems, textTag, flagIndexForSelectedItems, selectedFlags, showFlags, preferredFlagForLan;

#pragma mark - lifecycle

- (void) setTextArray:(NSArray *)textArray2
{
    NSMutableArray * tempArray=[NSMutableArray arrayWithCapacity:[textArray2 count]];
    for (NSString * lang in textArray2)
    {
        NSString * translated=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:lang];
        [tempArray addObject:translated];
    }
    [tempArray sortUsingSelector:@selector(localizedCompare:)];
    textArray=tempArray;
}

- (void) setSelectedItems:(NSArray *)selectedItems2
{
    NSMutableArray * tempArray=[NSMutableArray arrayWithCapacity:[selectedItems2 count]];
    for (NSString * lang in selectedItems2)
    {
        NSString * translated=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:lang];
        [tempArray addObject:translated];
    }
    selectedItems=tempArray;
}

- (void) setPreferredFlagForLan:(NSDictionary *)preferredFlagForLan2
{
    NSArray * keys=[preferredFlagForLan2 allKeys];
    NSMutableDictionary * tempDic=[NSMutableDictionary dictionary];
    for (NSString * key in keys)
    {
        NSString * translated=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:key];
        NSNumber * index=[preferredFlagForLan2 objectForKey:key];
        [tempDic setObject:index forKey:translated];
    }
    preferredFlagForLan=tempDic;
}

- (id) initWithMultipleSelectionTableView:(UITableView *) myTableView2 
                                textArray:(NSArray *) textArray2 
                            selectedItems:(NSArray *) selectedItems2
                flagIndexForSelectedItems:(NSArray *) flagIndexForSelectedItems2
                                  textTag:(NSString *) textTag2
                                 delegate:(id<LanguageSelectorControllerDelegate>) delegate2

{
    self = [super init];
    if (self)
    {
        self.myTableView=myTableView2;
        self.textArray=textArray2;
        self.selectedItems=selectedItems2;
        self.flagIndexForSelectedItems=flagIndexForSelectedItems2;
        self.preferredFlagForLan=nil;
        self.multiple=YES;
        self.showFlags=NO;
        self.textTag=textTag2;
        self.delegate=delegate2;
        
        self.myTableView.delegate=self;
        self.myTableView.dataSource=self;
        
        //Security measure
        if (self.multiple)
        {
            if ([self.flagIndexForSelectedItems count]!=[self.selectedItems count])
            {
                NSMutableArray * aux=[NSMutableArray arrayWithCapacity:[self.selectedItems count]];
                for (int i=0; i<[self.selectedItems count]; i++)
                    [aux addObject:[NSNumber numberWithInt:0]];
                self.flagIndexForSelectedItems=aux;
            }
        }
        
        self.selected=[NSMutableArray arrayWithCapacity:[self.textArray count]];
        self.selectedFlags=[NSMutableDictionary dictionaryWithCapacity:[self.textArray count]];
        for (int i=0; i<[self.textArray count]; i++)
        {
            NSString * str=[self.textArray objectAtIndex:i];
            if ([self.selectedItems containsObject:str])
            {
                [self.selected addObject:[NSNumber numberWithInt:i]];
                if (self.multiple)
                {
                    NSInteger index=[self.selectedItems indexOfObject:str];
                    [self.selectedFlags setObject:[self.flagIndexForSelectedItems objectAtIndex:index] forKey:[NSNumber numberWithInt:i]];
                } 
            }
        }
    }
    return self;
}

- (id) initWithSingleSelectionTableView:(UITableView *) myTableView2 
                              textArray:(NSArray *) textArray2 
                          selectedItems:(NSArray *) selectedItems2
                    preferredFlagForLan:(NSDictionary *) preferredFlagForLan2
                              showFlags: (BOOL) showFlags2
                                textTag:(NSString *) textTag2
                               delegate:(id<LanguageSelectorControllerDelegate>) delegate2
{
    self = [super init];
    if (self)
    {
        self.myTableView=myTableView2;
        self.textArray=textArray2;
        self.selectedItems=selectedItems2;
        self.multiple=NO;
        self.showFlags=showFlags2;
        self.preferredFlagForLan=preferredFlagForLan2;
        self.flagIndexForSelectedItems=nil;
        self.textTag=textTag2;
        self.delegate=delegate2;
        
        self.myTableView.delegate=self;
        self.myTableView.dataSource=self;
        
        //Security measure
        if (self.multiple)
        {
            if ([self.flagIndexForSelectedItems count]!=[self.selectedItems count])
            {
                NSMutableArray * aux=[NSMutableArray arrayWithCapacity:[self.selectedItems count]];
                for (int i=0; i<[self.selectedItems count]; i++)
                    [aux addObject:[NSNumber numberWithInt:0]];
                self.flagIndexForSelectedItems=aux;
            }
        }
        
        self.selected=[NSMutableArray arrayWithCapacity:[self.textArray count]];
        self.selectedFlags=[NSMutableDictionary dictionaryWithCapacity:[self.textArray count]];
        for (int i=0; i<[self.textArray count]; i++)
        {
            NSString * str=[self.textArray objectAtIndex:i];
            if ([self.selectedItems containsObject:str])
            {
                [self.selected addObject:[NSNumber numberWithInt:i]];
                if (self.multiple)
                {
                    NSInteger index=[self.selectedItems indexOfObject:str];
                    [self.selectedFlags setObject:[self.flagIndexForSelectedItems objectAtIndex:index] forKey:[NSNumber numberWithInt:i]];
                } 
            }
        }
    }
    return self;
}

- (id) initWithTableView:(UITableView *) myTableView2 
               textArray:(NSArray *) textArray2 
           selectedItems:(NSArray *) selectedItems2
flagIndexForSelectedItems:(NSArray *) flagIndexForSelectedItems2
                multiple:(BOOL) multiple2
showFlagInSingleSelection: (BOOL) showFlags2
                 textTag:(NSString *) textTag2
                delegate:(id<LanguageSelectorControllerDelegate>) delegate2
{
    self = [super init];
    if (self)
    {
        self.myTableView=myTableView2;
        self.textArray=textArray2;
        self.selectedItems=selectedItems2;
        self.flagIndexForSelectedItems=flagIndexForSelectedItems2;
        self.multiple=multiple2;
        self.showFlags=showFlags;
        self.textTag=textTag2;
        self.delegate=delegate2;
        
        self.myTableView.delegate=self;
        self.myTableView.dataSource=self;
        
        //Security measure
        if (self.multiple)
        {
            if ([self.flagIndexForSelectedItems count]!=[self.selectedItems count])
            {
                NSMutableArray * aux=[NSMutableArray arrayWithCapacity:[self.selectedItems count]];
                for (int i=0; i<[self.selectedItems count]; i++)
                    [aux addObject:[NSNumber numberWithInt:0]];
                self.flagIndexForSelectedItems=aux;
            }
        }
        
        self.selected=[NSMutableArray arrayWithCapacity:[self.textArray count]];
        self.selectedFlags=[NSMutableDictionary dictionaryWithCapacity:[self.textArray count]];
        for (int i=0; i<[self.textArray count]; i++)
        {
            NSString * str=[self.textArray objectAtIndex:i];
            if ([self.selectedItems containsObject:str])
            {
                [self.selected addObject:[NSNumber numberWithInt:i]];
                if (self.multiple)
                {
                    NSInteger index=[self.selectedItems indexOfObject:str];
                    [self.selectedFlags setObject:[self.flagIndexForSelectedItems objectAtIndex:index] forKey:[NSNumber numberWithInt:i]];
                } 
            }
        }
    }
    return self;
}

- (void) dealloc
{
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView = nil;
}


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.textArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"LanguageSelectorControllerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:18];
    
    LextTalkAppDelegate * del=[LextTalkAppDelegate sharedDelegate];
    NSString * language=[self.textArray objectAtIndex:indexPath.row];
    NSString * masterLan=[LanguageReference getMasterLanForAppLan:[LanguageReference appLan] andLanName:language];
    
    // Configure the cell...
	cell.textLabel.text=language;
    
    //Añadir el UISegmentedControl con las banderas, solo para multiple en principio
    if (self.multiple)
    {
        NSArray * dataArray=[LanguageReference flagsForMasterLan:masterLan];
        CGRect imageRect=CGRectMake(0, 0, 30, 20);
        NSMutableArray * imageArray=[NSMutableArray arrayWithCapacity:[dataArray count]];
        
        NSInteger counter=0;
        for (NSData * data in dataArray)
        {
            NSString * imageName=[masterLan stringByAppendingFormat:@"-%ld", (long)counter];
            counter ++;
            UIImage * image=[del.imageCache getImage:imageName withBigSize:NO];
            if (image==nil)
            {
                image=[UIImage imageWithData:data];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 20), NO, [UIScreen mainScreen].scale);
                [image drawInRect:imageRect];
                image=UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [del.imageCache putImage:image forName:imageName withBigSize:NO];
            }
            
            if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            [imageArray addObject:image];
        }
        MySegmentedControl * seg=[[MySegmentedControl alloc] initWithItems:imageArray];
        seg.tag = indexPath.row;
        
        
        //Accesroy, 5 seperation, 14 check image size
        UIView * accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, seg.frame.size.width + 5.0 + 14.0, seg.frame.size.height)];
        [accessoryView addSubview:seg];
        
        UIImage * image;
        if ([self.selectedFlags objectForKey:[NSNumber numberWithInteger:indexPath.row]])
            image = [UIImage imageNamed:@"CheckBlue"];
        else
            image = [UIImage imageNamed:@"CheckTrans"];
        
        UIImageView * imageView=[[UIImageView alloc] initWithImage:image];
        imageView.frame=CGRectMake(seg.frame.size.width + 5.0, (seg.frame.size.height - 14.0)/2.0, 14, 11);
        [accessoryView addSubview:imageView];
        cell.accessoryView = accessoryView;
        
        //Select the right flag in the segmented control
        if ([self.selectedFlags objectForKey:[NSNumber numberWithInteger:indexPath.row]])
        {
            NSInteger index=[[self.selectedFlags objectForKey:[NSNumber numberWithInteger:indexPath.row]] intValue];
            seg.selectedSegmentIndex=index;
        }
        //it has to be here, before setting the index of the seg, otherwise it fires the method flagChanged when it shouldn't and it doesn't work
        [seg addTarget:self action:@selector(flagChanged:) forControlEvents:UIControlEventValueChanged];
        
        
        
        if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 7)
            seg.tintColor = [UIColor whiteColor];
        
        
        /*
        CGRect cellRect=[tableView rectForRowAtIndexPath:indexPath];
        CGRect segRect=CGRectMake(cellRect.size.width - seg.frame.size.width - 32  ,
                                  (int)((cellRect.size.height- seg.frame.size.height)/2), 
                                  seg.frame.size.width, 
                                  seg.frame.size.height);
        seg.frame=segRect;
        seg.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
        //[seg addTarget:self action:@selector(flagChanged:) forControlEvents:UIControlEventValueChanged];
        seg.tag=555;
        
        
        
        [cell addSubview:seg];
        */
    }
    else
    {
        cell.accessoryView = nil;
        
        if ([self.selected containsObject:[NSNumber numberWithInteger:indexPath.row]])
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        else 
            cell.accessoryType=UITableViewCellAccessoryNone;
        if (self.showFlags)
        {
            //¿Use preference from the user if the flag is among his selection of languages?
            NSInteger index=0;
            //NSLog(@"Preferred flags: %@", self.preferredFlagForLan);
            index=[[self.preferredFlagForLan objectForKey:[self.textArray objectAtIndex:indexPath.row]] intValue];
            
            //NSString * imageName=[masterLan stringByAppendingFormat:@"-%d", index];
            //UIImage * image=[del.imageCache getImage:imageName withBigSize:YES];
            UIImage * image = nil;
            if (image==nil)
            {
                //image=[UIImage imageWithData:[LanguageReference flagForMasterLan:masterLan andId:index]];
                if ([self.textTag isEqualToString:@"Learning"] || [self.textTag isEqualToString:@"From"])
                    image = [IconGeneration smallWithGlowIconForLearningLan:masterLan withFlag:index];
                else
                    image = [IconGeneration smallWithGlowIconForSpeakingLan:masterLan withFlag:index];
                /*
                CGSize iconSize=CGSizeMake(45, 30);
                CGRect imageRect = CGRectMake(0.0, 0.0, iconSize.width, iconSize.height);
                UIGraphicsBeginImageContextWithOptions(iconSize, NO, [UIScreen mainScreen].scale);
                [image drawInRect:imageRect];
                image = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned
                UIGraphicsEndImageContext();
                */
                //[del.imageCache putImage:image forName:imageName withBigSize:YES];
            }
            
            cell.imageView.image=image;
            //cell.imageView.frame=CGRectMake(0, 0, 30, 20);
                                                                                             
        }
    }
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	
	//Quito la que pudiera estar seleccionada
	if (multiple)
	{
        /*
         if ([self.selected containsObject:[NSNumber numberWithInt:indexPath.row]])
         [self.selected removeObject:[NSNumber numberWithInt:indexPath.row]];
         else 
         [self.selected addObject:[NSNumber numberWithInt:indexPath.row]];
         
         [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] 
         withRowAnimation:UITableViewRowAnimationFade];
         */
        
        
        
	}
	if (!self.multiple)
	{
		int prevSelected=[[self.selected lastObject] intValue];
		self.selected=[NSMutableArray arrayWithObject:[NSNumber numberWithInteger:indexPath.row]];
		
		[self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:prevSelected inSection:0]] 
                                withRowAnimation:UITableViewRowAnimationFade];
		[self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] 
                                withRowAnimation:UITableViewRowAnimationFade];
        
        NSString * str=[self.textArray objectAtIndex:[[self.selected lastObject] intValue]];
        //Traducción a master languages:
        NSString * str2=[LanguageReference getMasterLanForAppLan:[LanguageReference appLan] andLanName:str];
        if ([delegate respondsToSelector:@selector(selectedItem:withTextTag:)])
            [delegate selectedItem:str2 withTextTag:self.textTag];
	}
    else
    {
        //Touching the row deselects the flag which is set, or sets the first one.
        if ([self.selectedFlags objectForKey:[NSNumber numberWithInteger:indexPath.row]])
        {
            //Deselect
            [self.selectedFlags removeObjectForKey:[NSNumber numberWithInteger:indexPath.row]];
            
        }
        else
        {
            //Select the first one
            [self.selectedFlags setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInteger:indexPath.row]];
        }
        [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] 
                                withRowAnimation:UITableViewRowAnimationFade];
        
        [self sendMultipleDelegate];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor=[UIColor clearColor];
}

#pragma mark Flag delegate
- (void) flagChanged:(MySegmentedControl *) seg
{
    NSIndexPath * indexPath= [NSIndexPath indexPathForRow:seg.tag inSection:0];
    if (seg.selectedSegmentIndex>=0)
    {
        //If it is already selected, I remove it
        if ([[self.selectedFlags objectForKey:[NSNumber numberWithInteger:indexPath.row]] isEqualToNumber:[NSNumber numberWithInteger:seg.selectedSegmentIndex]])
        {
            [self.selectedFlags removeObjectForKey:[NSNumber numberWithInteger:indexPath.row]];
            seg.selectedSegmentIndex=-1;
        }
        else
            [self.selectedFlags setObject:[NSNumber numberWithInteger:seg.selectedSegmentIndex] forKey:[NSNumber numberWithInteger:indexPath.row]];
    }
    else
        [self.selectedFlags removeObjectForKey:[NSNumber numberWithInteger:indexPath.row]];
    
    [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] 
                            withRowAnimation:UITableViewRowAnimationFade];
    
    [self sendMultipleDelegate];
}


- (void) sendMultipleDelegate
{
    if ([self.delegate respondsToSelector:@selector(selectedItems:withFlags:withTextTag:)])
    {
        NSArray * allKeys=[self.selectedFlags allKeys];
        NSArray * sorted=[allKeys sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray * texts=[NSMutableArray arrayWithCapacity:[allKeys count]];
        NSMutableArray * flags=[NSMutableArray arrayWithCapacity:[allKeys count]];
        for (NSNumber * key in sorted)
        {
            [texts addObject:[self.textArray objectAtIndex:[key intValue]]];
            [flags addObject:[self.selectedFlags objectForKey:key]];
        }
        //self.selectedItems=texts;
        //No utilizo el setTextItems para no traducir, si lo hago da error
        selectedItems=texts;
        self.flagIndexForSelectedItems=flags;
        
        //Traducción
        NSMutableArray * array=[NSMutableArray arrayWithCapacity:[self.selectedItems count]];
        for (NSString * str in self.selectedItems)
            [array addObject:[LanguageReference getMasterLanForAppLan:[LanguageReference appLan] andLanName:str]];
        
        //[delegate selectedItems:[NSArray arrayWithArray:self.selectedItems] withFlags:[NSArray arrayWithArray:self.flagIndexForSelectedItems] withTextTag:self.textTag];
        [delegate selectedItems:[NSArray arrayWithArray:array] withFlags:[NSArray arrayWithArray:self.flagIndexForSelectedItems] withTextTag:self.textTag];
    }
}


- (void) resetSelections
{
    self.selected=[NSMutableArray arrayWithCapacity:[self.textArray count]];
    self.selectedFlags=[NSMutableDictionary dictionaryWithCapacity:[self.textArray count]];
    
    for (int i=0; i<[self.textArray count]; i++)
    {
        NSString * str=[self.textArray objectAtIndex:i];
        if ([self.selectedItems containsObject:str])
        {
            [self.selected addObject:[NSNumber numberWithInt:i]];
            if (self.multiple)
            {
                NSInteger index=[self.selectedItems indexOfObject:str];
                [self.selectedFlags setObject:[self.flagIndexForSelectedItems objectAtIndex:index] forKey:[NSNumber numberWithInt:i]];
            } 
        }
    }
}

- (void) selectAndScrollToItem:(NSString *) item
{
    if (!self.multiple)
    {
        NSString * translated=[LanguageReference getLanForAppLan:[LanguageReference appLan] andMasterLan:item];
        NSInteger pos = [self.textArray indexOfObject:translated];
        if (pos != NSNotFound)
        {
            self.selected = [NSMutableArray arrayWithObject:[NSNumber numberWithInteger:pos]];
            NSIndexPath * index = [NSIndexPath indexPathForRow:pos inSection:0];
            [self.myTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            [self.myTableView reloadData];
        }
        else
        {
            NSLog(@"Index not found inselectAndScrollToItem");
        }
    }
}
 

@end
