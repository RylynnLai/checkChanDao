//
//  main.m
//  checkChanDao
//
//  Created by LLZ on 2017/12/29.
//  Copyright © 2017年 LLZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    NSApplication *app = [NSApplication sharedApplication];
    id delegate = [[AppDelegate alloc]init];
    app.delegate = delegate;
    return NSApplicationMain(argc, argv);
}
