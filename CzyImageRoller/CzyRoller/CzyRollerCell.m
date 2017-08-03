//
//  CzyRollerCell.m
//  CzyImageRoller
//
//  Created by macOfEthan on 17/8/1.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//


#import "CzyRollerCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CzyCircleView.h"

static CGFloat minZoomScale = 1;
static CGFloat maxZoomScale = 3;


@interface CzyRollerCell ()<UIScrollViewDelegate>

//colltionView上放scrollView scrollView上方imageView
//设置imageviewframe和contentsize
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *contentImageView;

//进度条
@property (nonatomic, strong) CzyCircleView *circleView;

@end

@implementation CzyRollerCell



#pragma mark - setImageUrl
- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    
    
    [_contentImageView sd_setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:nil options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        _circleView.hidden = NO;
        
        //不在主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _circleView.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
        });
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        //一定在图片下载完成之后在设置imageView的frame 和滚动视图 contentSize
        //因为其中会生成很多中间图片 可以打印地址都不一样
        if (!error) {
            
            //移除进度
            _circleView.hidden = YES;
            
            _contentImageView.frame = [self imageFrame];
            _scrollView.contentSize = CGSizeMake(kRollerWidth, [self imageFrame].size.height > self.bounds.size.height ? [self imageFrame].size.height : self.bounds.size.height+1);
        }
    }];
}

#pragma mark - prepareForReuse
- (void)prepareForReuse
{
//    NSLog(@"准备复用");
    
//    [self setNeedsLayout];
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self UIInit];
    }
    return self;
}

- (void)UIInit
{
    //scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kRollerWidth, kRollerHeight)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.minimumZoomScale = minZoomScale;
    _scrollView.maximumZoomScale = maxZoomScale;
    _scrollView.decelerationRate = 1.f;
    _scrollView.delegate = self;
    _scrollView.userInteractionEnabled = YES;
    [self.contentView addSubview:_scrollView];
    
    //图片
    _contentImageView = [[UIImageView alloc] init];
    _contentImageView.userInteractionEnabled = YES;
    //注意 先设置图片 在计算frame  frame需要按照图片宽高比来计算
    _contentImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", arc4random()%11+1]];
//    _contentImageView.frame = [self imageFrame];
    [_scrollView addSubview:_contentImageView];
    
    //错误做法 ：每张图片地址不一样 图片宽高还没有确定
    //初始化contentSize 如果按照图片宽高比计算出来的高度 高于 scrollView高度 就按计算出来的高度  否则 按scrollView高度+1 +1是为了让scrollView可以上下拖动
    //_scrollView.contentSize = CGSizeMake(kRollerWidth, [self imageFrame].size.height > _scrollView.bounds.size.height ? [self imageFrame].size.height : _scrollView.bounds.size.height+1);
    //NSLog(@"image frame = %@, contentSize = %@", NSStringFromCGRect(_contentImageView.frame), NSStringFromCGSize(_scrollView.contentSize));
    
    //双击放大手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_contentImageView addGestureRecognizer:doubleTap];
    
    //拖动手势 下拖到一定程度 消失
    [_scrollView.panGestureRecognizer addTarget:self action:@selector(pan:)];
    
    //单机显示张数 和提示
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:singleTap];
    
    //进度条
    _circleView = [[CzyCircleView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _circleView.center = self.center;
    [self.contentView addSubview:_circleView];
}

#pragma mark - 单击手势
- (void)singleTap:(UITapGestureRecognizer *)tap
{
    if (self.hiddenBlock) {
        self.hiddenBlock();
    }
}

#pragma mark - 拖动手势
- (void)pan:(UIPanGestureRecognizer *)panGes
{
//    NSLog(@"_scrollView.frame = %@ _scrollView.contentOffset.y = %f", NSStringFromCGRect(_scrollView.frame), _scrollView.contentOffset.y);
    
    //放大情况下 禁止下拉移除
    if (_scrollView.zoomScale > minZoomScale) {
        
        return;
    }
    
    CGFloat offsetY = _scrollView.contentOffset.y;
    
    //反推直接返回
    if (offsetY > 0) {
        return;
    }
    
    //结束手势
    if (panGes.state == UIGestureRecognizerStateEnded) {
        
        //下拖消失
        if (offsetY < -120) {
            //下拉关闭
            if (self.dismissBlock) {
                self.dismissBlock();
            }
        }else{
        
            //回到起始位置
            [UIView animateWithDuration:0.5f animations:^{
                [_scrollView setContentInset:UIEdgeInsetsZero];
                self.collectionView.alpha = 1;
            }];
        }
        
    }else{
    
        if (offsetY > -120) {
            
            //NSLog(@"1+offsetY/120 = %f", 1+offsetY/120);
            
            self.collectionView.alpha = 1+offsetY/120;
            
        }
    }
}

#pragma mark - 双击放大手势
- (void)doubleTap:(UIGestureRecognizer *)gesture
{
    //切换比例
    CGFloat zoomScale = (_scrollView.zoomScale == minZoomScale) ? maxZoomScale : minZoomScale;
    
    //需要放大的区域
    CGRect zoomRect = [self zoomRectWithPoint:[gesture locationInView:_contentImageView] andScale:zoomScale];
    
    //放大指定区域
    [_scrollView zoomToRect:zoomRect animated:YES];
}

/*
 _scrollView.frame.size.width = 414.000000
 _scrollView.frame.size.height = 736.000000
 scale = 3.000000
 point.x = 399.000000
 point.y = 475.333328
 w = 138.000000
 h = 245.333333
 x = 330.000000
 y = 352.666662
 
 _scrollView.frame.size.width = 414.000000
 _scrollView.frame.size.height = 736.000000
 scale = 3.000000
 point.x = 402.666656
 point.y = 276.000000
 w = 138.000000
 h = 245.333333
 x = 333.666656
 y = 153.333333
 */

#pragma mark - 返回需要 扩大 或者 缩小的区域
- (CGRect)zoomRectWithPoint:(CGPoint)point andScale:(CGFloat)scale
{
    //比例越大 返回的区域越小
    CGFloat w = self.bounds.size.width/scale;
    CGFloat h = self.bounds.size.height/scale;
    //点击位置 - 宽高 就是 扩大或者缩小后的坐标 -w*0.5最佳
    CGFloat x = point.x - w*0.5;
    CGFloat y = point.y - h*0.5;
    
    //NSLog(@" _scrollView.frame.size.width = %f \n _scrollView.frame.size.height = %f \n scale = %f \n point.x = %f \n point.y = %f \n w = %f \n h = %f \n x = %f \n y = %f", _scrollView.frame.size.width, _scrollView.frame.size.height, scale, point.x, point.y, w, h, x, y);
    
    return CGRectMake(x, y, w, h);
}

#pragma mark - <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _contentImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //双击走一次 拖动走多次
    
    //重新更新图片位置
    [self updateImageFrame];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //NSLog(@"scrollViewDidEndZooming scale = %f", scale);
    
    //扩大放大状态直接返回
    if (_scrollView.zoomScale == maxZoomScale) {
        return;
    }
    
    //回复到1.0scale时重新设置图片frame和contentSize
    _contentImageView.frame = [self imageFrame];
    _scrollView.contentSize = [self imageFrame].size.height > _scrollView.bounds.size.height ? [self imageFrame].size : CGSizeMake(kRollerWidth, kRollerHeight+1);
}

#pragma mark - 获取ImageView真实比例宽高
- (CGRect)imageFrame
{
    //没有图片 返回scrollView高度
    if (_contentImageView.image == nil) {
        return _scrollView.bounds;
    }
    
    UIImage *img = _contentImageView.image;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetWidth(_scrollView.frame) * img.size.height/img.size.width;
    CGFloat x = 0;
    CGFloat y = (height < self.bounds.size.height) ? (self.bounds.size.height-height)/2 : 0;
    
//    NSLog(@"x = %f, y = %f, width = %f, height = %f", x, y, width, height);
    //0x60000009dce0  0x608000090540
    //NSLog(@"img = %p \n", img);
    
    //NSLog(@"====== \n img width = %f  height = %f", img.size.width, img.size.height);
    
    return CGRectMake(x, y, width, height);
}

#pragma mark - 更新图片位置
- (void)updateImageFrame
{
    CGRect imageFrame = _contentImageView.frame;
    
    //视情况调整宽度和高度
    if (imageFrame.size.width > self.bounds.size.width) {
        
        //imageFrame.origin.x = (self.bounds.size.width - imageFrame.size.width)/2;
    }else{
        imageFrame.origin.x = 0;
    }
    
    if (imageFrame.size.height < self.bounds.size.height) {
        
        imageFrame.origin.y = (self.bounds.size.height - imageFrame.size.height)/2;
    }else{
        imageFrame.origin.y = 0;
    }
    
    if (CGRectEqualToRect(imageFrame, _contentImageView.frame) == false) {
        _contentImageView.frame = imageFrame;
    }
}

@end


