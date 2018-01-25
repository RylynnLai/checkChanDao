//
//  NSImage+ColorMask.m
//  checkChanDao
//
//  Created by LLZ on 2018/1/25.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import "NSImage+ColorMask.h"
typedef enum{
    
    ALPHA =0,
    
    BLUE =1,
    
    GREEN =2,
    
    RED =3
    
} PIXELS;
@implementation NSImage (ColorMask)
- (NSImage *)ucsRenderingImageWithColor:(NSColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    int red = components[0] * 255;
    int green = components[1] * 255;
    int blue = components[2] * 255;
    
    int width = self.size.width;
    
    int height = self.size.height;
    
    // the pixels will be painted to this array
    
    uint32_t*pixels = (uint32_t*)malloc(width * height *sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    
    memset(pixels,0, width * height *sizeof(uint32_t));
    
    //颜色空间DeviceRGB
    
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,8, width *sizeof(uint32_t), colorSpace,kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGImageRef cgImg = [self nsImageToCGImageRef:self];
    CGContextDrawImage(context,CGRectMake(0,0, width, height), cgImg);
    
    for(int y =0; y < height; y++) {
        
        for(int x =0; x < width; x++) {
            
            uint8_t *rgbaPixel = (uint8_t*) &pixels[y * width + x];
            
            // convert to grayscale using recommended method:http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            //灰度图装换公式
            //uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            // 0~255
            //            rgbaPixel[RED] = gray;
            //
            //            rgbaPixel[GREEN] = gray;
            //
            //            rgbaPixel[BLUE] = gray;
            
            rgbaPixel[RED] = red;
            
            rgbaPixel[GREEN] = green;
            
            rgbaPixel[BLUE] = blue;
            
        }
        
    }
    
    // create a new CGImageRef from our context with the modified pixels
    
    CGImageRef image =CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    free(pixels);
    
    // make a new UIImage to return
    NSImage *resultUIImage = [self imageFromCGImageRef:image];
    
    // we're done with image now too
    
    CGImageRelease(image);
    
    return resultUIImage;
}
// NSImage => CGImageRef
- (CGImageRef)nsImageToCGImageRef:(NSImage*)image;
{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef = NULL;
    if (imageData) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    }
    return imageRef;
}
// CGImageRef => NSImage
- (NSImage*)imageFromCGImageRef:(CGImageRef)image
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil;
    
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];
    return newImage;
}
@end
