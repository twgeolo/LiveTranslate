//
//  SignInViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/20/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

// Changing Status Bar to LightContent style
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up Background ImageView
    UIImage *wallpaper = [UIImage imageNamed:@"SignInWallpaper"];
    wallpaper = [wallpaper blurredImageWithRadius:5 iterations:2 tintColor:[UIColor blackColor]];
    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:wallpaper];
    backgroundIV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    backgroundIV.contentMode = UIViewContentModeScaleToFill;
    
    // Add a black overlay to the background imageview
    UIView *blackView = [[UIView alloc] initWithFrame:backgroundIV.frame];
    blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [backgroundIV addSubview:blackView];
    
    // Add Icon and App Name on top of the black overlay
    UIImageView *iconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon"]];
    NSInteger iconSideLength = ScreenWidth * 10 / 20;
    NSInteger startX = (ScreenWidth-iconSideLength)/2;
    iconIV.frame = CGRectMake(startX, 50, iconSideLength, iconSideLength);
    iconIV.layer.borderColor = [UIColor whiteColor].CGColor;
    iconIV.layer.borderWidth = 2;
    iconIV.layer.masksToBounds = YES;
    iconIV.layer.cornerRadius = 50;
    [blackView addSubview:iconIV];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50+iconSideLength+20, ScreenWidth, 22)];
    nameLabel.text = @"Live Translate";
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:28];
    [blackView addSubview:nameLabel];
    
    // Setup Username Field
    NSInteger TFWidth = ScreenWidth-60;
    NSInteger TFHeight = 44;
    UITextField *userTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, nameLabel.frame.origin.y+22+40, TFWidth, TFHeight)];
    userTF.delegate = self;
    userTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    userTF.returnKeyType = UIReturnKeyDone;
    userTF.userInteractionEnabled = YES;
    userTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    userTF.textColor = [UIColor whiteColor];
    userTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0]}];
    UIView *userIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+20, TFHeight)];
    UIImageView *userIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Username"]];
    userIconIV.frame = CGRectMake(10, 9, 26, 26);
    userIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [userIconBox addSubview:userIconIV];
    UIView *userSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(46, 8, 1, 28)];
    userSeparatorLine.backgroundColor = [UIColor whiteColor];
    [userIconBox addSubview:userSeparatorLine];
    userTF.leftView = userIconBox;
    userTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Password Field
    UITextField *passTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, userTF.frame.origin.y+40+20, TFWidth, TFHeight)];
    passTF.secureTextEntry = YES;
    passTF.delegate = self;
    passTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    passTF.returnKeyType = UIReturnKeyDone;
    passTF.userInteractionEnabled = YES;
    passTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    passTF.textColor = [UIColor whiteColor];
    passTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0]}];
    UIView *passIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+20, TFHeight)];
    UIImageView *passIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Password"]];
    passIconIV.frame = CGRectMake(10, 9, 26, 26);
    passIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [passIconBox addSubview:passIconIV];
    UIView *passSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(46, 8, 1, 28)];
    passSeparatorLine.backgroundColor = [UIColor whiteColor];
    [passIconBox addSubview:passSeparatorLine];
    passTF.leftView = passIconBox;
    passTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Sign In Button
    UIButton *signInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signInBtn.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    signInBtn.frame = CGRectMake((ScreenWidth-TFWidth)/2, passTF.frame.origin.y+40+20, TFWidth, TFHeight);
    [signInBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    signInBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [signInBtn setTitle:@"SIGN IN" forState:UIControlStateNormal];
    
    // Setup Sign Up part
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, signInBtn.frame.origin.y+40+20, TFWidth, TFHeight)];
    hintLabel.font = [UIFont systemFontOfSize:14];
    hintLabel.text = @"Don't have an account?";
    hintLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *registerLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, hintLabel.frame.origin.y+20, TFWidth, TFHeight)];
    registerLabel.font = [UIFont systemFontOfSize:15];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Register now"];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    registerLabel.attributedText = attributeString;
    registerLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    registerLabel.textAlignment = NSTextAlignmentCenter;
    
    // Add Background ImageView
    [self.view addSubview:backgroundIV];
    [self.view addSubview:userTF];
    [self.view addSubview:passTF];
    [self.view addSubview:signInBtn];
    [self.view addSubview:hintLabel];
    [self.view addSubview:registerLabel];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
