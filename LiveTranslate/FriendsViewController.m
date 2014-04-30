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
    UICollectionView *friendCollectionView;
    NSMutableArray *friendsAry;
    UITapGestureRecognizer *tapRecognizer;
    Person *selectedFriend;
    UILabel *dispNameLabel;
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
    
    if (![UserDefaults integerForKey:@"LoadedContacts"]) {
        MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
        overlayView.titleLabelText = @"Loading";
        
        dispatch_queue_t queue = dispatch_queue_create("LoadContact", 0);
        dispatch_async(queue, ^{
            [ApplicationDelegate getContacts];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.title = [NSString stringWithFormat:@"Friends (%lu)", (unsigned long)friendsAry.count];
                [friendCollectionView reloadData];
                [self.tableView reloadData];
                [overlayView dismiss:YES];
            });
        });
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
    [ApplicationDelegate customizeViewController:self tableView:YES];
    
    if ([UserDefaults integerForKey:@"FriendsGrid"]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(70, 103);
        layout.sectionInset = UIEdgeInsetsMake(30, 30, 30, 30);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        friendCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
        friendCollectionView.dataSource = self;
        friendCollectionView.delegate = self;
        
        [friendCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        friendCollectionView.backgroundColor = [UIColor clearColor];
        self.view = friendCollectionView;
    }
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    self.navigationController.useBlurForPopup = YES;
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
        cell.imageView.image = [ApplicationDelegate circularImage:[UIImage imageWithData:friend.imageData] withFrame:CGRectMake(0, 0, 50, 50)];
        cell.imageView.layer.borderWidth = 1.5;
        cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imageView.layer.cornerRadius = 25;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showInfoCardForFriendAtRow:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return friendsAry.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    Person *friend = [friendsAry objectAtIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[ApplicationDelegate circularImage:[UIImage imageWithData:friend.imageData] withFrame:CGRectMake(0, 0, 70, 70)]];
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 1.5;
    imageView.layer.cornerRadius = 35;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 70, 23)];
    nameLabel.text = [[friend.displayName componentsSeparatedByString:@" "] objectAtIndex:0];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:14];
    
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:nameLabel];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showInfoCardForFriendAtRow:indexPath.row];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)showInfoCardForFriendAtRow: (NSInteger)row {
    Person *friend = [friendsAry objectAtIndex:row];
    UIViewController *viewController = [[UIViewController alloc] init];
    UIView *friendInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 400)];
    friendInfoView.backgroundColor = [UIColor whiteColor];
    if (friend.imageData!=(NSData *)[NSNull null]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:friend.imageData]];
        imageView.frame = CGRectMake(20, 20, 200, 200);
        imageView.layer.cornerRadius = 5;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [friendInfoView addSubview:imageView];
    }
    dispNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 225, 200, 25)];
    dispNameLabel.text = friend.displayName;
    dispNameLabel.font = [UIFont boldSystemFontOfSize:22];
    [friendInfoView addSubview:dispNameLabel];
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 250, 200, 20)];
    statusLabel.text = friend.status;
    statusLabel.font = [UIFont systemFontOfSize:15];
    statusLabel.textColor = [UIColor grayColor];
    [friendInfoView addSubview:statusLabel];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(20, 277.25, 200, 0.5)];
    separator.backgroundColor = [UIColor lightGrayColor];
    [friendInfoView addSubview:separator];
    
    BButton *editBtn = [[BButton alloc] initWithFrame:CGRectMake(20, 285, 60, 40) type:BButtonTypeDefault style:BButtonStyleBootstrapV2];
    editBtn.tag = row;
    [editBtn addTarget:self action:@selector(editName:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    [friendInfoView addSubview:editBtn];
    BButton *callBtn = [[BButton alloc] initWithFrame:CGRectMake(90, 285, 60, 40) type:BButtonTypeDefault style:BButtonStyleBootstrapV2];
    callBtn.tag = row;
    [callBtn addTarget:self action:@selector(callFriend:) forControlEvents:UIControlEventTouchUpInside];
    [callBtn setTitle:@"Call" forState:UIControlStateNormal];
    [friendInfoView addSubview:callBtn];
    BButton *messageBtn = [[BButton alloc] initWithFrame:CGRectMake(160, 285, 60, 40) type:BButtonTypeDefault style:BButtonStyleBootstrapV2];
    messageBtn.tag = row;
    [messageBtn addTarget:self action:@selector(msgFriend:) forControlEvents:UIControlEventTouchUpInside];
    [messageBtn setTitle:@"Msg" forState:UIControlStateNormal];
    [friendInfoView addSubview:messageBtn];
    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(20, 332.25, 200, 0.5)];
    separator2.backgroundColor = [UIColor lightGrayColor];
    [friendInfoView addSubview:separator2];
    
    BButton *chatBtn = [[BButton alloc] initWithFrame:CGRectMake(20, 340, 200, 40) type:BButtonTypeSuccess style:BButtonStyleBootstrapV2];
    [chatBtn setTitle:@"Chat" forState:UIControlStateNormal];
    [friendInfoView addSubview:chatBtn];
    
    viewController.view = friendInfoView;
    [self.navigationController presentPopupViewController:viewController animated:YES completion:nil];
    
    [self.navigationController.view addGestureRecognizer:tapRecognizer];
}

- (IBAction)editName:(id)sender {
    selectedFriend = [friendsAry objectAtIndex:((BButton *)sender).tag];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Edit Friend's name" message:[NSString stringWithFormat:@"\"%@\"",selectedFriend.displayName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].placeholder = @"New name";
    [alertView show];
}

- (IBAction)callFriend:(id)sender {
    Person *friend = [friendsAry objectAtIndex:((BButton *)sender).tag];
    NSString *urlString = [NSString stringWithFormat:@"tel:%@", friend.phone];
    if ([SharedApplication canOpenURL:[NSURL URLWithString:urlString]]) {
        [SharedApplication openURL:[NSURL URLWithString:urlString]];
    } else {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Your phone does not support this functionality"];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
        [alertView show];
    }
}

- (IBAction)msgFriend:(id)sender {
    Person *friend = [friendsAry objectAtIndex:((BButton *)sender).tag];
    NSString *urlString = [NSString stringWithFormat:@"sms:%@", friend.phone];
    if ([SharedApplication canOpenURL:[NSURL URLWithString:urlString]]) {
        [SharedApplication openURL:[NSURL URLWithString:urlString]];
    } else {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Your phone does not support this functionality"];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        if ([alertView.title isEqualToString:@"Edit Friend's name"]) {
            NSString *newName = [alertView textFieldAtIndex:0].text;
            if (newName.length <= 0) {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"You did not enter anything"];
                [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
                [alertView show];
                return;
            }
        
            for (Person *friend in friendsAry) {
                if ([friend.displayName isEqualToString:newName]) {
                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Someone already uses the name"];
                    [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
                    [alertView show];
                    return;
                }
            }
            
            [ApplicationDelegate executeUpdate:@"UPDATE Friends SET displayName=? WHERE displayName=?", newName, selectedFriend.displayName];
            
            dispNameLabel.text = newName;
            selectedFriend.displayName = newName;
            [friendCollectionView reloadData];
            [self.tableView reloadData];
        }
    }
}

- (IBAction)dismissPopup:(id)sender {
    UITapGestureRecognizer *recognizer = (UITapGestureRecognizer *)sender;
    CGPoint location = [recognizer locationInView:self.navigationController.view];
    NSInteger width = (ScreenWidth - 240) / 2;
    NSInteger height = (ScreenHeight - 400) / 2;
    if (self.navigationController.popupViewController != nil &&
        (location.x < width ||
         location.x > ScreenWidth-width ||
         location.y < height ||
         location.y > ScreenHeight-height)
    ) {
        [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
        [self.navigationController.view removeGestureRecognizer:tapRecognizer];
    }
}

@end
