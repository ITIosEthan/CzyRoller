//
//  CzyImageRollerView.m
//  CzyImageRoller
//
//  Created by macOfEthan on 17/8/1.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//


#import "CzyImageRollerView.h"
#import "CzyRollerCell.h"
#import "CzyCircleView.h"

static CGFloat bottomBarH = 40;

@interface CzyImageRollerView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

//滚动视图collectionView
@property (nonatomic, strong) UICollectionView *roller;
//底部功能区域
@property (nonatomic, strong) UIView *bottonFunctionBar;
//页码
@property (nonatomic, strong) UILabel *pageNum;
//提示
@property (nonatomic, strong) UILabel *alerter;
//保存
@property (nonatomic, strong) UIButton *save;
//pageControl样式显示页码
@property (nonatomic, strong) UIPageControl *pageControl;
//当前显示第几张图片 记录保存至相册
@property (nonatomic, assign) NSInteger currentImagePage;


@end

@implementation CzyImageRollerView

#pragma mark - Setter
- (void)setImageUrls:(NSArray *)imageUrls
{
    _imageUrls = imageUrls;
    
    [_roller reloadData];
}

#pragma mark - initWithFrame
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self rollerInit];
    }
    return self;
}

- (void)rollerInit
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 20);
    layout.itemSize = CGSizeMake(kRollerWidth, kRollerHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    //宽度+10 留10
    _roller = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kRollerWidth+10, kRollerHeight) collectionViewLayout:layout];
    _roller.delegate = self;
    _roller.dataSource = self;
    _roller.showsHorizontalScrollIndicator = NO;
    _roller.pagingEnabled = YES;
    [self addSubview:_roller];
    
    [_roller registerClass:[CzyRollerCell class] forCellWithReuseIdentifier:NSStringFromClass([CzyRollerCell class])];
    
    //下拉移除提示
    _alerter = [[UILabel alloc] initWithFrame:CGRectMake(kRollerWidth/2-120/2, 10, 120, 60)];
    _alerter.text = @"努力下拉可以移除\n单击隐藏工具栏\n双击放大拖动浏览";
    _alerter.numberOfLines = 3;
    _alerter.font = [UIFont systemFontOfSize:14];
    _alerter.textAlignment = NSTextAlignmentCenter;
    _alerter.textColor = [UIColor whiteColor];
    [self addSubview:_alerter];
    
    [_alerter.layer addAnimation:[self upDownAnimation] forKey:@"position"];
    
    //保存图片
    _save = [UIButton buttonWithType:UIButtonTypeCustom];
    _save.frame = CGRectMake(kRollerWidth-10-60, 20, 60, 30);
    [_save setTitle:@"保存图片" forState:UIControlStateNormal];
    [_save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _save.titleLabel.font = [UIFont systemFontOfSize:14];
    [_save addTarget:self action:@selector(saveImageToAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_save];
}

#pragma mark - setPageStyle
- (void)setPageStyle:(CzyPageStyle)pageStyle
{
    _pageStyle = pageStyle;
    
    if (_pageStyle == CzyPageStyleLabel) {
        
        if (_bottonFunctionBar) {
            return;
        }
        
        [self bottomLabelStyle];
    }else if (_pageStyle == CzyPageStyleDot){
        
        if (_pageControl) {
            return;
        }
        
        [self bottomDotStyle];
    }
}

#pragma mark - bottomLabelStyle
- (void)bottomLabelStyle
{
    //底部
    _bottonFunctionBar = [[UIView alloc] initWithFrame:CGRectMake(0, kRollerHeight-bottomBarH, kRollerWidth, bottomBarH)];
    _bottonFunctionBar.backgroundColor = [UIColor clearColor];
    _bottonFunctionBar.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottonFunctionBar];
    
    _pageNum = [[UILabel alloc] initWithFrame:CGRectMake(kRollerWidth/2-70, 10, 140, 20)];
    _pageNum.text = [NSString stringWithFormat:@"1/%ld", self.imageUrls.count];
    _pageNum.textColor = [UIColor whiteColor];
    _pageNum.textAlignment = NSTextAlignmentCenter;
    _pageNum.font = [UIFont boldSystemFontOfSize:14];
    [_bottonFunctionBar addSubview:_pageNum];
    
}

#pragma mark - bottomDotStyle
- (void)bottomDotStyle
{
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(kRollerWidth/2-150/2, kRollerHeight-50, 150, 30)];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.numberOfPages = self.imageUrls.count;
    _pageControl.currentPage = 0;
    [self addSubview:_pageControl];
}

#pragma mark - 页码设置
- (void)setCurrentPage:(NSInteger)curentPage total:(NSUInteger)totalPage
{
    if (_pageStyle == CzyPageStyleLabel) {
        _pageNum.text = [NSString stringWithFormat:@"%ld/%ld", curentPage+1, totalPage];
    }else{
        _pageControl.numberOfPages = totalPage;
        _pageControl.currentPage = curentPage;
    }
}

#pragma mark - 保存图片
- (void)saveImageToAlbum
{
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.imageUrls[_currentImagePage]]];
    UIImage *targetImage = [[UIImage alloc] initWithData:imageData];
    UIImageWriteToSavedPhotosAlbum(targetImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"imageDidSaveToAlbumWithError error = %@", error);

}

#pragma mark - <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self imageUrls].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CzyRollerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CzyRollerCell class]) forIndexPath:indexPath];
    
    //图片地址
    cell.imageUrl = self.imageUrls[indexPath.row];
    
    //传过去父视图改变透明度
    cell.collectionView = collectionView;
    
    //单击影藏或者显示
    cell.hiddenBlock = ^(){
        _bottonFunctionBar.hidden = (_bottonFunctionBar.hidden == NO) ? YES : NO;
        _pageControl.hidden = (_pageControl.hidden == NO) ? YES : NO;
    };
    
    //下拉消失
    cell.dismissBlock = ^(){

        [self removeFromSuperview];
    };
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kRollerWidth, kRollerHeight);
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentImagePage = scrollView.contentOffset.x / kRollerWidth;
    
    //NSLog(@"_cur_currentImagePage = %ld", _currentImagePage);
    
    //设置页码
    [self setCurrentPage:_currentImagePage total:self.imageUrls.count];
    
}

#pragma mark - 上下摆动动画
- (CAKeyframeAnimation *)upDownAnimation
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    positionAnimation.values = @[@20, @40, @20];
    positionAnimation.duration = 2.0f;
    positionAnimation.repeatCount = MAXFLOAT;
    positionAnimation.fillMode = kCAFillModeForwards;
    positionAnimation.removedOnCompletion = YES;
    positionAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    return positionAnimation;
}

@end





