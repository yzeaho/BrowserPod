//
//  CFAppDelegate.m
//  BrowserPod
//
//  Created by yzeaho on 07/01/2020.
//  Copyright (c) 2020 yzeaho. All rights reserved.
//

#import "CFAppDelegate.h"
#import "CFViewController.h"
#import "BrowserController.h"
#import "AppCustomFormatter.h"
#import "MediaType.h"

@implementation CFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DDOSLogger *logger = [DDOSLogger sharedInstance];
    logger.logFormatter = [[AppCustomFormatter alloc] init];
    [DDLog addLogger:logger]; // Uses os_log
    
    CFViewController *bc = [CFViewController new];
    UINavigationController *root = [[UINavigationController alloc] initWithRootViewController:bc];
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];
    [NSThread sleepForTimeInterval:1.0];
    return YES;
}

@end
