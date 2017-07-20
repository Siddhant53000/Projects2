//
//  ImageViewerViewController.m
//  LextTalk
//
//  Created by Raúl Martín Carbonell on 10/27/13.
//
//

#import "ImageViewerViewController.h"
#import "GeneralHelper.h"

@interface ImageViewerViewController ()

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation ImageViewerViewController

- (CGSize) contentSizeForViewInPopover
{
    CGSize size=CGSizeMake(320, 375);
    return size;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.scrollView.delegate = nil;
    self.scrollView = nil;
    self.imageView = nil;
}

- (void) loadView
{
    CGRect applicationFrame=[UIScreen mainScreen].applicationFrame;
    CGRect rect = applicationFrame;
    //NSLog(@"width: %f, height: %f", applicationFrame.size.width, applicationFrame.size.height);
    rect.size.height -= self.navigationController.navigationBar.frame.size.height;
    rect.size.height -= self.tabBarController.tabBar.frame.size.height;
    
    self.imageView = [[UIImageView alloc] initWithFrame:rect];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:rect];
    self.scrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.contentSize = self.imageView.bounds.size;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor=[UIColor blackColor];
    [self.scrollView addSubview:self.imageView];
    
    self.view = [[UIView alloc] initWithFrame:rect];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor=[UIColor blackColor];
    [self.view addSubview:self.scrollView];
    
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap.numberOfTapsRequired=2;
    tap.numberOfTouchesRequired=1;
    [self.scrollView addGestureRecognizer:tap];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [GeneralHelper plainBarButtonItemWithText:nil image:[UIImage imageNamed:@"arrow-back"] target:self selector:@selector(popViewController)];
    
    self.imageView.image = self.image;
}

- (void) popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutBanners:YES];
    
    [self.imageView sizeToFit];
    [self.scrollView sizeToFit];
    
    //al hacer el sizeToFit parece que se descolocan los sitemas de coordenadas
    //Asi quedan alineados
    CGRect rect=CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    //CGRect rect=CGRectMake(0, 0, self.imageView.bounds.size.width, self.imageView.bounds.size.height);
    self.imageView.frame=rect;
    
    self.scrollView.contentSize=self.image.size;
    
    self.scrollView.maximumZoomScale=3;
    self.scrollView.delegate=self;
    
    //Calculate and set minimum zoom
    double zoom=[self calculateAndSetMinimumZoom];
    //----------------------------------------
    
    //Así consigo que llene toda la pantalla
    //self.scrollView.zoomScale=self.scrollView.minimumZoomScale;
    self.scrollView.zoomScale=zoom;
    [self scrollViewDidZoom:self.scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
    [self handleRotation];
}



- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size
          withTransitionCoordinator:coordinator];
    
    //Dentro de este bloque las vistas ya tienen al tamaño al que transitan, así que no es necesario arrastrar size
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //update views here, e.g. calculate your view
         [self handleRotation];
         
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
     }];
}

- (void) handleRotation
{
    //Debo distinguir si ya está cargada la imagen o no
    //Si no lo está e itento hace las cosas del zoom, lo que ocurre es que el indicador
    //se va a la esquina de abajo a la derecha
    if (self.image!=nil)
    {
        [self calculateAndSetMinimumZoom];
        
        
        //if (self.scrollView.zoomScale<self.scrollView.minimumZoomScale)
        self.scrollView.zoomScale=self.scrollView.minimumZoomScale;
        
        [self scrollViewDidZoom:self.scrollView];
    }
}

#pragma mark - ImageViewerViewController
-(double) calculateAndSetMinimumZoom
{
	CGFloat zoom = [self calculateMinimumZoom];
    
	if (zoom>1)
		self.scrollView.minimumZoomScale=1;
	else
		self.scrollView.minimumZoomScale=zoom;
	
	return zoom;
}

-(double) calculateMinimumZoom
{
    CGSize screenSize=self.scrollView.bounds.size;
    CGSize imageSize=self.image.size;
    //NSLog(@"ancho: %f", screenSize.width);
    //NSLog(@"alto: %f", screenSize.height);
    
    //Fix for iOS 7 onwards
    screenSize.height -= self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + self.tabBarController.tabBar.frame.size.height + 2*self.lastAdHeight;
    
    CGFloat heightReason=imageSize.height / screenSize.height;
    CGFloat widthReason=imageSize.width / screenSize.width;
    
    CGFloat zoom;
    if (heightReason>widthReason)
        zoom= 1/heightReason;
    else
        zoom= 1/widthReason;
    
    return zoom;
}

- (void) doubleTap:(UITapGestureRecognizer *) gesture
{
    double zoom = [self calculateAndSetMinimumZoom];
    [self.scrollView setZoomScale:zoom animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)pScrollView {
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark -
#pragma mark Ad Reimplementation
- (CGFloat) layoutBanners:(BOOL) animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    CGFloat adHeight=[super layoutBanners:animated];
    CGRect newFrame=self.view.frame;//If I do it with the scrollview, it reduces itself everytime an ad is refreshed
    newFrame.size.height=newFrame.size.height - adHeight;
    
    //Needed in iOS 7
    newFrame.origin = CGPointMake(0, 0);
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.scrollView.frame=newFrame;
                     }];
    return 0.0;
}

@end
