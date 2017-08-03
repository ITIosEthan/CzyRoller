//
//  ViewController.m
//  CzyImageRoller
//
//  Created by macOfEthan on 17/8/1.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "ViewController.h"
#import "CzyImageRollerView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDImageCache.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) CzyImageRollerView *rollerView;

@end

@implementation ViewController

- (NSArray *)imageUrls
{
    return @[@"http://pic49.nipic.com/file/20140927/19617624_230415502002_2.jpg",
      @"http://img3.redocn.com/tupian/20150430/mantenghuawenmodianshiliangbeijing_3924704.jpg",
      @"http://pic76.nipic.com/file/20150826/19291311_131811815000_2.jpg",
      @"http://imgsrc.baidu.com/image/c0%3Dshijue1%2C0%2C0%2C294%2C40/sign=60aeee5da74bd11310c0bf7132c6ce7a/72f082025aafa40fe3c0c4f3a164034f78f0199d.jpg",
      @"http://pic.58pic.com/58pic/13/74/51/99d58PIC6vm_1024.jpg",
      @"http://pic.58pic.com/58pic/13/85/85/73T58PIC9aj_1024.jpg",
      @"http://imgsrc.baidu.com/image/c0%3Dshijue1%2C0%2C0%2C294%2C40/sign=9909ddc1b91c8701c2bbbaa54f16f45a/a08b87d6277f9e2fb0727e2d1530e924b899f354.jpg"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    _headerImageView.userInteractionEnabled = YES;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[self imageUrls].firstObject] placeholderImage:[UIImage imageNamed:@"1S8xRc"]];
    self.tableView.tableHeaderView = _headerImageView;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShow:)];
    [_headerImageView addGestureRecognizer:tapGes];
}

- (void)tapShow:(UITapGestureRecognizer *)tap
{
    _rollerView = [[CzyImageRollerView alloc] initWithFrame:self.view.bounds];
    
    //设置url数组
    _rollerView.imageUrls = [self imageUrls].mutableCopy;
    
    //设置页码样式
    _rollerView.pageStyle = CzyPageStyleDot;
    
    [self.view addSubview:_rollerView];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[SDImageCache new] clearMemory];
    [[SDImageCache new] clearDiskOnCompletion:^{
        
    }];
    
    NSLog(@" -- %ld -- %ld -- ", [[SDImageCache new] getSize], [[SDImageCache new] getDiskCount]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reusedId = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
    }
    
    cell.textLabel.text = @"快速清除图片";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end
