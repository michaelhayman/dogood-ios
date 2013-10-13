#import "UIImage+Grayscale.h"

@implementation UIImage (Grayscale)
// [self.teaser.image convertToGrayscale];

- (UIImage *)convertImageToGrayscale:(UIImage *)image {
    CGFloat actualWidth = image.size.width;
    CGFloat actualHeight = image.size.height;

    CGRect imageRect = CGRectMake(0, 0, actualWidth, actualHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    CGContextRef context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);

    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, nil, (CGBitmapInfo)kCGImageAlphaOnly);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    return grayScaleImage;
}

@end
