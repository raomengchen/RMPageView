//
//  RMPageView.m
//  RMPageController
//
//  Created by RaoMeng on 2017/5/22.
//  Copyright © 2017年 TianyingJiuzhou Network Technology Co. Ltd. All rights reserved.
//

#import "RMPageView.h"
#import "UIView+Frame.h"

#import "RMPageTitleView.h"
#import "RMPageBodyCollectionViewCell.h"  // body的cell;

#define kTopTitleDefautHeight 40.0
#define kTopTitleDefautFontSize 18.0
#define kIndicatorHeight 1.5
#define kIndicatorWidth 30
#define kMinScale 0.833333   // 设置
#define spaceTabItem  25
#define spaceLeft  15   //距离屏幕最左边15

@interface RMPageView()<UICollectionViewDelegate,UICollectionViewDataSource>

/**
顶部标题
 */
@property (nonatomic, strong) UIScrollView *topTitleScrollview;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UICollectionView *bodyView;
@property (nonatomic, assign) CGFloat tabItemWidth;  // 标题宽度
@property (nonatomic, assign) NSInteger numberOfTabItems;
@property (nonatomic, assign) CGFloat contentTabView;  // 上面标题的宽度

@property (nonatomic, strong) UIImageView *shadowImageView; // 下面标题

/**
 标题数组
 */
@property (nonatomic, strong) NSMutableArray *tabItems;
@property (nonatomic, assign) NSInteger lastSelectedTabIndex; //记录上一次的索引
@property (nonatomic, assign) BOOL isClick; //是否是通过点击改变的。
@property (nonatomic, assign) BOOL isNeedRefreshLayout; // 滑动过程中不允许layoutSubviews
@property (nonatomic, assign) NSInteger leftItemIndex; //记录滑动时左边的itemIndex
@property (nonatomic, assign) NSInteger rightItemIndex; //记录滑动时右边的itemIndex



@end

@implementation RMPageView

#pragma mark - initView

- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)childControllers childTitles:(NSArray<RMPageModel *> *)childTitles {
    
    self = [super init];
    if(self) {
        _childControllers = childControllers;
        _childTitles = childTitles;
        [self initBaseSettings];
        [self initView];
    }
    return self;
}

- (void)initBaseSettings {
    
    _selectedTabIndex = 0;
    _lastSelectedTabIndex = 0;
    _tabItems = [NSMutableArray arrayWithCapacity:1];
    _tabSize = CGSizeZero;
    _numberOfTabItems =  _childTitles.count;
    _indicatorHeight = kIndicatorHeight;
    _indicatorWidth = kIndicatorWidth;
    _tabItemFont = [UIFont systemFontOfSize:kTopTitleDefautFontSize];
    _spaceBetweenTabIndex = spaceTabItem;
    _tabBackgroundColor = [UIColor whiteColor];
    
    _minScale = kMinScale;
    _unSelectedColor = [UIColor blackColor];
    _selectedColor = [UIColor redColor];
    self.isNeedRefreshLayout = YES;
    _isClick = NO;
    
}

- (void) initView {
    
    _topTitleScrollview = [UIScrollView new];
    _topTitleScrollview.showsVerticalScrollIndicator = NO;
    _topTitleScrollview.showsHorizontalScrollIndicator = NO;
    _topTitleScrollview.backgroundColor = _tabBackgroundColor;
    _topTitleScrollview.clipsToBounds = YES;
    _topTitleScrollview.delegate = self;
    [self addSubview:_topTitleScrollview];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; // 设置水平滚动
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _bodyView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    _bodyView.showsVerticalScrollIndicator = NO;
    _bodyView.showsHorizontalScrollIndicator = NO;
    _bodyView.backgroundColor = [UIColor whiteColor];
    _bodyView.pagingEnabled = YES;
    _bodyView.delegate = self;
    _bodyView.dataSource = self;
    [self addSubview:self.bodyView];
    
    
    _shadowImageView = [[UIImageView alloc]init];
    _shadowImageView.image = [UIImage imageNamed:@""];
    _shadowImageView.backgroundColor = [UIColor greenColor];
    [self addSubview:_shadowImageView];
    
    
    _indicatorView = [UIView new];
    _indicatorView.backgroundColor = _selectedColor;
    [self addSubview:self.indicatorView];
    
    self.backgroundColor = [UIColor clearColor];
//    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
//    effe.frame = self.bounds;
//    [self addSubview:effe];
    
    
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        
        RMPageTitleView *tabItem = [[RMPageTitleView alloc] init];
        tabItem.pageTitleLabel.font = _tabItemFont;
        tabItem.pageModel = _childTitles[i];
        tabItem.pageTitleLabel.textColor = i ==_selectedTabIndex ? _selectedColor : _unSelectedColor;
        tabItem.userInteractionEnabled = YES;
        if (i == 0) {
            tabItem.pageTitleLabel.transform = CGAffineTransformMakeScale(1.0,1.0);
        } else {
            tabItem.pageTitleLabel.transform = CGAffineTransformMakeScale(_minScale,_minScale);
        }
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeChildControllerOnClick:)];
        [tabItem addGestureRecognizer:tapRecognizer];
        [_tabItems addObject:tabItem];
        [_topTitleScrollview addSubview:tabItem];
    }
    [self.bodyView registerClass:[RMPageBodyCollectionViewCell class] forCellWithReuseIdentifier:@"bodyCell"];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isNeedRefreshLayout) {
        if(_tabSize.height <= 0) {
            _tabSize.height = kTopTitleDefautHeight;
        }
        if(_tabSize.width <= 0) {
            _tabSize.width = self.width;
        }
        _topTitleScrollview.frame = CGRectMake(0, 0, self.width, kTopTitleDefautHeight);
     

        CGFloat contentTab = 0; // 前面距离X的位置
        for(NSInteger i = 0; i < _tabItems.count; i++) {
            
            RMPageTitleView *tabItem = (RMPageTitleView *)_tabItems[i];
            CGFloat tabItemWidth = [self getTitleWidth:tabItem.pageTitleLabel.text] ; // 计算文本的高度
            tabItem.frame = CGRectMake(contentTab , 0, tabItemWidth, _tabSize.height);
            contentTab += tabItemWidth + 0;
        }
        self.contentTabView = contentTab;
        _topTitleScrollview.contentSize = CGSizeMake(contentTab, 0);
        
        _shadowImageView.frame = CGRectMake(0, kTopTitleDefautHeight, self.width, 3);
        
        self.bodyView.frame = CGRectMake(0, kTopTitleDefautHeight + 3, self.width, self.height - kTopTitleDefautHeight - 3);
        [self.bodyView reloadData];
        [self layoutIndicatorView];
        [self reviseTabContentOffsetBySelectedIndex:NO];
        
    }
}


- (void)layoutIndicatorView {
    
    RMPageTitleView *selecedTabItem = _tabItems[_selectedTabIndex];
    self.indicatorView.frame = CGRectMake(selecedTabItem.center.x - _indicatorWidth / 2.0 - _topTitleScrollview.contentOffset.x, _tabSize.height - _indicatorHeight, _indicatorWidth, _indicatorHeight);
}

/**
 根据选择项修正tab的展示区域
 */
- (void)reviseTabContentOffsetBySelectedIndex:(BOOL)isAnimate {
    
    if (_topTitleScrollview.width >= self.contentTabView) {
        return; // 如果contentSize小于本身的宽度不操作
    }
    RMPageTitleView *currentTabItem = _tabItems[_selectedTabIndex];
    CGFloat selectedItemCenterX = currentTabItem.center.x;
    CGFloat reviseX;
    if(selectedItemCenterX + _tabSize.width / 2.0 >= _topTitleScrollview.contentSize.width) {
        reviseX = _topTitleScrollview.contentSize.width - _tabSize.width; //不足以到中心，靠右
    } else if(selectedItemCenterX - _tabSize.width / 2.0 <= 0) {
        reviseX = 0; //不足以到中心，靠左
    } else {
        reviseX = selectedItemCenterX - _tabSize.width / 2.0; //修正至中心
    }
    //如果前后没有偏移量差，setContentOffset实际不起作用；或者没有动画效果
    if(fabs(_topTitleScrollview.contentOffset.x - reviseX) < 1 || !isAnimate) {
        [self finishReviseTabContentOffset];
    }
    [_topTitleScrollview setContentOffset:CGPointMake(reviseX, 0) animated:isAnimate];
}


- (void)finishReviseTabContentOffset {
    
    _topTitleScrollview.userInteractionEnabled = YES;
    _isNeedRefreshLayout = YES;
    _isClick = NO;
    if ([self.delegate respondsToSelector:@selector(pageView:endChangePageLastSelectedTabIndex:selectedTabIndex:)]) {
        [self.delegate pageView:self endChangePageLastSelectedTabIndex:self.lastSelectedTabIndex selectedTabIndex:_selectedTabIndex];
    }
    _lastSelectedTabIndex = _selectedTabIndex;
}


- (void)changeSelectedItemToNextItem:(NSInteger)nextIndex {
    
    RMPageTitleView *currentTabItem = _tabItems[_selectedTabIndex];
    RMPageTitleView *nextTabItem = _tabItems[nextIndex];
    currentTabItem.pageTitleLabel.textColor = _unSelectedColor;
    nextTabItem.pageTitleLabel.textColor = _selectedColor;
}

#pragma mark -Title layout

- (void)resetTabItemScale {
    
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        RMPageTitleView *tabItem = _tabItems[i];
        if(i != _selectedTabIndex) {
            tabItem.pageTitleLabel.transform = CGAffineTransformMakeScale(_minScale, _minScale);
        } else {
            tabItem.pageTitleLabel.transform = CGAffineTransformMakeScale(1, 1);
        }
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.childTitles.count;
    
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
        RMPageBodyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bodyCell" forIndexPath:indexPath];
        cell.bodyController = self.childControllers[indexPath.row];
        return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

        return CGSizeMake(self.width, self.height - kTopTitleDefautHeight);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(scrollView == self.bodyView) {
        _selectedTabIndex = self.bodyView.contentOffset.x / self.bodyView.width;
        [self reviseTabContentOffsetBySelectedIndex:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if(scrollView == self.bodyView) {
        [self reviseTabContentOffsetBySelectedIndex:YES];
    } else if (scrollView == _topTitleScrollview){
        [self finishReviseTabContentOffset];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(scrollView == _topTitleScrollview) {
        _isNeedRefreshLayout = NO;
        if(self.indicatorView.superview) {
            RMPageTitleView *selecedTabItem = _tabItems[_selectedTabIndex];
            self.indicatorView.frame = CGRectMake(selecedTabItem.center.x - self.indicatorView.width /2.0 - scrollView.contentOffset.x, self.indicatorView.y, self.indicatorView.width, self.indicatorView.height);
        }
    } else if(scrollView == self.bodyView) {
        if(self.bodyView.contentSize.width <= 0) {
            return;
        }
        _isNeedRefreshLayout = NO;
        if(!_isClick) {
            if(self.bodyView.contentOffset.x <= 0) { //左边界
                _leftItemIndex = 0;
                _rightItemIndex = 0;
            } else if(self.bodyView.contentOffset.x >= self.bodyView.contentSize.width - self.bodyView.width) { //右边界
                _leftItemIndex = _numberOfTabItems - 1;
                _rightItemIndex = _numberOfTabItems - 1;
            } else {
                _leftItemIndex = (int)(self.bodyView.contentOffset.x / self.bodyView.width);
                _rightItemIndex = _leftItemIndex + 1;
            }
        }
        [self changeTitleWithGradient]; // 改变字体的缩放
        if(_isClick) {
            [self changeIndicatorFrame];
        } else {
            [self changeIndicatorFrameByStretch];
        }
    }
}

#pragma mark - 顶部横线的动画

- (void)changeIndicatorFrame {
    
    NSInteger currentIndex = self.bodyView.contentOffset.x / self.bodyView.width;
    RMPageTitleView *tabItem = (RMPageTitleView *)_tabItems[currentIndex];
    CGFloat nowIndicatorCenterX = tabItem.centerX; //计算indicator此时的centerx
    CGFloat relativeLocation = (currentIndex - _leftItemIndex) / (_rightItemIndex - _leftItemIndex); //计算此时body的偏移量在一页中的占比

    if(_leftItemIndex == _rightItemIndex) {
        relativeLocation = 0;
    }
    self.indicatorView.frame = CGRectMake(nowIndicatorCenterX - _indicatorWidth / 2.0 - _topTitleScrollview.contentOffset.x, self.indicatorView.y, _indicatorWidth, self.indicatorView.height);
}


- (void)changeIndicatorFrameByStretch {
    
    if(_indicatorWidth <= 0) {
        return;
    }
    CGFloat relativeLocation = 1;
    if (_leftItemIndex == _rightItemIndex) {
        relativeLocation = 0;
    } else {
        relativeLocation = (self.bodyView.contentOffset.x / self.bodyView.width - _leftItemIndex) /(_rightItemIndex - _leftItemIndex);;
    }
    RMPageTitleView *leftTabItem = _tabItems[_leftItemIndex];
    RMPageTitleView *rightTabItem = _tabItems[_rightItemIndex];
    
    CGFloat leftwidthItem = [self getTitleWidth:leftTabItem.pageTitleLabel.text];
    CGFloat rightwidthItem = [self getTitleWidth:rightTabItem.pageTitleLabel.text];
    CGFloat widthItem = (leftwidthItem + rightwidthItem) / 2; // 左右item的宽度不同的时候，防止滑到第二个item的时候因宽度的不同indicatorWidth不一样长
    CGRect nowFrame = CGRectMake(0, self.indicatorView.y, 0, self.indicatorView.height);
    //计算宽度
    if(relativeLocation <= 0.5) {
        nowFrame.size.width = _indicatorWidth + widthItem * (relativeLocation / 0.5);
        nowFrame.origin.x = (leftTabItem.center.x - _topTitleScrollview.contentOffset.x) - _indicatorWidth / 2.0;
    } else {
        nowFrame.size.width = _indicatorWidth + widthItem * ((1 - relativeLocation) / 0.5);
        nowFrame.origin.x = (rightTabItem.center.x - _topTitleScrollview.contentOffset.x) + _indicatorWidth /2.0 - nowFrame.size.width;
    }
    self.indicatorView.frame = nowFrame;
}


#pragma mark - 顶部标题的动画

- (void)changeTitleWithGradient {
    
    if(_leftItemIndex != _rightItemIndex) {
        
        CGFloat rightScale = (self.bodyView.contentOffset.x / self.bodyView.width - _leftItemIndex) /(_rightItemIndex - _leftItemIndex);
        CGFloat leftScale = 1 - rightScale;
        
        RMPageTitleView *leftTabItem = _tabItems[_leftItemIndex];
        RMPageTitleView *rightTabItem = _tabItems[_rightItemIndex];
        
        if (leftScale > 0.5) {
            leftTabItem.pageTitleLabel.textColor = _selectedColor;
            rightTabItem.pageTitleLabel.textColor = _unSelectedColor;
        } else {
            leftTabItem.pageTitleLabel.textColor = _unSelectedColor;
            rightTabItem.pageTitleLabel.textColor = _selectedColor;
        }
        //字体渐变
        leftTabItem.pageTitleLabel.transform = CGAffineTransformMakeScale(_minScale + (1 - _minScale) * leftScale, _minScale + (1 - _minScale) * leftScale);
        rightTabItem.pageTitleLabel.transform = CGAffineTransformMakeScale(_minScale + (1 - _minScale) * rightScale, _minScale + (1 - _minScale) * rightScale);
    }
}

#pragma mark - 标题点击

- (void)changeChildControllerOnClick:(UITapGestureRecognizer *)tap {
    
    NSInteger nextIndex = [_tabItems indexOfObject:tap.view];
    if(nextIndex != _selectedTabIndex) {
        _isClick = YES;
        _topTitleScrollview.userInteractionEnabled = NO; //防止快速切换
        _leftItemIndex = nextIndex > _selectedTabIndex ? _selectedTabIndex:nextIndex;
        _rightItemIndex = nextIndex > _selectedTabIndex ? nextIndex:_selectedTabIndex;
        _selectedTabIndex = nextIndex;
        [self.bodyView setContentOffset:CGPointMake(self.frame.size.width * _selectedTabIndex, 0) animated:NO]; //关闭底部滚动的时候的动画
        [self reviseTabContentOffsetBySelectedIndex:YES];
        // 防止上面顶部的标签栏的标签数比较少的情况不滑动，手动掉一下完成设置的
        if (_topTitleScrollview.contentSize.width <= _topTitleScrollview.width) {
            [self finishReviseTabContentOffset];
        }
    } else {
        
        if ([self.delegate respondsToSelector:@selector(pageView:selectedTabIndex:)]) {
            [self.delegate pageView:self selectedTabIndex:_selectedTabIndex];
        }
    }
}


#pragma mark - 设置

- (void)setMinScale:(CGFloat)minScale {
    if(minScale > 0 && minScale <= 1) {
        _minScale = minScale;
        [self resetTabItemScale];
    }
}

- (void)setChildTitles:(NSArray *)childTitles {
    
    if (childTitles.count <= 0) {
        return; //数组为空时
    }
    _childTitles = childTitles;
    _numberOfTabItems = _childTitles.count; // 设置一页显示多少个
    [_tabItems removeAllObjects];
    [_topTitleScrollview.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RMPageTitleView class]]) {
            [obj removeFromSuperview]; // 去除标题视图上的标题
        }
    }];
    _isNeedRefreshLayout = YES;
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        RMPageTitleView *tabItem = [[RMPageTitleView alloc] init];
        tabItem.pageTitleLabel.font = _tabItemFont;
        tabItem.pageModel = _childTitles[i];
        tabItem.pageTitleLabel.textColor = i==_selectedTabIndex ? _selectedColor : _unSelectedColor;
        tabItem.userInteractionEnabled = YES;
        if (i == _selectedTabIndex) {
            tabItem.pageTitleLabel.transform = CGAffineTransformMakeScale(1.0,1.0);
        } else {
            tabItem.pageTitleLabel.transform = CGAffineTransformMakeScale(_minScale,_minScale);
        }
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeChildControllerOnClick:)];
        [tabItem addGestureRecognizer:tapRecognizer];
        [_tabItems addObject:tabItem];
        [_topTitleScrollview addSubview:tabItem];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setChildControllers:(NSArray *)childControllers {
    
    if (childControllers.count <= 0) {
        return;
    }
    _childControllers = childControllers;
    [self.bodyView reloadData];
    
}

- (void)setTabBackgroundColor:(UIColor *)tabBackgroundColor {
    
    _tabBackgroundColor = tabBackgroundColor;
    _topTitleScrollview.backgroundColor = _tabBackgroundColor;
}

- (void)setSelectedTabIndex:(NSInteger)selectedTabIndex {
    
    if(selectedTabIndex >= 0 && selectedTabIndex < _numberOfTabItems && _selectedTabIndex != selectedTabIndex) {
        [self changeSelectedItemToNextItem:selectedTabIndex];
        _selectedTabIndex = selectedTabIndex;
        _lastSelectedTabIndex = selectedTabIndex;
        [self layoutIndicatorView];
        self.bodyView.contentOffset = CGPointMake(self.width * _selectedTabIndex, 0);
        [self resetTabItemScale];
    }
}

- (void)setUnSelectedColor:(UIColor *)unSelectedColor {
    
    _unSelectedColor = unSelectedColor;
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        RMPageTitleView *tabItem = _tabItems[i];
        tabItem.pageTitleLabel.textColor = i ==_selectedTabIndex ? _selectedColor : _unSelectedColor;
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    
    _selectedColor = selectedColor;
    RMPageTitleView *tabItem = _tabItems[_selectedTabIndex];
    tabItem.pageTitleLabel.textColor = _selectedColor;
    self.indicatorView.backgroundColor = _selectedColor;
}

- (void)setTabItemFont:(UIFont *)tabItemFont {
    _tabItemFont = tabItemFont;
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        RMPageTitleView *tabItem = _tabItems[i];
        tabItem.pageTitleLabel.font = _tabItemFont;
    }
}

#pragma mark - 工具

- (CGFloat)getTitleWidth:(NSString *)title {
    
    UIFont *textFont = [UIFont systemFontOfSize:kTopTitleDefautFontSize] ? [UIFont systemFontOfSize:kTopTitleDefautFontSize] : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    CGFloat height = kTopTitleDefautHeight;
    textSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.width + 20);
}




@end
