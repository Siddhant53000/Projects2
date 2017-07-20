//
//  LocationViewController.m
//  LextTalk
//
//  Created by Isaaca Hoglen on 11/20/16.
//
//

#import "LocationViewController.h"
#import "LocationDBHandler.h"

@interface LocationViewController ()
@property (strong, nonatomic) UISwitch *locationButton;
@property (strong, nonatomic) UITextField *locField;
@property (strong, nonatomic) UISwitch *isVisibleSwitch;
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Location"];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    [addButton setTitle:@"Done"];
    self.navigationItem.rightBarButtonItem = addButton;
    _locationButton = [[UISwitch alloc] init];
    [_locationButton addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
    float yOrigin = self.navigationItem.accessibilityFrame.size.height + 100;
    UILabel *locationLabel = [[UILabel alloc] init];
    [locationLabel setFrame:CGRectMake(10, yOrigin, 250, 20)];
    [_locationButton setFrame:CGRectMake(255,yOrigin, 25, 10)];
    [_locationButton setTintColor:[UIColor greenColor]];
    [_locationButton setOn:[[LocationDBHandler getSharedInstance] getUseDefaultLocation]];
    NSLog(@"Default loc: %d", [[LocationDBHandler getSharedInstance] getUseDefaultLocation]);

    [locationLabel setTextColor:[UIColor blackColor]];
    [locationLabel setBackgroundColor:[UIColor clearColor]];
    _locField = [[UITextField alloc] init];
    [_locField setFrame:CGRectMake(10, 50+yOrigin, 300, 40)];
    [_locField setBackgroundColor:[UIColor greenColor]];
    NSString *textFieldText = [[LocationDBHandler getSharedInstance] getUserLocation];
    [_locField setText:textFieldText];
    [_locField setTextColor:[UIColor blackColor]];
    [_locField setEnabled:false];
    [_locField setClearsOnBeginEditing:true];
    [locationLabel setText:@"Use Default location?"];
    _isVisibleSwitch = [[UISwitch alloc] init];
    UILabel *isVisibleLabel = [[UILabel alloc] init];
    [isVisibleLabel setText:@"Visible on the map?"];
    [isVisibleLabel setFrame:CGRectMake(10, 100+yOrigin, 250, 20)];
    [_isVisibleSwitch setFrame:CGRectMake(255, 100+yOrigin, 25, 10)];
    [_isVisibleSwitch setTintColor:[UIColor greenColor]];
    [_isVisibleSwitch addTarget:self action:@selector(visibileSwitched:) forControlEvents:UIControlEventValueChanged];
    [_isVisibleSwitch setOn:[[LocationDBHandler getSharedInstance] getIsVisible]];
    [isVisibleLabel setTextColor:[UIColor blackColor]];
    [isVisibleLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:locationLabel];
    [self.view addSubview:_locationButton];
    [self.view addSubview:_locField];
    [self.view addSubview:isVisibleLabel];
    [self.view addSubview:_isVisibleSwitch];
}

- (void)addItem: (id)sender {
    NSString *locationField = [_locField text];
    if (locationField.length > 0 && [_locationButton isOn]) {
        [[LTDataSource sharedDataSource].localUser setPhysAddress:locationField];
        [[LocationDBHandler getSharedInstance] setLocationInformation:[_locationButton isOn] forLocation:locationField andIsVisible:[_isVisibleSwitch isOn]];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:locationField completionHandler:^(NSArray* placemarks, NSError *error) {
            for (CLPlacemark* aPlacemark in placemarks) {
                CLLocationCoordinate2D newCoords = CLLocationCoordinate2DMake(aPlacemark.location.coordinate.latitude, aPlacemark.location.coordinate.longitude);
                [[LTDataSource sharedDataSource].localUser setCoordinate:newCoords];
            }
        }];
    } else {
        [[LTDataSource sharedDataSource].localUser setCoordinate:[[LTDataSource sharedDataSource] latestLocation]];
        [[LocationDBHandler getSharedInstance] setLocationInformation:0 forLocation:@"Street Address, City, Country" andIsVisible:[_isVisibleSwitch isOn]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switched: (id)sender {
    bool useDefault = [_locationButton isOn];
    [[LTDataSource sharedDataSource].localUser setLocationSwitch:useDefault];
    if (useDefault) {
        [_locField setEnabled:true];
    } else {
        [_locField setEnabled:false];
    }
}

-(void)visibileSwitched:(id) sender {
    //I don't do anything, this is to be implemented later
    NSLog(@"I have been switched!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
