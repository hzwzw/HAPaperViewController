//
//  HAViewController.m
//  Paper
//
//  Created by Heberti Almeida on 03/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "HAViewController.h"
#import "HACollectionViewSmallLayout.h"
#import "HACollectionViewLargeLayout.h"
#import "TLTransitionLayout.h"

#define kTransitionSpeed 0.02f

static const CGFloat kLargeLayoutScale = 2.5;

@interface HAViewController ()

@property (nonatomic, assign) NSInteger slide;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UIImageView *reflected;
@property (nonatomic, strong) HACollectionViewLargeLayout *largeLayout;
@property (nonatomic, strong) HACollectionViewSmallLayout *smallLayout;
@property (nonatomic, getter=isFullscreen) BOOL fullscreen;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic, assign) BOOL isZooming;
@property (nonatomic, assign) CGFloat lastScale;

@property (strong, nonatomic) TLTransitionLayout *transitionLayout;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinch;
@property (nonatomic) CGFloat initialScale;


@end

@implementation HAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _galleryImages = @[@"Image", @"Image1", @"Image2", @"Image3", @"Image4"];
    _slide = 0;
    
//    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinchGesture:)];
//    [_collectionView addGestureRecognizer:gesture];
    
    // Custom layouts
    _smallLayout = [[HACollectionViewSmallLayout alloc] init];
    _largeLayout = [[HACollectionViewLargeLayout alloc] init];
    
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_collectionView addGestureRecognizer:pinchGestureRecognizer];
    
//    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_smallLayout];
//    [_collectionView registerClass:[AFCollectionViewCell class] forCellWithReuseIdentifier:ItemIdentifier];
//    _collectionView.delegate = self;
//    _collectionView.dataSource = self;
    
    _collectionView.collectionViewLayout = _smallLayout;
    _collectionView.clipsToBounds = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    // Shadow on collection
//    [_collectionView setClipsToBounds:NO];
//    [_collectionView.layer setShadowOffset:CGSizeMake(0, 0)];
//    [_collectionView.layer setShadowColor:[[UIColor blackColor] CGColor]];
//    [_collectionView.layer setShadowRadius:6.0];
//    [_collectionView.layer setShadowOpacity:0.5];
//
//    // Improve shadow performance
//    CGPathRef path = [UIBezierPath bezierPathWithRect:_collectionView.bounds].CGPath;
//    [_collectionView.layer setShadowPath:path];
    
    
    // Init mainView
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mainView.clipsToBounds = YES;
    _mainView.layer.cornerRadius = 4;
    [self.view insertSubview:_mainView belowSubview:_collectionView];
    
    // ImageView on top
    _topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _reflected = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_topImage.bounds), 320, 320)];
    [_mainView addSubview:_topImage];
    [_mainView addSubview:_reflected];
    
    
    // Reflect imageView
    _reflected.transform = CGAffineTransformMakeScale(1.0, -1.0);
    
    
    // Gradient to top image
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _topImage.bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] CGColor],
                        (id)[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    [_topImage.layer insertSublayer:gradient atIndex:0];
    
    
    // Gradient to reflected image
    CAGradientLayer *gradientReflected = [CAGradientLayer layer];
    gradientReflected.frame = _reflected.bounds;
    gradientReflected.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor],
                                 (id)[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    [_reflected.layer insertSublayer:gradientReflected atIndex:0];
    
    
    // Content perfect pixel
    UIView *perfectPixelContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_topImage.bounds), 1)];
    perfectPixelContent.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    [_topImage addSubview:perfectPixelContent];
    
    
    // Label logo
    UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 290, 0)];
    logo.backgroundColor = [UIColor clearColor];
    logo.textColor = [UIColor whiteColor];
    logo.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    logo.text = @"Paper";
    [logo sizeToFit];
    // Label Shadow
    [logo setClipsToBounds:NO];
    [logo.layer setShadowOffset:CGSizeMake(0, 0)];
    [logo.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [logo.layer setShadowRadius:1.0];
    [logo.layer setShadowOpacity:0.6];
    [_mainView addSubview:logo];
    
    
    // Label Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, logo.frame.origin.y + CGRectGetHeight(logo.frame) + 8, 290, 0)];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    title.text = @"Heberti Almeida";
    [title sizeToFit];
    // Label Shadow
    [title setClipsToBounds:NO];
    [title.layer setShadowOffset:CGSizeMake(0, 0)];
    [title.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [title.layer setShadowRadius:1.0];
    [title.layer setShadowOpacity:0.6];
    [_mainView addSubview:title];
    
    
    // Label SubTitle
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, title.frame.origin.y + CGRectGetHeight(title.frame), 290, 0)];
    subTitle.backgroundColor = [UIColor clearColor];
    subTitle.textColor = [UIColor whiteColor];
    subTitle.font = [UIFont fontWithName:@"Helvetica" size:13];
    subTitle.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit";
    subTitle.lineBreakMode = NSLineBreakByWordWrapping;
    subTitle.numberOfLines = 0;
    [subTitle sizeToFit];
    // Label Shadow
    [subTitle setClipsToBounds:NO];
    [subTitle.layer setShadowOffset:CGSizeMake(0, 0)];
    [subTitle.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [subTitle.layer setShadowRadius:1.0];
    [subTitle.layer setShadowOpacity:0.6];
    [_mainView addSubview:subTitle];
    
    
    // First Load
    [self changeSlide];
    
    // Loop gallery - fix loop: http://bynomial.com/blog/?p=67
    NSTimer *timer = [NSTimer timerWithTimeInterval:5.0f target:self selector:@selector(changeSlide) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


#pragma mark - Hide StatusBar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark - UIPinchGestureRecognizer
- (void)didReceivePinchGesture:(UIPinchGestureRecognizer*)gesture
{
    NSLog(@"scale %f", gesture.scale);
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 4;
    
//    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerTap:)];
//    twoFingerTap.numberOfTouchesRequired = 2;
//    [cell addGestureRecognizer:twoFingerTap];
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Cell"]];
    cell.backgroundView = backgroundView;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Start transition
    _transitioning = YES;
    
    if (_fullscreen) {
        _fullscreen = NO;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
        [_collectionView snapshotViewAfterScreenUpdates:YES];
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            // Change flow layout
            [_collectionView setCollectionViewLayout:_smallLayout animated:YES];
            _collectionView.backgroundColor = [UIColor clearColor];
            
            // Reset scale
            _mainView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            _transitioning = NO;
        }];
    }
    else {
        _fullscreen = YES;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            // Change flow layout
            [_collectionView setCollectionViewLayout:_largeLayout animated:YES];
            _collectionView.backgroundColor = [UIColor blackColor];
            
            // Transform to zoom in effect
            _mainView.transform = CGAffineTransformScale(_mainView.transform, 0.96, 0.96);
        } completion:^(BOOL finished) {
            _transitioning = NO;
        }];
    }
}


#pragma mark - Change slider
- (void)changeSlide
{
    if (_fullscreen == NO && _transitioning == NO) {
        if(_slide > _galleryImages.count-1) _slide = 0;
        
        UIImage *toImage = [UIImage imageNamed:_galleryImages[_slide]];
        [UIView transitionWithView:_mainView
                          duration:0.6f
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseInOut
                        animations:^{
                            _topImage.image = toImage;
                            _reflected.image = toImage;
                        } completion:nil];
        _slide++;
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

#pragma mark - Gesture Interactions
- (void)doubleFingerTap:(UITapGestureRecognizer *)pinchGestureRecognizer
{
    NSLog(@"tap 2 fingers");
    
    if ([pinchGestureRecognizer state] == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // Transform to zoom in effect
            _mainView.transform = CGAffineTransformScale(_mainView.transform, 0.96, 0.96);
        } completion:^(BOOL finished) {
            _transitioning = NO;
        }];
    } else if ([pinchGestureRecognizer state] == UIGestureRecognizerStateEnded) {
        // Reset scale
        _mainView.transform = CGAffineTransformMakeScale(1, 1);
    }
}


- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    if (pinch.state == UIGestureRecognizerStateBegan && !_transitionLayout) {
        
        // remember initial scale factor for progress calculation
        _initialScale = pinch.scale;
        
        UICollectionViewLayout *toLayout = _smallLayout == _collectionView.collectionViewLayout ? _largeLayout : _smallLayout;
        
        _transitionLayout = (TLTransitionLayout *)[_collectionView startInteractiveTransitionToCollectionViewLayout:toLayout completion:^(BOOL completed, BOOL finish) {
            if (finish) {
                _collectionView.contentOffset = _transitionLayout.toContentOffset;
            } else {
                _collectionView.contentOffset = _transitionLayout.fromContentOffset;
            }
            self.transitionLayout = nil;
        }];
        
        NSArray *visiblePoses = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:_collectionView.bounds];
        NSMutableArray *visibleIndexPaths = [NSMutableArray arrayWithCapacity:visiblePoses.count];
        for (UICollectionViewLayoutAttributes *pose in visiblePoses) {
            [visibleIndexPaths addObject:pose.indexPath];
        }
        _transitionLayout.toContentOffset = [_collectionView toContentOffsetForLayout:_transitionLayout indexPaths:visibleIndexPaths placement:TLTransitionLayoutIndexPathPlacementCenter];
        
    }
    
    else if (pinch.state == UIGestureRecognizerStateChanged && _transitionLayout && pinch.numberOfTouches > 1) {
        
        CGFloat finalScale = _transitionLayout.nextLayout == _largeLayout ? kLargeLayoutScale : 1 / kLargeLayoutScale;
        _transitionLayout.transitionProgress = transitionProgress(_initialScale, pinch.scale, finalScale, TLTransitioningEasingLinear);
    }
    else if (pinch.state == UIGestureRecognizerStateEnded) {
//    else {
//    else if (pinch.state == UIGestureRecognizerStateEnded && _transitionLayout) {
        
        if (_transitionLayout.transitionProgress > 0.3) {
            [_collectionView finishInteractiveTransition];
        } else {
            [_collectionView cancelInteractiveTransition];
        }
        
    }
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    return [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
}


//- (CGFloat)transitionRange:(CGFloat)range
//{
//    return MAX(MIN((range), 1.0), 0.0);
//}


//#pragma mark - UIViewControllerTransitioningDelegate
//- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
//    return 0.4f;
//}

@end
