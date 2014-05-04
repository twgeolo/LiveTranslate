//
//  AppDelegate.m
//  LiveTranslate
//
//  Created by George Lo on 4/20/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate {
    NSTimer *timer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:20]
    }];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self executeUpdate:@"CREATE TABLE IF NOT EXISTS Friends (userName TEXT, realName TEXT, displayName TEXT, status TEXT, phone TEXT, gender INT, image BLOB)"];
    [self executeUpdate:@"CREATE TABLE IF NOT EXISTS Messages (withUser TEXT, sender TEXT, message TEXT, timeStamp INT)"];
    
    if ([UserDefaults objectForKey:@"Lang"] == nil) {
        [UserDefaults setObject:@"en" forKey:@"Lang"];
        [UserDefaults synchronize];
    }
    
    
    if (DUMMY_DATA) {
        NSLog(@"Creating Dummy Data ---------------");
        NSArray *sampleArray = [NSArray arrayWithObjects:
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=ksawant&pin=123456&phone=805-410-2334&realname=Kartik%20Sawant&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=wtsai&pin=123456&phone=206-973-9963&realname=Wesley%20Tsai&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=mlee&pin=123456&phone=513-720-7749&realname=Ming%20Lee&gender=F",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=ksu&pin=123456&phone=604-655-7567&realname=Kevin%20Su&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=ahsu&pin=123456&phone=770-558-0602&realname=Angel%20Hsu&gender=F",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=kmedhi&pin=123456&phone=505-652-2451&realname=Krishnabh%20Medhi&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=dcheng&pin=123456&phone=949-500-4593&realname=Daniel%20Cheng&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=tchu&pin=123456&phone=858-692-0632&realname=Terry%20Chu&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=bcheng&pin=123456&phone=949-378-6669&realname=Brian%20Cheng&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=tkembura&pin=123456&phone=312-780-9832&realname=Tatum%20Kembura&gender=F",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=aliu&pin=123456&phone=917-257-0694&realname=Andy%20Liu&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=psullivan&pin=123456&phone=980-248-9239&realname=Patrick%20Sullivan&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=ktakemae&pin=123456&phone=857-919-5841&realname=Keisuke%20Takemae&gender=M",
                                @"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=jtsai&pin=123456&phone=091-550-3655&realname=James%20Tsai&gender=M",
                                nil];
        for (NSString *sample in sampleArray) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:sample]];
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSLog(@"%@ - %@\n",[dict objectForKey:@"success"],[dict objectForKey:@"message"]);
            }
        }
        NSLog(@"Finished");
    }
    
    return YES;
}

- (void)startRetrieveMessage {
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(retrieveMessages:) userInfo:nil repeats:YES];
}

- (void)stopRetrieveMessage {
    [timer invalidate];
}

- (IBAction)retrieveMessages:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/receive?user=%@&pin=%@&userLang=%@", [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"PIN"], [UserDefaults objectForKey:@"Lang"]];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *arr = [dict objectForKey:@"results"];
            if (arr.count > 0) {
                for (NSDictionary *msgDict in arr) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                    [dateFormatter setLocale:enUSPOSIXLocale];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
                    NSDate *timeStamp = [dateFormatter dateFromString:[msgDict objectForKey:@"timestamp"]];
                    timeStamp = [NSDate dateWithTimeInterval:-14400 sinceDate:timeStamp];
                    
                    [self executeUpdate:@"INSERT INTO Messages (withUser, sender, message, timeStamp) VALUES (?, ?, ?, ?)", [msgDict objectForKey:@"from"], [msgDict objectForKey:@"from"], [msgDict objectForKey:@"message"], [NSNumber numberWithDouble:[timeStamp timeIntervalSince1970]]];
                }
            }
        }
    });
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

- (FMResultSet *)executeQuery:(NSString*)sql, ... {
    FMDatabase *db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"LiveTranslate.db"]];
    FMResultSet *s;
    if ([db open]) {
        va_list args;
        va_start(args, sql);
        id result = [db executeQuery:sql withArgumentsInArray:nil orDictionary:nil orVAList:args];
        va_end(args);
        return result;
    }
    [db close];
    return s;
}

- (BOOL)executeUpdate:(NSString*)sql, ... {
    FMDatabase *db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"LiveTranslate.db"]];
    BOOL flag;
    if ([db open]) {
        va_list args;
        va_start(args, sql);
        
        BOOL result = [db executeUpdate:sql error:nil withArgumentsInArray:nil orDictionary:nil orVAList:args];
        
        va_end(args);
        return result;
    }
    [db close];
    return flag;
}

- (void)sendRequestWithURL: (NSString *)urlStr
              successBlock:(void (^)(void))completion {
    MRProgressOverlayView *overlay = [MRProgressOverlayView showOverlayAddedTo:self.window animated:YES];
    overlay.titleLabelText = @"Loading";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"success"] isEqualToString:@"true"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    overlay.titleLabelText = @"Success";
                    overlay.mode = MRProgressOverlayViewModeCheckmark;
                    [completion invoke];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [overlay dismiss:YES];
                    });
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    overlay.titleLabelText = @"Failed";
                    overlay.mode = MRProgressOverlayViewModeCross;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [overlay dismiss:YES];
                    });
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                overlay.titleLabelText = @"Network Error";
                overlay.mode = MRProgressOverlayViewModeCross;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [overlay dismiss:YES];
                });
            });
        }
    });
}

- (UIButton *)makeFlatButtonWithFrame: (CGRect)rect
                                 text: (NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    button.frame = rect;
    [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (UITextField *)makeRegisterTFWithFrame: (CGRect)rect
                                     tag: (NSInteger)tag
                                delegate: (id)delegate
                             placeholder: (NSString *)placeholder
                                   image: (NSString *)imageName
                                keyboard: (UIKeyboardType)keyboardType {
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    textField.tag = tag;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = delegate;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = keyboardType;
    textField.returnKeyType = UIReturnKeyDone;
    textField.userInteractionEnabled = YES;
    textField.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    textField.textColor = [UIColor whiteColor];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1.0]}];
    UIView *iconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.height+15, rect.size.height)];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.height, rect.size.height)];
    bgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    [iconBox addSubview:bgView];
    UIImageView *iconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    iconIV.frame = CGRectMake(10, 9, 26, 26);
    iconIV.contentMode = UIViewContentModeScaleAspectFit;
    [iconBox addSubview:iconIV];
    textField.leftView = iconBox;
    textField.leftViewMode = UITextFieldViewModeAlways;
    return textField;
}

- (UITextField *)makeSignInTFWithFrame: (CGRect)rect
                                   tag: (NSInteger)tag
                              delegate: (id)delegate
                           placeholder: (NSString *)placeholder
                                 image: (NSString *)imageName {
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    textField.tag = tag;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = delegate;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.userInteractionEnabled = YES;
    textField.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    textField.textColor = [UIColor whiteColor];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0]}];
    UIView *iconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.height+20, rect.size.height)];
    UIImageView *iconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    iconIV.frame = CGRectMake(10, 9, 26, 26);
    iconIV.contentMode = UIViewContentModeScaleAspectFit;
    [iconBox addSubview:iconIV];
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(46, 8, 1, 28)];
    separatorLine.backgroundColor = [UIColor whiteColor];
    [iconBox addSubview:separatorLine];
    textField.leftView = iconBox;
    textField.leftViewMode = UITextFieldViewModeAlways;
    return textField;
}

- (void)customizeViewController: (UIViewController *)sender tableView: (BOOL)tvBool {
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sideButton setImage:[UIImage imageNamed:@"SideMenu"] forState:UIControlStateNormal];
    sideButton.frame = CGRectMake(0, 0, 25, 25);
    [sideButton addTarget:sender action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    sender.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    
    if (tvBool) {
        ((UITableViewController *)sender).tableView.backgroundColor = [UIColor clearColor];
    }
    [sender.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar"] forBarMetrics:UIBarMetricsDefault];
    UIImage *wallpaperImage = [[UIImage imageNamed:@"Wallpaper"] blurredImageWithRadius:5 iterations:2 tintColor:[UIColor blackColor]];
    [sender.navigationController.view setBackgroundColor:[UIColor colorWithPatternImage:wallpaperImage]];
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [sender.navigationController.view insertSubview:blackView atIndex:0];
    UIView *blackView2 = [[UIView alloc] initWithFrame:CGRectMake(0, -20, ScreenWidth, 64)];
    blackView2.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [sender.navigationController.navigationBar insertSubview:blackView2 atIndex:1];
    
    sender.navigationController.navigationBar.shadowImage = [UIImage new];
    [sender.navigationController.navigationBar setTranslucent:YES];
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
                    if (!person) {
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
                        CFRelease(phoneNumberRef);
                    }
                    currFriend.phone = [NSArray arrayWithArray:phoneNumbers];
                    [friends addObject:currFriend];
                    CFRelease(multiPhones);
                    CFRelease(person);
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
                
                [self executeUpdate:@"DELETE FROM Friends"];
                for (Person *person in friendsOnServer) {
                    [self executeUpdate:@"INSERT INTO Friends (userName, realName, displayName, status, phone, gender, image) VALUES (?, ?, ?, ?, ?, ?, ?)", person.userName, person.realName, person.displayName, person.status, [person.phone objectAtIndex:0], person.gender, person.imageData];
                }
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
