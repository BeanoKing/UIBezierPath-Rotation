//
//  CustomView.m
//  Rotation
//
//  Created by Josh King on 4/7/15.
//  Copyright (c) 2015 Josh King. All rights reserved.
//

#import "CustomView.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation CustomView
{
    CGRect rectangle;
    CGRect circleRect;
    UIBezierPath *rectPath;
    CGPoint pointBase;
    BOOL handleSelected;
    UIBezierPath *circle;
    UIBezierPath *ellipsePath;
    BOOL shadowCircle;
    CGPoint shadowPoint;
    BOOL leftOfAxis;
    CGFloat rotationRadians;
    BOOL radiansSet;
}


- (void)drawRect:(CGRect)rect {
   	CGContextRef context = UIGraphicsGetCurrentContext ();
    CGContextSaveGState (context);
    
    const CGFloat *components = CGColorGetComponents([UIColor blueColor].CGColor);
    [[UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:0.7] setFill];
    
    [[UIColor blueColor] setStroke];
    
    rectangle = CGRectMake(200,300,300,300);
    
    rectPath = [UIBezierPath bezierPathWithRect:rectangle];
    
    if (!shadowCircle && radiansSet)
    {
        CGPathRef path = createPathRotatedAroundBoundingBoxCenter(rectPath.CGPath, rotationRadians);
        rectPath.CGPath = path;
        CGPathRelease(path);
    }
    
    [rectPath setLineWidth:2.0f];
    [rectPath stroke];
    
    [rectPath fill];
    
    [self generateHandle];
    
    CGContextRestoreGState (context);
}

- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    pointBase = p;
    
    if ([circle containsPoint:pointBase])
        handleSelected = YES;
    else
        handleSelected = NO;
    
    [self setNeedsDisplay];
}

- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (handleSelected && [ellipsePath containsPoint:point])
    {
        shadowCircle = YES;
        shadowPoint = point;
        [self setNeedsDisplay];
    }
}

- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
    shadowCircle = NO;
    [self setNeedsDisplay];
}

- (void) generateHandle
{
    CGFloat topXMidPoint = rectangle.origin.x + rectangle.size.width / 2;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [[UIColor lightGrayColor] setStroke];
    [path moveToPoint:CGPointMake(topXMidPoint, rectangle.origin.y - 3)];
    [path addLineToPoint:CGPointMake(topXMidPoint, rectangle.origin.y - 50)];
    [path setLineWidth:1];
    [path stroke];

    circleRect = CGRectMake(topXMidPoint - 12, rectangle.origin.y - 77, 24, 24);

    circle = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [[UIColor lightGrayColor] setStroke];
    [[UIColor greenColor] setFill];
    [circle setLineWidth:2];
    [circle stroke];
    
    if (handleSelected)
    {
        [circle fill];
        
        //draw arc around the object
        ellipsePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(rectangle.origin.x - 100, rectangle.origin.y - 65, 500, 500)];
        [[UIColor lightGrayColor] setStroke];
        [ellipsePath stroke];
    }
    
    if (shadowCircle)
    {
        if (shadowPoint.x < pointBase.x)
            leftOfAxis = YES;
        else
            leftOfAxis = NO;
        
        CGRect shadowRect = CGRectMake(shadowPoint.x, shadowPoint.y, 24, 24);
        [[UIColor blueColor] setStroke];
        UIBezierPath *shadowCirclePath = [UIBezierPath bezierPathWithOvalInRect:shadowRect];
        [shadowCirclePath setLineWidth:1];
        [shadowCirclePath stroke];
        
        CGPoint middlePoint = CGPointMake(rectangle.origin.x + (rectangle.size.width / 2), rectangle.origin.y + (rectangle.size.height / 2));
        
        CGFloat angle = [self angleBetweenTwoPoints:middlePoint endPoint:shadowPoint];
        NSLog(@"%f",angle);
        NSLog(@"%@",(leftOfAxis ? @"Yes" : @"No"));
        
        if (!leftOfAxis && angle >= 270)
        {
            angle = 360 - angle + 90;
        }
        else
        {
            angle = (!leftOfAxis ? abs(angle - 90) : 360 - abs(angle - 90));
        }
        
        NSLog(@"%f",angle);
        
        rotationRadians = DEGREES_TO_RADIANS(angle);
        radiansSet = YES;
        CGPathRef path = createPathRotatedAroundBoundingBoxCenter(rectPath.CGPath, rotationRadians);
        rectPath.CGPath = path;
        [[UIColor lightGrayColor] setStroke];
        CGPathRelease(path);
        
        //CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
        //[rectPath applyTransform:transform];
        [rectPath stroke];
        
        //CGFloat distance = [self distanceBetweenTwoPoints:pointBase p2:shadowPoint];
       // NSLog(@"%f",distance);
    }
}


- (CGFloat) angleBetweenTwoPoints:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    float deltaX = endPoint.x - startPoint.x;
    float deltaY = endPoint.y - startPoint.y;
    
    float angle = atan2f(-deltaY, deltaX) * 180 / M_PI;
    
    if (angle < 0) {
        angle = 180 - abs(angle) + 180;
    }
    
    return angle;
}

static CGPathRef createPathRotatedAroundBoundingBoxCenter(CGPathRef path, CGFloat radians) {
    CGRect bounds = CGPathGetBoundingBox(path); // might want to use CGPathGetPathBoundingBox
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, center.x, center.y);
    transform = CGAffineTransformRotate(transform, radians);
    transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
    return CGPathCreateCopyByTransformingPath(path, &transform);
}


@end
