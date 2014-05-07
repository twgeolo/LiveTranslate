//
//  ChatMapViewController.h
//  LiveTranslate
//
//  Created by George Lo on 5/7/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "QTree.h"
#import "QCluster.h"
#import "ClusterAnnotationView.h"
#import "ChatAnnotation.h"

@interface ChatMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) QTree *qTree;

@end
