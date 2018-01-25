//
//  NSImage+ColorMask.h
//  checkChanDao
//
//  Created by LLZ on 2018/1/25.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (ColorMask)
/**
 渲染成指定颜色的图片
 
 @param color 颜色
 @return 图片
 */
- (NSImage *)ucsRenderingImageWithColor:(NSColor *)color;
@end
