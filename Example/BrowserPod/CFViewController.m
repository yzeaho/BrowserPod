//
//  CFViewController.m
//  BrowserPod
//
//  Created by yzeaho on 07/01/2020.
//  Copyright (c) 2020 yzeaho. All rights reserved.
//

#import "CFViewController.h"
#import "BrowserController.h"
#import "FileLookController.h"

@interface CFViewController ()

@end

@implementation CFViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];]
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
        NSForegroundColorAttributeName:[UIColor whiteColor]
    }];
    DDLogInfo(@"%@", NSStringFromCGRect(self.navigationController.navigationBar.frame));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    BrowserController *c = [BrowserController new];
    //c.htmlUrl = [NSURL URLWithString:@"http://www.qq.com"];
    //c.htmlUrl = [NSURL URLWithString:@"http://www-ins.szse.cn:8370/zczwz/announcement/notification/P020200701582610283201.TXT"];
    c.htmlUrl = [NSURL URLWithString:@"http://listing.szse.cn"];
    //[self.navigationController pushViewController:c animated:YES];
    
    //NSURL *url = [NSURL URLWithString:@"http://god-father.club/1.txt"];
    NSURL *url = [NSURL URLWithString:@"http://www-ins.szse.cn:8370/zczwz/announcement/notification/P020200701558151950434.exe"];
    FileLookController *fc = [[FileLookController alloc] init:url];
    [self.navigationController pushViewController:fc animated:YES];
}

@end
