//
//  FriendsCollectionViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/28/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "FriendsCollectionViewController.h"

@interface FriendsCollectionViewController ()

@end

@implementation FriendsCollectionViewController {
    UICollectionView *friendCollectionView;
    NSMutableArray *friendsAry;
    UITapGestureRecognizer *tapRecognizer;
    Person *selectedFriend;
    UILabel *dispNameLabel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    friendsAry = [NSMutableArray new];
    
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sideButton setImage:[UIImage imageNamed:@"SideMenu"] forState:UIControlStateNormal];
    sideButton.frame = CGRectMake(0, 0, 25, 25);
    [sideButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    
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
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(70, 103);
    layout.sectionInset = UIEdgeInsetsMake(30, 30, 30, 30);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    friendCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    friendCollectionView.dataSource = self;
    friendCollectionView.delegate = self;
    
    [friendCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    friendCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:friendCollectionView];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    self.navigationController.useBlurForPopup = YES;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    Person *friend = [friendsAry objectAtIndex:indexPath.row];
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
    editBtn.tag = indexPath.row;
    [editBtn addTarget:self action:@selector(editName:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    [friendInfoView addSubview:editBtn];
    BButton *callBtn = [[BButton alloc] initWithFrame:CGRectMake(90, 285, 60, 40) type:BButtonTypeDefault style:BButtonStyleBootstrapV2];
    callBtn.tag = indexPath.row;
    [callBtn addTarget:self action:@selector(callFriend:) forControlEvents:UIControlEventTouchUpInside];
    [callBtn setTitle:@"Call" forState:UIControlStateNormal];
    [friendInfoView addSubview:callBtn];
    BButton *messageBtn = [[BButton alloc] initWithFrame:CGRectMake(160, 285, 60, 40) type:BButtonTypeDefault style:BButtonStyleBootstrapV2];
    messageBtn.tag = indexPath.row;
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
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
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
            
            FMDatabase *db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"LiveTranslate.db"]];
            if ([db open]) {
                [db executeUpdate:@"UPDATE Friends SET displayName=? WHERE displayName=?", newName, selectedFriend.displayName];
            }
            [db close];
            
            dispNameLabel.text = newName;
            selectedFriend.displayName = newName;
            [friendCollectionView reloadData];
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
         location.y > ScreenHeight-height
         )) {
            [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
            [self.navigationController.view removeGestureRecognizer:tapRecognizer];
        }
}

@end
