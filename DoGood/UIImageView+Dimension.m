#import "UIImageView+Dimension.h"

@implementation UIImageView (Dimension)

- (CGSize)imageSizeAfterAspectFit {
    float newwidth;
    float newheight;

    UIImage *image = self.image;

    if (image.size.height >= image.size.width){
        newheight = self.frame.size.height;
        newwidth = (image.size.width / image.size.height) * newheight;

        if (newwidth>self.frame.size.width) {
            float diff = self.frame.size.width - newwidth;
            newheight = newheight+diff/newheight * newheight;
            newwidth = self.frame.size.width;
        }

    }
    else{
        newwidth = self.frame.size.width;
        newheight = (image.size.height / image.size.width) * newwidth;

        if (newheight > self.frame.size.height){
            float diff = self.frame.size.height-newheight;
            newwidth = newwidth+diff/newwidth*newwidth;
            newheight = self.frame.size.height;
        }
    }

    DebugLog(@"image after aspect fit: width=%f height=%f",newwidth,newheight);

    return CGSizeMake(newwidth, newheight);
}

@end
