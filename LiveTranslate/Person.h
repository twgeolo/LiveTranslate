//
//  Person.h
//  LiveTranslate
//
//  Created by George Lo on 4/23/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *realName;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *status;
@property (nonatomic) NSArray *phone;
@property (nonatomic) NSString *gender;
@property (nonatomic) NSData *imageData;

@end
