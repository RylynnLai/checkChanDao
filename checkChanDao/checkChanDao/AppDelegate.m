//
//  AppDelegate.m
//  checkChanDao
//
//  Created by LLZ on 2017/12/29.
//  Copyright © 2017年 LLZ. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong, readwrite) Controller *controller;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.controller = [Controller startController];
    [self.controller checkChanDao];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
