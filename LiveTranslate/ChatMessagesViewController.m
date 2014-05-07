//
//  ChatMessagesViewController.m
//  LiveTranslate
//
//  Created by George Lo on 5/2/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "ChatMessagesViewController.h"

@interface ChatMessagesViewController ()

@end

@implementation ChatMessagesViewController {
    UIImage *friendImage;
    UIImage *selfImage;
    NSTimer *timer;
    CLLocationManager *locationManager;
    float userLat, userLon;
}

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT displayName, image, gender FROM Friends WHERE userName=?", self.userName];
    if ([s next]) {
        self.title = [s objectForColumnIndex:0];
        if ([s objectForColumnIndex:1]!=(NSData *)[NSNull null]) {
            friendImage = [UIImage imageWithData:[s objectForColumnIndex:1]];
        } else {
            if ([[s objectForColumnIndex:2] isEqualToString:@"M"]) {
                friendImage = [UIImage imageNamed:@"Male"];
            } else {
                friendImage = [UIImage imageNamed:@"Female"];
            }
        }
    }
    friendImage = [self resizedImage:[ApplicationDelegate makeCircularImage:friendImage withFrame:CGRectMake(0, 0, 50, 50)]];
    if ([[UserDefaults objectForKey:@"gender"] isEqualToString:@"M"]) {
        selfImage = [self resizedImage:[ApplicationDelegate makeCircularImage:[UIImage imageNamed:@"Male"] withFrame:CGRectMake(0, 0, 50, 50)]];
    } else {
        selfImage = [self resizedImage:[ApplicationDelegate makeCircularImage:[UIImage imageNamed:@"Female"] withFrame:CGRectMake(0, 0, 50, 50)]];
    }
    self.messageInputView.textView.placeHolder = @"New Message";
    self.sender = [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"];;
    
    [self setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"Wallpaper2"] blurredImageWithRadius:5 iterations:2 tintColor:[UIColor blackColor]]]];
    
    self.messages = [NSMutableArray new];
    s = [ApplicationDelegate executeQuery:@"SELECT sender, message, timeStamp FROM Messages WHERE withUser=? ORDER BY timeStamp", self.userName];
    while ([s next]) {
        NSString *sender = [s objectForColumnIndex:0];
        if ([sender isEqualToString:self.sender]) {
            sender = [UserDefaults objectForKey:@"realName"];
        } else {
            sender = self.title;
        }
        JSMessage *message = [[JSMessage alloc] initWithText:[s objectForColumnIndex:1] sender:sender date:[NSDate dateWithTimeIntervalSince1970:[[s objectForColumnIndex:2] integerValue]]];
        [self.messages addObject:message];
    }
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@" Back" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [button addTarget:self.parentViewController action:@selector(dismissModalViewControllerAnimated:)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 70, 25)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar2"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ApplicationDelegate stopRetrieveMessage];
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(retrieveMessages:) userInfo:nil repeats:YES];
    [self.tableView setContentOffset:CGPointMake(0, 100000) animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [timer invalidate];
    [ApplicationDelegate startRetrieveMessage];
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
                    
                    if ([[msgDict objectForKey:@"from"] isEqualToString:self.userName]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ShowNetworkActivityIndicator();
                            [JSMessageSoundEffect playMessageReceivedSound];
                            [self.messages addObject:[[JSMessage alloc] initWithText:[msgDict objectForKey:@"message"] sender:self.title date:timeStamp]];
                            [self finishSend];
                            [self scrollToBottomAnimated:YES];
                            HideNetworkActivityIndicator();
                        });
                    } else {
                        [UserDefaults setBool:YES forKey:@"hasNewMessage"];
                        [UserDefaults synchronize];
                    }
                    
                    [ApplicationDelegate executeUpdate:@"INSERT INTO Messages (withUser, sender, message, timeStamp) VALUES (?, ?, ?, ?)", [msgDict objectForKey:@"from"], [msgDict objectForKey:@"from"], [msgDict objectForKey:@"message"], [NSNumber numberWithDouble:[timeStamp timeIntervalSince1970]]];
                }
            }
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    [JSMessageSoundEffect playMessageSentSound];
    srand48(time(0));
    double lat;
    double lon;
    if (DUMMY_LOC) {
        lat = 40.4422655 + 0.5 * (1 - 2 * drand48());
        lon = -86.9265415 + 0.5 * (1 - 2 * drand48());
    } else {
        lat = userLat;
        lon = userLon;
    }
    [ApplicationDelegate executeUpdate:@"INSERT INTO Messages (withUser, sender, message, timeStamp, lat, lon) VALUES (?, ?, ?, ?, ?, ?)", self.userName, self.sender, text, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], [NSNumber numberWithDouble:lat], [NSNumber numberWithDouble:lon]];
    [self.messages addObject:[[JSMessage alloc] initWithText:text sender:self.sender date:date]];
    [UserDefaults setBool:YES forKey:@"hasNewMessage"];
    [UserDefaults synchronize];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *urlStr = [[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/send?sourceLang=%@&toUser=%@&user=%@&pin=%@&message=%@", [UserDefaults objectForKey:@"Lang"], self.userName, [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"PIN"], text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"success"] isEqualToString:@"true"]) {
            } else {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Failed" andMessage:[dict objectForKey:@"message"]];
                [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
                [alertView show];
            }
        }
    });
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *message = [self.messages objectAtIndex:indexPath.row];
    if ([message.sender isEqualToString:self.title]) {
        return JSBubbleMessageTypeIncoming;
    }
    return JSBubbleMessageTypeOutgoing;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *message = [self.messages objectAtIndex:indexPath.row];
    if ([message.sender isEqualToString:self.title]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
    return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 3 == 0) {
        return YES;
    }
    return NO;
}

- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor whiteColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor whiteColor];
    }
    
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    if ([sender isEqualToString:self.title]) {
        return [[UIImageView alloc] initWithImage:friendImage];
    } else {
        return [[UIImageView alloc] initWithImage:selfImage];
    }
}

- (UIImage *)resizedImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0);
    [image drawInRect:CGRectMake(5, 5, 40, 40)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
