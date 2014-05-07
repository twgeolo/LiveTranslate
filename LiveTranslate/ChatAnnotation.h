//
//  ChatAnnotation.h
//  LiveTranslate
//
//  Created by George Lo on 5/7/14.
//  Copyright (c) 2014 George Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "QTree/QTree.h"

@interface ChatAnnotation : NSObject <MKAnnotation, QTreeInsertable>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

- (NSString *)title;

@end
