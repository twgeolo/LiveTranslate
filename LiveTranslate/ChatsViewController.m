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
	UITapGestureRecognizer *tapRecognizer;
	UILabel *hintLabel;
    NSTimer *timer;
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
    
    self.navigationItem.title = @"Chats";
    friendCellAry = [NSMutableArray new];
    
    self.tableView.rowHeight = 70;
    self.tableView.separatorColor = [UIColor clearColor];
	
	UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[addBtn setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
	[addBtn addTarget:self action:@selector(showSelectionView:) forControlEvents:UIControlEventTouchUpInside];
	addBtn.frame = CGRectMake(0, 0, 25, 25);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
	
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    self.navigationController.useBlurForPopup = YES;
	
	hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 60, ScreenWidth-120, 80)];
	hintLabel.numberOfLines = 3;
	hintLabel.font = [UIFont boldSystemFontOfSize:20];
	hintLabel.text = @"You have no chats.\nPress the + button to get started !";
	hintLabel.textAlignment = NSTextAlignmentCenter;
	hintLabel.textColor = [UIColor whiteColor];
    
    [ApplicationDelegate customizeViewController:self tableView:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:YES];
    [friendCellAry removeAllObjects];
    
    FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT Friends.image, Friends.userName, Friends.displayName, Messages.message FROM Messages INNER JOIN Friends WHERE Friends.userName == Messages.withUser GROUP BY Friends.userName ORDER BY Messages.timeStamp DESC"];
    while ([s next]) {
        NSArray *infoAry = [NSArray arrayWithObjects:
                            [s objectForColumnIndex:0],
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
}

- (IBAction)showSelectionView:(id)sender {
	ChatSelectFriendViewController *viewController = [[ChatSelectFriendViewController alloc] init];
	viewController.tableView.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
	UIColor *firstColor = [UIColor colorWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
    UIColor *secondColor = [UIColor colorWithRed:55.0f/255.0f green:55.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    NSArray *colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
	navController.navigationBar.translucent = NO;
	navController.viewControllers = @[viewController];
	navController.view.frame = CGRectMake(0, 0, 240, 400);
	[self.navigationController presentPopupViewController:navController animated:YES completion:nil];
    [self.view addGestureRecognizer:tapRecognizer];
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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[infoAry objectAtIndex:0]]];
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
	
    UIView *whiteLine = [[UIView alloc] initWithFrame:CGRectMake(5, 69.5, ScreenWidth-10, 0.5)];
    whiteLine.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [cell.contentView addSubview:whiteLine];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == self.tableView) {
        NSArray *infoArray = [friendCellAry objectAtIndex:indexPath.row];
        ChatMessagesViewController *viewController = [[ChatMessagesViewController alloc] init];
        viewController.userName = [infoArray objectAtIndex:1];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:navController animated:YES completion:nil];
	} else {
        [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
        ChatMessagesViewController *viewController = [[ChatMessagesViewController alloc] init];
        viewController.userName = @"";
        FMResultSet *s = [ApplicationDelegate executeQuery:@"SELECT userName FROM Friends WHERE displayName=?", [tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        if ([s next]) {
            viewController.userName = [s objectForColumnIndex:0];
        }
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:navController animated:YES completion:nil];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
