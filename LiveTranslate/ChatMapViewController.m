//
//  ChatMapViewController.m
//  LiveTranslate
//
//  Created by George Lo on 5/7/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "ChatMapViewController.h"

@interface ChatMapViewController ()

@end

@implementation ChatMapViewController {
    MKMapView *myMapView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [ApplicationDelegate customizeViewController:self tableView:NO];
    self.navigationItem.title = @"Chat Map";
    
    myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(20, 64+20-5, ScreenWidth-40, ScreenHeight-64-40+5)];
    [myMapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(40.4422655, -86.9265415), 100000, 100000) animated:YES];
    myMapView.mapType = [UserDefaults integerForKey:@"MapType"];
    myMapView.showsBuildings = YES;
    myMapView.showsPointsOfInterest = YES;
    myMapView.showsUserLocation = YES;
    myMapView.delegate = self;
    [self.view addSubview:myMapView];
    
    self.qTree = [QTree new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        srand48(time(0));
        FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT Friends.displayName, Messages.message, Messages.lat, Messages.lon FROM Messages INNER JOIN Friends WHERE Messages.withUser == Friends.userName"];
        while ([s next]) {
            if ([s objectForColumnIndex:2]==[NSNull null]) {
                continue;
            }
            ChatAnnotation *point = [[ChatAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake([[s objectForColumnIndex:2] floatValue], [[s objectForColumnIndex:3] floatValue]);
            point.title = [s objectForColumnIndex:0];
            point.subtitle = [s objectForColumnIndex:1];
            [self.qTree insertObject:point];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadAnnotations];
        });
    });
    
    UIButton *mapTypeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    mapTypeBtn.frame = CGRectMake(0, 0, 25, 25);
    [mapTypeBtn setImage:[UIImage imageNamed:@"Map Type"] forState:UIControlStateNormal];
    [mapTypeBtn addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapTypeBtn];
}

- (IBAction)changeMapType:(id)sender {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Map Type" andMessage:nil];
    [alertView addButtonWithTitle:@"Standard" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alert){
        [UserDefaults setInteger:0 forKey:@"MapType"];
        [UserDefaults synchronize];
        myMapView.mapType = 0;
    }];
    [alertView addButtonWithTitle:@"Satellite" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alert){
        [UserDefaults setInteger:1 forKey:@"MapType"];
        [UserDefaults synchronize];
        myMapView.mapType = 1;
    }];
    [alertView addButtonWithTitle:@"Hybrid" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alert){
        [UserDefaults setInteger:2 forKey:@"MapType"];
        [UserDefaults synchronize];
        myMapView.mapType = 2;
    }];
    [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeDestructive handler:nil];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

- (void)mapView:(MKMapView*)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self reloadAnnotations];
}

-(void)reloadAnnotations
{
    if( !self.isViewLoaded ) {
        return;
    }
    
    const MKCoordinateRegion mapRegion = myMapView.region;
    BOOL useClustering = YES;
    const CLLocationDegrees minNonClusteredSpan = useClustering ? MIN(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5 : 0;
    NSArray* objects = [self.qTree getObjectsInRegion:mapRegion minNonClusteredSpan:minNonClusteredSpan];
    
    NSMutableArray* annotationsToRemove = [myMapView.annotations mutableCopy];
    [annotationsToRemove removeObject:myMapView.userLocation];
    [annotationsToRemove removeObjectsInArray:objects];
    [myMapView removeAnnotations:annotationsToRemove];
    
    NSMutableArray* annotationsToAdd = [objects mutableCopy];
    [annotationsToAdd removeObjectsInArray:myMapView.annotations];
    
    [myMapView addAnnotations:annotationsToAdd];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if( [annotation isKindOfClass:[MKUserLocation class]] ) {
        return nil;
    }
    
    if( [annotation isKindOfClass:[QCluster class]] ) {
        ClusterAnnotationView* annotationView = (ClusterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:[ClusterAnnotationView reuseId]];
        if( !annotationView ) {
            annotationView = [[ClusterAnnotationView alloc] initWithCluster:(QCluster*)annotation];
        }
        annotationView.cluster = (QCluster*)annotation;
        return annotationView;
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
