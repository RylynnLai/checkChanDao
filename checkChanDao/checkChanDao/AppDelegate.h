//
//  AppDelegate.h
//  checkChanDao
//
//  Created by LLZ on 2017/12/29.
//  Copyright © 2017年 LLZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong, readonly) Controller *controller;

@end

