# RMPageView

//导入#import "RMPageView.h"


![image](https://github.com/raomengchen/RMPageView/blob/master/88.gif)

/**
子控器数组
*/
@property (nonatomic, strong) NSArray *childControllers;

/**
子控制器标题数组
*/
@property (nonatomic, strong) NSArray<RMPageModel *> *childTitles;

/**
设置当前选择item
*/
@property (nonatomic, assign) NSInteger selectedTabIndex;

/**
设置一页最多显示的个数
*/
@property (nonatomic, assign) NSInteger maxNumberOfPageItems;

/**
两个标题之间的距离
*/
@property (nonatomic, assign) CGFloat   spaceBetweenTabIndex;

/**
item的size
*/
@property (nonatomic, assign) CGSize tabSize;

/**
item的字体大小
*/
@property (nonatomic, strong) UIFont *tabItemFont;

/**
未选择颜色
*/
@property (nonatomic, strong) UIColor *unSelectedColor;

/**
当前选中颜色
*/
@property (nonatomic, strong) UIColor *selectedColor;

/**
顶部标题的颜色背景色，默认white
*/
@property (nonatomic, strong) UIColor *tabBackgroundColor;

/**
滑动代理
*/
@property (nonatomic, assign) id<RMPageViewDelegate>delegate;


/**
初始化View

@param childControllers 子控器数组
@param childTitles 子控制器标题数组
@return <#return value description#>
*/
- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)childControllers childTitles:(NSArray<RMPageModel *> *)childTitles ;


//初始化
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


// 增加控制器 

FirstViewController *fiveVC2 = [[FirstViewController alloc]init];
[self addChildViewController:fiveVC2];
NSMutableArray *addArray = [NSMutableArray arrayWithArray:_pageView.childTitles];
RMPageModel *model = [[RMPageModel alloc]init];
model.title = @"新增加";
model.isShowIndentifImageView = YES;
[addArray addObject:model];
_pageView.childTitles = addArray;
_pageView.childControllers = self.childViewControllers;

![image](https://github.com/raomengchen/RMPageView/blob/master/99.gif)



// 代理
- (void)pageView:(RMPageView *)pageView endChangePageLastSelectedTabIndex:(NSInteger)lastSelectedTabIndex selectedTabIndex:(NSInteger)selectedTabIndex;

/**
第二次点击标题

@param pageView <#pageView description#>
@param selectTabIndex <#selectTabIndex description#>
*/
- (void)pageView:(RMPageView *)pageView selectedTabIndex:(NSInteger )selectTabIndex;






