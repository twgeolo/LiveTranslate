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
    
    self.tableView.rowHeight = 70;
    self.tableView.separatorColor = [UIColor clearColor];
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sideButton setImage:[UIImage imageNamed:@"SideMenu"] forState:UIControlStateNormal];
    sideButton.frame = CGRectMake(0, 0, 25, 25);
    [sideButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    
    if (![UserDefaults integerForKey:@"LoadedContacts"]) {
        [self getContacts];
        [UserDefaults setInteger:1 forKey:@"LoadedContacts"];
        [UserDefaults synchronize];
    } else {
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
    }
    self.navigationItem.title = [NSString stringWithFormat:@"Friends (%lu)", (unsigned long)friendsAry.count];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar"] forBarMetrics:UIBarMetricsDefault];
    UIImage *wallpaperImage = [[UIImage imageNamed:@"Wallpaper"] blurredImageWithRadius:5 iterations:2 tintColor:[UIColor blackColor]];
    [self.navigationController.view setBackgroundColor:[UIColor colorWithPatternImage:wallpaperImage]];
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [self.navigationController.view insertSubview:blackView atIndex:0];
    UIView *blackView2 = [[UIView alloc] initWithFrame:CGRectMake(0, -20, ScreenWidth, 64)];
    blackView2.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [self.navigationController.navigationBar insertSubview:blackView2 atIndex:1];
    
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTranslucent:YES];
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
                    self.navigationItem.title = [NSString stringWithFormat:@"Friends (%lu)", (unsigned long)friendsAry.count];
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
    cell.textLabel.font = [UIFont systemFontOfSize:21];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = friend.status;
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
    cell.backgroundColor = [UIColor clearColor];
    if (friend.imageData!=(NSData *)[NSNull null]) {
        cell.imageView.image = [ApplicationDelegate circularScaleAndCropImage:[UIImage imageWithData:friend.imageData] frame:CGRectMake(0, 0, 50, 50)];
        cell.imageView.layer.borderWidth = 1.5;
        cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imageView.layer.cornerRadius = 25;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
    self.useBlurForPopup = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Popup Functions

- (IBAction)btnPresentPopup:(id)sender {
    /*SamplePopupViewController *samplePopupViewController = [[SamplePopupViewController alloc] initWithNibName:@"SamplePopupViewController" bundle:nil];
    [self presentPopupViewController:samplePopupViewController animated:YES completion:^(void) {
        NSLog(@"popup view presented");
    }];*/
}

- (IBAction)dismissPopup:(id)sender {
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
}

#pragma mark - gesture recognizer delegate functions

// so that tapping popup view doesnt dismiss it
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

@end
