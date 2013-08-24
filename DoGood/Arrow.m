#import "Arrow.h"
#define kTriangleHeight 8.

@implementation Arrow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor whiteColor] set];

    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(rect.size.width / 2 - kTriangleHeight, 0)];
    [trianglePath addLineToPoint:CGPointMake(rect.size.width / 2, kTriangleHeight)];
    [trianglePath addLineToPoint:CGPointMake(rect.size.width / 2 + kTriangleHeight, 0)];
    [trianglePath closePath];
    [trianglePath fill];
}

@end
