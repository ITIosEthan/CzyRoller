//
//  CzyCircleView.m
//  CzyCircleAnimation
//
//  Created by macOfEthan on 17/8/1.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "CzyCircleView.h"

@interface CzyCircleView ()
{
    CAShapeLayer *_circle;
    CAShapeLayer *_line;
}

@property (nonatomic, strong) UIBezierPath *path;
@end

@implementation CzyCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        
        [self drawStaticUI];
        
    }
    
    return self;
}

- (void)drawStaticUI
{
    CGFloat labW = 30;
    CGFloat labH = 30;
    CGFloat lineW = 3;
    
    _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labW, labH)];
    _percentLabel.text = @"0%";
    _percentLabel.adjustsFontSizeToFitWidth = YES;
    _percentLabel.center = self.center;
    _percentLabel.textAlignment = NSTextAlignmentCenter;
    _percentLabel.textColor = [UIColor redColor];
    [self addSubview:_percentLabel];
    
    //半径
    CGFloat radius = labW/2+lineW;
    
    _path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(labW/2, labH/2) radius:radius startAngle:-0.5*M_PI endAngle:1.5*M_PI clockwise:YES];
    
    //画圆
    _circle = [CAShapeLayer layer];
    _circle.fillColor = [UIColor clearColor].CGColor;
    _circle.frame = _percentLabel.bounds;
    _circle.path = _path.CGPath;
    _circle.strokeEnd = 0.5;
    [_percentLabel.layer addSublayer:_circle];
    
    //画圆外的线条
    _line = [CAShapeLayer layer];
    _line.frame = _percentLabel.bounds;
    _line.fillColor = [UIColor clearColor].CGColor;
    _line.strokeColor = [UIColor whiteColor].CGColor;
    //设置进度为0
    _line.strokeEnd = 0;
    _line.lineWidth = lineW;
    _line.lineCap = kCALineCapRound;
    _line.lineJoin = kCALineJoinRound;
    _line.path = _path.CGPath;
    //设置frame
    [_percentLabel.layer addSublayer:_line];
    
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    _percentLabel.text = [NSString stringWithFormat:@"%.0f%%",progress*100];
    
    _line.strokeEnd = progress;
    
    //NSLog(@"progress = %f ,_percentLabel.text = %@", progress, _percentLabel.text);
}

@end
