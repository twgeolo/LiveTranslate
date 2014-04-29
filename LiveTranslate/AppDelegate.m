//
//  AppDelegate.m
//  LiveTranslate
//
//  Created by George Lo on 4/20/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:20]
    }];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"LiveTranslate.db"]];
    if ([db open]) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Friends (userName TEXT, realName TEXT, displayName TEXT, status TEXT, phone TEXT, gender INT, image BLOB)"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Messages (toUserName TEXT, message TEXT, TIMESTAMP TEXT)"];
    }
    [db close];
    
    if ([UserDefaults objectForKey:@"Lang"] == nil) {
        [UserDefaults setObject:@"en" forKey:@"Lang"];
        [UserDefaults synchronize];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIImage *)circularImage:(UIImage *)image withFrame:(CGRect)frame {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), NO, 0.0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath (contextRef);
    CGContextAddArc (contextRef, frame.size.width/2, frame.size.height/2, frame.size.width/2, 0, 2*M_PI, 0);
    CGContextClosePath (contextRef);
    CGContextClip (contextRef);
    CGContextScaleCTM (contextRef, frame.size.width/image.size.width, frame.size.height/image.size.height);
    
    CGRect newRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:newRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)getContacts {
        CFErrorRef *error = nil;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        
        __block BOOL accessGranted = NO;
        if (ABAddressBookRequestAccessWithCompletion != NULL) {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
        } else {
            accessGranted = YES;
        }
        
        if (accessGranted) {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
            ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
            CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
            NSMutableArray *friends = [NSMutableArray new];
            
            if (nPeople == 0) {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"No friend on our server"];
                [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
                [alertView show];
            } else {
                for (int i = 0; i < nPeople; i++) {
                    Person *currFriend = [[Person alloc] init];
                    ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                    if (person == nil) {
                        continue;
                    }
                    
                    if (ABPersonHasImageData(person)) {
                        CFDataRef imageRef = ABPersonCopyImageData(person);
                        if (imageRef) {
                            currFriend.imageData = (__bridge NSData *)imageRef;
                        }
                        CFRelease(imageRef);
                    }
                    
                    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
                    ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                        NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
                        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
                        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                       componentsJoinedByString:@""];
                        if (phoneNumber.length > 10) {
                            phoneNumber = [phoneNumber substringWithRange:NSMakeRange(phoneNumber.length-10, 10)];
                        }
                        if (phoneNumber.length == 10) {
                            phoneNumber = [NSString stringWithFormat:@"%@-%@-%@", [phoneNumber substringToIndex:3], [phoneNumber substringWithRange:NSMakeRange(3, 3)], [phoneNumber substringFromIndex:6]];
                            [phoneNumbers addObject:phoneNumber];
                        }
                    }
                    currFriend.phone = [NSArray arrayWithArray:phoneNumbers];
                    [friends addObject:currFriend];
                }
                
                NSMutableArray *friendsOnServer = [NSMutableArray new];
                for (int i=0; i<friends.count; i++) {
                    Person *currFriend = [friends objectAtIndex:i];
                    for (int j=0; j<currFriend.phone.count; j++) {
                        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/search?phone=%@", [currFriend.phone objectAtIndex:j]]]];
                        if (data) {
                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                            if ([[dict objectForKey:@"numberOfMatches"] integerValue] == 1) {
                                dict = [[dict objectForKey:@"results"] objectAtIndex:0];
                                currFriend.phone = [NSArray arrayWithObject:[currFriend.phone objectAtIndex:j]];
                                currFriend.userName = [dict objectForKey:@"name"];
                                currFriend.realName = [dict objectForKey:@"real_name"];
                                currFriend.displayName = [dict objectForKey:@"real_name"];
                                currFriend.gender = [dict objectForKey:@"gender"];
                                currFriend.status = [dict objectForKey:@"status"];
                                [friendsOnServer addObject:currFriend];
                            }
                        }
                    }
                }
                
                FMDatabase *db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"LiveTranslate.db"]];
                if ([db open]) {
                    [db executeUpdate:@"DELETE FROM Friends"];
                    for (Person *person in friendsOnServer) {
                        [db executeUpdate:@"INSERT INTO Friends (userName, realName, displayName, status, phone, gender, image) VALUES (?, ?, ?, ?, ?, ?, ?)", person.userName, person.realName, person.displayName, person.status, [person.phone objectAtIndex:0], person.gender, person.imageData];
                    }
                }
                [db close];
                [UserDefaults setInteger:1 forKey:@"LoadedContacts"];
                [UserDefaults synchronize];
            }
        } else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Cannot fetch contacts"];
            [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
            [alertView show];
        }
}

- (NSString *)languageForKey: (NSString *)key {
    if ([key isEqualToString:@"en"]) {
        return @"English";
    } else if ([key isEqualToString:@"es"]) {
        return @"Spanish";
    } else if ([key isEqualToString:@"ko"]) {
        return @"Korean";
    } else if ([key isEqualToString:@"ja"]) {
        return @"Japanese";
    } else if ([key isEqualToString:@"zh-TW"]) {
        return @"Chinese Traditional";
    } else if ([key isEqualToString:@"zh-CN"]) {
        return @"Chinese Simplified";
    } else if ([key isEqualToString:@"hi"]) {
        return @"Hindi";
    }
    return @"Unknown";
}

@end
