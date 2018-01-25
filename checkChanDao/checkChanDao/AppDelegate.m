//
//  AppDelegate.m
//  checkChanDao
//
//  Created by LLZ on 2017/12/29.
//  Copyright © 2017年 LLZ. All rights reserved.
//

#import "AppDelegate.h"
#import "Controller.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[Controller shareController] start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
