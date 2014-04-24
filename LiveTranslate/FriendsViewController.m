//
//  FriendsViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/21/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController {
    NSMutableArray *friendsAry;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    friendsAry = [NSMutableArray new];
    
    self.tableView.rowHeight = 54;
    self.tableView.separatorColor = [UIColor darkGrayColor];
    self.navigationController.navigationBar.translucent = NO;
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sideButton setImage:[UIImage imageNamed:@"SideMenu"] forState:UIControlStateNormal];
    sideButton.frame = CGRectMake(0, 0, 26, 26);
    [sideButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    
    /*if (![UserDefaults integerForKey:@"LoadedContacts"]) {
        [self getContacts];
#warning add these
        //[UserDefaults setInteger:1 forKey:@"LoadedContacts"];
        //[UserDefaults synchronize];
    } else {*/
        FMDatabase *db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"LiveTranslate.db"]];
        if ([db open]) {
            FMResultSet *s = [db executeQuery:@"SELECT * FROM Friends ORDER BY DisplayName"];
            while ([s next]) {
                Person *friend = [[Person alloc] init];
                friend.userName = [s objectForColumnIndex:0];
                friend.realName = [s objectForColumnIndex:1];
                friend.displayName = [s objectForColumnIndex:2];
                friend.status = [s objectForColumnIndex:3];
                friend.phone = [s objectForColumnIndex:4];
                friend.gender = [s objectForColumnIndex:5];
                friend.imageData = [s objectForColumnIndex:6];
                [friendsAry addObject:friend];
            }
        }
        [db close];
    //}
    self.navigationItem.title = [NSString stringWithFormat:@"Friends (%lu)", (unsigned long)friendsAry.count];
}

- (void)getContacts {
    MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
    overlayView.titleLabelText = @"Loading";
    
    dispatch_queue_t queue = dispatch_queue_create("LoadContact", 0);
    dispatch_async(queue, ^{
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    overlayView.mode = MRProgressOverlayViewModeCross;
                    overlayView.titleLabelText = @"No Friend on our server";
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [overlayView dismiss:YES];
                    });
                });
            } else {
                for (int i = 0; i < nPeople; i++) {
                    Person *currFriend = [[Person alloc] init];
                    ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                    
                    @try {
                        NSData *imageData = (__bridge NSData *)ABPersonCopyImageData(person);
                        if (imageData) {
                            currFriend.imageData = imageData;
                        }
                    } @catch (NSException *e) {
                        NSLog(@"%@",e);
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
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        if ([[dict objectForKey:@"numberOfMatches"] integerValue] == 1) {
                            dict = [[dict objectForKey:@"results"] objectAtIndex:0];
                            currFriend.userName = [dict objectForKey:@"name"];
                            currFriend.realName = [dict objectForKey:@"real_name"];
                            currFriend.displayName = [dict objectForKey:@"real_name"];
                            currFriend.gender = [dict objectForKey:@"gender"];
                            currFriend.status = [dict objectForKey:@"status"];
                            [friendsOnServer addObject:currFriend];
                        }
                    }
                }
                
                FMDatabase *db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"LiveTranslate.db"]];
                if ([db open]) {
                    [db executeUpdate:@"DELETE FROM Friends"];
                    for (Person *person in friendsOnServer) {
                        NSLog(@"Inserting %@\n", person.userName);
                        [db executeUpdate:@"INSERT INTO Friends (userName, realName, displayName, status, phone, gender, image) VALUES (?, ?, ?, ?, ?, ?, ?)", person.userName, person.realName, person.displayName, person.status, person.phone, person.gender, person.imageData];
                        [friendsAry addObject:person];
                    }
                }
                [db close];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationItem.title = [NSString stringWithFormat:@"Friends (%i)", friendsAry.count];
                    [self.tableView reloadData];
                    [overlayView dismiss:YES];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:nil message:@"Cannot fetch contacts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                [overlayView dismiss:YES];
            });
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return friendsAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Person *friend = [friendsAry objectAtIndex:indexPath.row];
    cell.textLabel.text = friend.displayName;
    cell.detailTextLabel.text = friend.status;
    cell.backgroundColor = [UIColor clearColor];
    if (friend.imageData!=(NSData *)[NSNull null]) {
        cell.imageView.image =[self circularScaleAndCropImage:[UIImage imageWithData:friend.imageData] frame:CGRectMake(0, 0, 40, 40)];
    }
    
    return cell;
}

- (UIImage *)circularScaleAndCropImage:(UIImage*)image frame:(CGRect)frame {
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Get the width and heights
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat rectWidth = frame.size.width;
    CGFloat rectHeight = frame.size.height;
    
    //Calculate the scale factor
    CGFloat scaleFactorX = rectWidth/imageWidth;
    CGFloat scaleFactorY = rectHeight/imageHeight;
    
    //Calculate the centre of the circle
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);
    
    //Set the SCALE factor for the graphics context
    //All future draw calls will be scaled by this factor
    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
    
    // Draw the IMAGE
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [image drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
