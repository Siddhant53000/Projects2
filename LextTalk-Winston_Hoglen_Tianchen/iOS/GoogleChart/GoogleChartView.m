//
//  GoogleChartView.m
// LextTalk
//
//  Created by nacho on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleChartView.h"
#import "TeamReference.h"


@implementation GoogleChartView
@synthesize	points;
@synthesize data;

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection: (NSURLConnection *) theConnection didFailWithError: (NSError *)error {
	NSLog(@"Error loading Google Chart: %@", [error description]);
	[theConnection release];
}

- (void)connection: (NSURLConnection *) theConnection didReceiveData: (NSData *) theData {
    //NSLog(@"didReceiveData: %d bytes", [theData length]);    
	[data appendData: theData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *) theConnection {
    NSLog(@"connectionDidFinishLoading");  
    
    UIImage *anImage = [[UIImage alloc] initWithData: data];
    [self setImage: anImage];
    [anImage release];
    [data release];
}

#pragma mark -
#pragma mark GoogleChartView methods
#define BASE_URL @"http://chart.apis.google.com/chart"
#define OPTIONS @"chf=bg,s,00000000\
&chxs=0,FFFFFF,11.5\
&chxt=x\
&cht=p3"

- (void) loadChart {
    return;
    
    NSString *legend = @"chl=";
    NSString *values = @"chd=t:";
    CGFloat total = 0;
    for (GFTeamStat *t in points){
        total += t.percentage/100.0;
        GFTeam *team = [TeamReference newTeamWithId: t.teamId];
        legend = [legend stringByAppendingFormat: @"%@|", team.name];
        values = [values stringByAppendingFormat: @"%f|", t.percentage/100];        
        [team release];
    }
    
    legend = [legend stringByAppendingFormat: @"%@", @"Rest"];
    values = [values stringByAppendingFormat: @"%f", 1 - total];        
    
	NSString *chartURL = [NSString stringWithFormat: @"%@?chs=%dx%d&%@&%@&%@", BASE_URL, (int)self.frame.size.width, (int) self.frame.size.height, OPTIONS , legend, values];
    
    NSString *encodedString = [chartURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURLRequest *request = [[[NSURLRequest alloc] initWithURL: [NSURL URLWithString: encodedString]] autorelease];
    data = [[NSMutableData alloc] init];    
	[data setLength: 0];
	
    [NSURLConnection connectionWithRequest: request delegate: self];
    
    NSLog(@"Loading google chart: %@", chartURL);
}

#pragma mark -
#pragma mark UIImageView methods

/*
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
