//
//  ChatSelectFriendViewController.m
//  LiveTranslate
//
//  Created by George Lo on 5/1/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "ChatSelectFriendViewController.h"

@interface ChatSelectFriendViewController ()

@end

@implementation ChatSelectFriendViewController {
	NSMutableArray *friendsAry;
    NSMutableArray *selectedFriend;
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
    selectedFriend = [NSMutableArray new];
    self.tableView.rowHeight = 50;
	
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
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"Friends";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.prompt = @"Select one or more friends";
    
    [ApplicationDelegate customizeViewController:self tableView:YES];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(dismissModalViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Person *friend = [friendsAry objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = friend.displayName;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    if (friend.imageData!=(NSData *)[NSNull null] && friend.imageData!=nil) {
        cell.imageView.image = [ApplicationDelegate makeCircularImage:[UIImage imageWithData:friend.imageData] withFrame:CGRectMake(0, 0, 40, 40)];
    } else {
        if ([friend.gender isEqualToString:@"M"]) {
            cell.imageView.image = [ApplicationDelegate makeCircularImage:[UIImage imageNamed:@"Male"] withFrame:CGRectMake(0, 0, 40, 40)];
        } else {
            cell.imageView.image = [ApplicationDelegate makeCircularImage:[UIImage imageNamed:@"Female"] withFrame:CGRectMake(0, 0, 40, 40)];
        }
    }
    cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.imageView.layer.borderWidth = 1.5;
    cell.imageView.layer.cornerRadius = 20;
    cell.imageView.layer.masksToBounds = YES;
    cell.accessoryType = [selectedFriend containsObject:friend.displayName] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    if ([selectedFriend containsObject:text]) {
        [selectedFriend removeObject:text];
    } else {
        [selectedFriend addObject:text];
    }
    
    if (selectedFriend.count > 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(sendMessageToFriend:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)sendMessageToFriend:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [((ChatsViewController *)self.oriSender) sendMessageToPeople:selectedFriend];
    }];
}

@end
