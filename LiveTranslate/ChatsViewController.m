//
//  ChatsViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/21/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "ChatsViewController.h"

@interface ChatsViewController ()

@end

@implementation ChatsViewController {
    NSMutableArray *friendCellAry;
	UILabel *hintLabel;
    NSTimer *timer;
    NSMutableArray *peopleArray;
    BOOL loaded;
    NSMutableArray *deleteUsrAry;
    CLLocationManager *locationManager;
    float userLat, userLon;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    deleteUsrAry = [NSMutableArray new];
    
    self.navigationItem.title = @"Chats";
    friendCellAry = [NSMutableArray new];
    
    self.tableView.rowHeight = 70;
    self.tableView.separatorColor = [UIColor clearColor];
	
	UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[addBtn setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
	[addBtn addTarget:self action:@selector(showSelectionView:) forControlEvents:UIControlEventTouchUpInside];
	addBtn.frame = CGRectMake(0, 0, 25, 25);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
	
	hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 60, ScreenWidth-120, 80)];
	hintLabel.numberOfLines = 3;
	hintLabel.font = [UIFont boldSystemFontOfSize:20];
	hintLabel.text = @"You have no chats.\nPress the + button to get started !";
	hintLabel.textAlignment = NSTextAlignmentCenter;
	hintLabel.textColor = [UIColor whiteColor];
    
    [ApplicationDelegate customizeViewController:self tableView:YES];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    userLat = newLocation.coordinate.latitude;
    userLon = newLocation.coordinate.longitude;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [timer invalidate];
    
    
    for (NSString *username in deleteUsrAry) {
        [ApplicationDelegate executeUpdate:@"DELETE FROM Messages WHERE withUser == ?", username];
    }
    
    [deleteUsrAry removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!loaded || [UserDefaults boolForKey:@"hasNewMessage"]) {
        MRActivityIndicatorView *indicatorView = [[MRActivityIndicatorView alloc] initWithFrame:CGRectMake((ScreenWidth-50)/2, 30, 50, 50)];
        indicatorView.tintColor = [UIColor colorWithRed:0 green:172./255 blue:1 alpha:1];
        [self.tableView addSubview:indicatorView];
        [indicatorView startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [friendCellAry removeAllObjects];
            
            FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT Friends.image, Friends.userName, Friends.displayName, Messages.message, Friends.gender FROM Messages INNER JOIN Friends WHERE Friends.userName == Messages.withUser GROUP BY Friends.userName ORDER BY Messages.timeStamp DESC"];
            while ([s next]) {
                UIImage *img;
                if ([s objectForColumnIndex:0]!=(NSData *)[NSNull null]) {
                    img = [UIImage imageWithData:[s objectForColumnIndex:0]];
                    
                } else {
                    if ([[s objectForColumnIndex:4] isEqualToString:@"M"]) {
                        img = [UIImage imageNamed:@"Male"];
                    } else {
                        img = [UIImage imageNamed:@"Female"];
                    }
                }
                NSArray *infoAry = [NSArray arrayWithObjects:
                                    img,
                                    [s objectForColumnIndex:1],
                                    [s objectForColumnIndex:2],
                                    [s objectForColumnIndex:3],
                                    nil];
                [friendCellAry addObject:infoAry];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [indicatorView stopAnimating];
                [indicatorView removeFromSuperview];
                
                if (friendCellAry.count == 0) {
                    [self.tableView addSubview:hintLabel];
                } else {
                    [hintLabel removeFromSuperview];
                }
                
                [self.tableView reloadData];
            });
            timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:YES];
            
            loaded = YES;
            [UserDefaults setBool:NO forKey:@"hasNewMessage"];
            [UserDefaults synchronize];
        });
    }
}

- (IBAction)showSelectionView:(id)sender {
	ChatSelectFriendViewController *viewController = [[ChatSelectFriendViewController alloc] init];
    viewController.oriSender = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self.navigationController presentViewController:navController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    return friendCellAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    NSArray *infoAry = [friendCellAry objectAtIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[infoAry objectAtIndex:0]];
    imageView.frame = CGRectMake(15, 10, 50, 50);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 1.5;
    imageView.layer.cornerRadius = 25;
    imageView.layer.masksToBounds = YES;
    [cell.contentView addSubview:imageView];
    
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(75, 5, ScreenWidth-70-15, 30)];
    nameLbl.font = [UIFont boldSystemFontOfSize:24];
    nameLbl.text = [infoAry objectAtIndex:2];
    nameLbl.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:nameLbl];
    
    UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake(70, 25, ScreenWidth-70-50, 45)];
    messageView.backgroundColor = [UIColor clearColor];
    messageView.font = [UIFont systemFontOfSize:12];
    messageView.text = [infoAry objectAtIndex:3];
    messageView.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    messageView.userInteractionEnabled = NO;
    [cell.contentView addSubview:messageView];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(5, 69.5, ScreenWidth-10, 0.5);
    layer.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    [cell.contentView.layer addSublayer:layer];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *infoArray = [friendCellAry objectAtIndex:indexPath.row];
    ChatMessagesViewController *viewController = [[ChatMessagesViewController alloc] init];
    viewController.userName = [infoArray objectAtIndex:1];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *displayName = [[friendCellAry objectAtIndex:indexPath.row] objectAtIndex:2];
            NSString *username = @"";
            FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT userName FROM Friends WHERE displayName=?", displayName];
            if ([s next]) {
                username = [s objectForColumnIndex:0];
            }
            [deleteUsrAry addObject:username];
            [friendCellAry removeObjectAtIndex:indexPath.row];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        });
    }
}

- (void)sendMessageToPeople:(NSArray *)pplAry {
    if (pplAry.count == 1) {
        ChatMessagesViewController *viewController = [[ChatMessagesViewController alloc] init];
        viewController.userName = @"";
        FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT userName FROM Friends WHERE displayName=?", [pplAry objectAtIndex:0]];
        if ([s next]) {
            viewController.userName = [s objectForColumnIndex:0];
        }
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:navController animated:YES completion:nil];
    } else if (pplAry.count > 1) {
        peopleArray = [NSMutableArray new];
        for (NSString *user in pplAry) {
            FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT userName FROM Friends WHERE displayName=?", user];
            if ([s next]) {
                [peopleArray addObject:[s objectForColumnIndex:0]];
            }
        }
        YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"" maxCount:140 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];
        popupTextView.delegate = self;
        popupTextView.caretShiftGestureEnabled = YES;
        popupTextView.placeholderColor = [UIColor lightTextColor];
        [popupTextView showInViewController:self];
    }
}

- (void)popupTextView:(YIPopupTextView *)textView willDismissWithText:(NSString *)text cancelled:(BOOL)cancelled {
    if (!cancelled) {
        NSString *toUserStr = [NSString stringWithFormat:@"toUser=%@", [peopleArray objectAtIndex:0]];
        for (int i=1; i<peopleArray.count; i++) {
            toUserStr = [toUserStr stringByAppendingFormat:@"&toUser=%@", [peopleArray objectAtIndex:i]];
        }
        NSString *urlStr = [[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/send?sourceLang=%@&%@&user=%@&pin=%@&message=%@", [UserDefaults objectForKey:@"Lang"], toUserStr, [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"PIN"], text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ApplicationDelegate sendRequestWithURL:urlStr successBlock:^{
            srand48(time(0));
            for (NSString *user in peopleArray) {
                double lat;
                double lon;
                if (DUMMY_LOC) {
                    lat = 40.4422655 + 0.5 * (1 - 2 * drand48());
                    lon = -86.9265415 + 0.5 * (1 - 2 * drand48());
                } else {
                    lat = userLat;
                    lon = userLon;
                }
                [ApplicationDelegate executeUpdate:@"INSERT INTO Messages (withUser, sender, message, timeStamp, lat, lon) VALUES (?, ?, ?, ?, ?, ?)", user, [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], text, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], [NSNumber numberWithDouble:lat], [NSNumber numberWithDouble:lon]];
            }
            [friendCellAry removeAllObjects];
            
            FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT Friends.image, Friends.userName, Friends.displayName, Messages.message, Friends.gender FROM Messages INNER JOIN Friends WHERE Friends.userName == Messages.withUser GROUP BY Friends.userName ORDER BY Messages.timeStamp DESC"];
            while ([s next]) {
                UIImage *img;
                if ([s objectForColumnIndex:0]!=(NSData *)[NSNull null]) {
                    img = [UIImage imageWithData:[s objectForColumnIndex:0]];
                    
                } else {
                    if ([[s objectForColumnIndex:4] isEqualToString:@"M"]) {
                        img = [UIImage imageNamed:@"Male"];
                    } else {
                        img = [UIImage imageNamed:@"Female"];
                    }
                }
                NSArray *infoAry = [NSArray arrayWithObjects:
                                    img,
                                    [s objectForColumnIndex:1],
                                    [s objectForColumnIndex:2],
                                    [s objectForColumnIndex:3],
                                    nil];
                [friendCellAry addObject:infoAry];
            }
            
            if (friendCellAry.count == 0) {
                [self.tableView addSubview:hintLabel];
            } else {
                [hintLabel removeFromSuperview];
            }
            
            [self.tableView reloadData];
        }];
    }
}

@end
