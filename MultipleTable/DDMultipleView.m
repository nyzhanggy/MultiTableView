
#import "DDMultipleView.h"
#import "DDSegmentView.h"
#import "DDScrollView.h"

#define HoverOffset (CGRectGetHeight(_headerView.frame) - self.hoverOffset)

typedef NS_ENUM(NSInteger,ScrollDirection) {
    ScrollDirectionDefult = 0,
    ScrollDirectionLeft = -1,
    ScrollDirectionRight = 1

};

static NSString * const kDDMultipleViewContentOffset = @"contentOffset";

@interface DDMultipleView ()<UIScrollViewDelegate,DDSegmentViewDelegate,DDSegmentViewDataSource> {
    
    ScrollDirection _scrollDirection;
    CGFloat _beginDraggingX;
    
    UIView *_headerView;
    NSInteger _currentIndex;
    NSMutableArray *_tableViews;
    
    BOOL _isClickSegment;
    BOOL _isHover;
    BOOL _isScrolling;
    
    BOOL _isInit;
}
@property (nonatomic,strong) DDScrollView *scrollView;
@property (nonatomic,strong) DDSegmentView *segmentView;
@property (nonatomic, strong) UIView *headerContainerView;

@end

@implementation DDMultipleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        _currentIndex = 0;
        _isHover = NO;
        _scrollDirection = ScrollDirectionDefult;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self initView];
}

- (void)dealloc {
    for (NSInteger index = 0; index < _tableViews.count; index ++) {
        UITableView *subTableView = [_tableViews objectAtIndex:index];
        [subTableView removeObserver:self forKeyPath:kDDMultipleViewContentOffset];
    }
}

- (void)initView {
    if (_isInit) {
        return;
    }
    _isInit = YES;
    _headerView = [self.dataSources headerViewForMultipleView:self];
    
    [self.headerContainerView addSubview:_headerView];
    [self.headerContainerView addSubview:self.segmentView];
    
    _headerContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(_headerView.frame) + CGRectGetHeight(self.segmentView.frame));
    
    NSUInteger numberOfsection = [self.dataSources numberOfSectionsInMultipleView:self];
    _tableViews = [NSMutableArray array];
    for (NSInteger index = 0; index < numberOfsection; index ++) {
        UITableView *subTableView = [self.dataSources multipleView:self tableViewForSection:index];
        
        subTableView.frame = (CGRect){CGRectGetWidth(self.frame) * index,0,self.frame.size};
        [self.scrollView addSubview:subTableView];
        [_tableViews addObject:subTableView];
        
        [subTableView addObserver:self forKeyPath:kDDMultipleViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        UIView *tempHeaderView = [[UIView alloc] initWithFrame:_headerContainerView.bounds];
        subTableView.tableHeaderView = tempHeaderView;
        if (index == _currentIndex) {
            [subTableView.tableHeaderView addSubview:_headerContainerView];
        }
    }
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * _tableViews.count, CGRectGetHeight(_scrollView.frame));
    
    _scrollView.disableGestureView = _headerView;

}
#pragma mark - deleagte
#pragma mark ---SegmentViewDataSource
- (NSInteger)numberOfItemInSegment:(DDSegmentView *)segment {
    return [self.dataSources numberOfSectionsInMultipleView:self];
}
- (NSString *)segment:(DDSegmentView *)segment titleForIndex:(NSInteger)index {
    if ([self.dataSources respondsToSelector:@selector(multipleView:titleForSection:)]) {
        return [self.dataSources multipleView:self titleForSection:index];
    } else {
        if (index < _tiltleArray.count) {
            return _tiltleArray[index];
        }
    }
    return @"";
}

#pragma mark ---SegmentViewDelegate
- (void)segment:(DDSegmentView *)segment didSelectedIndex:(NSInteger)index {
    if (_isScrolling) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(multipleView:didSelectedSection:)]) {
        [self.delegate multipleView:self didSelectedSection:index];
    }
    _isClickSegment = YES;
    [self bringHeaderToFront];
    [self updateTableViewContentOffsetWithIndex:index];
    _currentIndex = index;
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView setContentOffset:CGPointMake(index * CGRectGetWidth(self.scrollView.frame), 0) animated:NO];
        _isScrolling = YES;
        segment.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
        [self bringHeaderToTableView];
        _isScrolling = NO;
        segment.userInteractionEnabled = YES;
    }];
    
    _scrollDirection = ScrollDirectionDefult;
}

#pragma mark ---UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isClickSegment = NO;
    if(scrollView.decelerating) {
        scrollView.scrollEnabled = NO; /*正在滚动的时候，把禁止滚动，防止从第一个直接跳到第三个或第四*/
    } else {
        _scrollDirection = ScrollDirectionDefult;
        _beginDraggingX = scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
       [self scrollViewDidEndScroll:scrollView];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScroll:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        _isScrolling = YES;
        [self bringHeaderToFront];
        if (_isClickSegment) {
            return;
        }
        if (scrollView.contentOffset.x < _beginDraggingX) {
            if (_scrollDirection != ScrollDirectionLeft) {
                _scrollDirection = ScrollDirectionLeft;
                NSInteger index = floor(_beginDraggingX/CGRectGetWidth(scrollView.frame));
                [self updateTableViewContentOffsetWithIndex:index -1];
            }
        } else if (scrollView.contentOffset.x > _beginDraggingX) {
            if (_scrollDirection != ScrollDirectionRight) {
                _scrollDirection = ScrollDirectionRight;
                NSInteger index = floor(_beginDraggingX/CGRectGetWidth(scrollView.frame));
                [self updateTableViewContentOffsetWithIndex:index + 1];
            }
        }
    }
}

- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView {
    _isScrolling = NO;
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(self.scrollView.frame);
    if (scrollView == self.scrollView) {
        [_segmentView changeIndex:_currentIndex];
    }
    _scrollDirection = ScrollDirectionDefult;
    scrollView.scrollEnabled = YES;
    [self bringHeaderToTableView];
    
}


#pragma mark - public
- (void)reloadHeaderView {
    [_headerView removeFromSuperview];

    _headerView = [self.dataSources headerViewForMultipleView:self];
    self.segmentView.frame = CGRectMake(0, CGRectGetHeight(_headerView.frame), CGRectGetWidth(self.frame), 44);
    
    CGFloat headerContainerViewHeight = CGRectGetHeight(_headerView.frame) + CGRectGetHeight(self.segmentView.frame);
    
    [self.headerContainerView addSubview:_headerView];
    for (NSInteger index = 0; index < _tableViews.count; index ++) {
        UITableView *subTableView = _tableViews[index];
        UIView *tempHeaderView = [[UIView alloc] initWithFrame:(CGRect){0,0,CGRectGetWidth(_headerContainerView.frame), headerContainerViewHeight}];
        subTableView.tableHeaderView = tempHeaderView;
    }
    if (_isHover) {
        _headerContainerView.frame = (CGRect){CGRectGetMinX(_headerContainerView.frame),-HoverOffset,CGRectGetWidth(_headerContainerView.frame),headerContainerViewHeight };
    } else {
        _headerContainerView.frame = (CGRect){_headerContainerView.frame.origin,CGRectGetWidth(_headerContainerView.frame), headerContainerViewHeight};
        UITableView *currentTable = _tableViews[_currentIndex];
        [currentTable.tableHeaderView addSubview:_headerContainerView];
        [currentTable reloadData];
    }
}



- (void)updateSectionTitleAtSection:(NSInteger)section {
    [_segmentView changeTitleAtIndex:section];
}

- (void)updateSectionTitle:(NSString *)title atSection:(NSInteger)section {
    [_segmentView changeTitle:title atIndex:section];
}
- (void)updateTableViewAtSection:(NSInteger)section {
    UITableView * updateTable = _tableViews[section];
    [updateTable reloadData];
    [self insertContentInsetForTableViewAtSection:section];
}
#pragma mark - events
- (void)bringHeaderToFront {
    if (![_headerContainerView.superview isEqual:self]) {
        CGRect converFrame = [_headerContainerView convertRect:_headerContainerView.frame toView:self];
        converFrame.origin = CGPointMake(0, CGRectGetMinY(converFrame));
        [_headerContainerView removeFromSuperview];
        _headerContainerView.frame = converFrame;
        [self addSubview:_headerContainerView];
    }
}

- (void)bringHeaderToTableView {
    UITableView *currentTableView = _tableViews[_currentIndex];
    if ([_headerContainerView.superview isEqual:self] && !_isHover) {
        [_headerContainerView removeFromSuperview];
        _headerContainerView.frame = (CGRect){0,0,_headerContainerView.frame.size};
        [currentTableView.tableHeaderView addSubview:_headerContainerView];
    }
}

- (void)updateTableViewContentOffsetWithIndex:(NSInteger)index {
    if (index < 0 || index >= _tableViews.count) {
        return;
    }

    UITableView *currentTableView = _tableViews[_currentIndex];
    UITableView *tableView = _tableViews[index];
    
    
    if (currentTableView.contentOffset.y < HoverOffset) {
        tableView.contentOffset = currentTableView.contentOffset;
    } else {
        if (tableView.contentOffset.y < HoverOffset) {
            tableView.contentOffset = CGPointMake(0, HoverOffset);
        }   
    }
    [self insertContentInsetForTableViewAtSection:index];
}

- (void)insertContentInsetForTableViewAtSection:(NSInteger)section{
    if (section >= _tableViews.count) {
        return;
    }
    UITableView * updateTable = _tableViews[section];
   
     if (updateTable.contentSize.height < self.scrollView.frame.size.height + HoverOffset) {
         updateTable.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame) + HoverOffset);
        
    }
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (_currentIndex >= _tableViews.count) {
        return;
    }
    UITableView *currentTableView = [_tableViews objectAtIndex:_currentIndex];
    if (object == currentTableView) {
        CGPoint contentOffset = [[change valueForKey:@"new"] CGPointValue];
        if (contentOffset.y >= HoverOffset) {
            if (![_headerContainerView.superview isEqual:self]) {
                [_headerContainerView removeFromSuperview];
                [self addSubview:_headerContainerView];
            }
            _isHover = YES;
            _headerContainerView.frame = CGRectMake(0, - HoverOffset, CGRectGetWidth(_segmentView.frame), CGRectGetHeight(_headerContainerView.frame));
        }  else {
            if ([_headerContainerView.superview isEqual:self]) {
                [_headerContainerView removeFromSuperview];
                [currentTableView.tableHeaderView addSubview:_headerContainerView];
             
            }
            _isHover = NO;
            _headerContainerView.frame = (CGRect){0,0,_headerContainerView.frame.size};
            
        }
    }
}

#pragma mark - setter and getter

- (DDScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[DDScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor lightGrayColor];
		_scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.clipsToBounds = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (DDSegmentView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[DDSegmentView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_headerView.frame), CGRectGetWidth(self.frame), 44)];
        _segmentView.backgroundColor = [UIColor whiteColor];
        _segmentView.normalColor = self.sectionNormalColor;
        _segmentView.selectedColor = self.sectionSelectedColor;
        _segmentView.delegate = self;
        _segmentView.dataSources = self;
    }
    return _segmentView;
}

- (UIView *)headerContainerView {
    if (!_headerContainerView) {
        _headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(_headerView.frame))];
        _headerContainerView.clipsToBounds = NO;
    }
    return _headerContainerView;
}
@end
