//
//  ViewController.m
//  RMPageController
//
//  Created by RaoMeng on 2017/5/22.
//  Copyright © 2017年 TianyingJiuzhou Network Technology Co. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Frame.h"
#import "FirstViewController.h"
#import "TwoViewController.h"
#import "ThirdViewController.h"
#import "FourViewController.h"
#import "FiveViewController.h"

#import "RMPageView.h"

@interface ViewController ()<RMPageViewDelegate>


@property (nonatomic, strong) UIButton *addTitleBtn;

@property (nonatomic, strong) RMPageView *pageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    FirstViewController *firstVC = [[FirstViewController alloc]init];
    TwoViewController *twoVC = [[TwoViewController alloc]init];
    ThirdViewController *thirdVC = [[ThirdViewController alloc]init];
    FourViewController *fourVC = [[FourViewController alloc]init];
    FiveViewController *fiveVC = [[FiveViewController alloc]init];
    FourViewController *fourVC1 = [[FourViewController alloc]init];
    FiveViewController *fiveVC1 = [[FiveViewController alloc]init];
    [self addChildViewController:firstVC];
    [self addChildViewController:twoVC];
    [self addChildViewController:thirdVC];
    [self addChildViewController:fourVC];
    [self addChildViewController:fiveVC];
    [self addChildViewController:fourVC1];
    [self addChildViewController:fiveVC1];
    
    NSArray *titleArray = @[@"视频",@"新闻",@"直播",@"开心一笑",@"嘿嘿",@"开心一笑",@"嘿嘿"];
    NSMutableArray *newTitleArray = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < titleArray.count; i++ ) {
        RMPageModel *model = [[RMPageModel alloc]init];
        model.title = titleArray[i];
        model.isShowIndentifImageView = (i < 3) ? YES : NO;  // 是否显示标题上面的标签
        [newTitleArray addObject:model];
    }
    
    _pageView = [[RMPageView alloc]initWithChildControllers:self.childViewControllers childTitles:newTitleArray];
    _pageView.frame = CGRectMake(0, 20, self.view.width, self.view.height - 20);
    [self.view addSubview:_pageView];
    _pageView.delegate = self;
    
    
    self.addTitleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.addTitleBtn.frame = CGRectMake(100, 200, 100, 40);
    [self.addTitleBtn setTitle:@"增加控制器" forState:UIControlStateNormal];
    [self.view addSubview:self.addTitleBtn];
    
    [self.addTitleBtn addTarget:self action:@selector(addTitle:) forControlEvents:UIControlEventTouchUpInside];
    
}



- (void)addTitle:(UIButton *)sender {
    
    FirstViewController *fiveVC2 = [[FirstViewController alloc]init];
    [self addChildViewController:fiveVC2];
    NSMutableArray *addArray = [NSMutableArray arrayWithArray:_pageView.childTitles];
    RMPageModel *model = [[RMPageModel alloc]init];
    model.title = @"新增加";
    model.isShowIndentifImageView = YES;
    [addArray addObject:model];
    _pageView.childTitles = addArray;
    _pageView.childControllers = self.childViewControllers;
    
}





-(void)pageView:(RMPageView *)pageView endChangePageLastSelectedTabIndex:(NSInteger)lastSelectedTabIndex selectedTabIndex:(NSInteger)selectedTabIndex {
    
    NSLog(@"lastSelectIndex:%ld  selectIndex:%ld",lastSelectedTabIndex,selectedTabIndex);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
