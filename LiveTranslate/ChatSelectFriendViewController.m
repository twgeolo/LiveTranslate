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
	
	self.tableView.rowHeight = 44;
	self.tableView.separatorColor = [UIColor clearColor];
	
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
	
    UIImage *wallpaper = [UIImage imageNamed:@"SignInWallpaper"];
    wallpaper = [wallpaper blurredImageWithRadius:5 iterations:2 tintColor:[UIColor blackColor]];
    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:wallpaper];
    backgroundIV.frame = CGRectMake(0, 0, 240, 400);
    backgroundIV.contentMode = UIViewContentModeScaleToFill;
	UIView *blackView = [[UIView alloc] initWithFrame:backgroundIV.frame];
    blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.83];
    [backgroundIV addSubview:blackView];
	self.tableView.backgroundView = backgroundIV;
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"Select a friend";
    titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
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
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (friend.imageData!=(NSData *)[NSNull null]) {
        cell.imageView.image = [ApplicationDelegate circularImage:[UIImage imageWithData:friend.imageData] withFrame:CGRectMake(0, 0, 38, 38)];
        cell.imageView.layer.borderWidth = 1.5;
        cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imageView.layer.cornerRadius = 19;
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
