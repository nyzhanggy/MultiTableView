

#import "ViewController.h"
#import "DDMulipleView.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,DDMulipleViewDataSources,DDMulipleViewDelegate> {
	NSArray *_viewControllers;
    NSMutableArray *_titleArray;
    NSMutableArray *_viewsArray;
    
    UIView *_headerView;
    
    NSInteger _rowNumber;
}
	
@property (nonatomic,strong) DDMulipleView *mulipleView;

@end

@implementation ViewController
	
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _titleArray = [NSMutableArray arrayWithObjects:@"123",@"dsadadsadsa",@"33", nil];
    _rowNumber = 20;
	self.automaticallyAdjustsScrollViewInsets = NO;
    // 头视图
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
    _headerView.backgroundColor = [UIColor redColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_headerView.frame), 120)];
    label.text = @"多个tableview";
    label.textAlignment = NSTextAlignmentCenter;
    [_headerView addSubview:label];
    
    
    _viewsArray = [NSMutableArray array];
    
    // 内容视图 tableviews
    for (NSInteger index = 0; index < 3; index ++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mulipleView.frame), CGRectGetHeight(_mulipleView.frame)) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = index;
        [_viewsArray addObject:tableView];
        tableView.tableFooterView = [UIView new];
        if (index == 2) {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
        }
    }

	[self.view addSubview:self.mulipleView];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}
- (void)mulipleView:(DDMulipleView *)mulipleView didSelectedSection:(NSInteger)section {
    NSLog(@"%td",section);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view addSubview:self.mulipleView];
}
- (NSInteger)numberOfSectionsInMulipleView:(DDMulipleView *)mulipleView  {
    return _viewsArray.count;
}

- (UITableView *)mulipleView:(DDMulipleView *)mulipleView tableViewForSection:(NSInteger)section {
    return _viewsArray[section];
}
- (UIView *)headerViewForMulipleView:(DDMulipleView *)mulipleView {
    return _headerView;
}

- (DDMulipleView *)mulipleView {
	if (!_mulipleView) {
		_mulipleView = [[DDMulipleView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 20)];
        _mulipleView.dataSources = self;
        _mulipleView.delegate = self;
        _mulipleView.hoverOffset = 64;
        _mulipleView.tiltleArray = _titleArray;
        _mulipleView.sectionSelectedColor = [UIColor blueColor];
	}
	return _mulipleView;
}
	

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        return _rowNumber;
    }
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
    if (indexPath.row == 5) {
        cell.textLabel.text = @"增高头视图";

    } else if (indexPath.row == 4){
        cell.textLabel.text = @"减小头视图";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"增长 segment 标题";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"减短 segment 标题";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"增加 tableview 内容";
    } else if (indexPath.row == 0) {
        cell.textLabel.text = @"减少 tableview 内容";
    } else {
        cell.textLabel.text = @(indexPath.row + 100).stringValue;
    }

	return cell;
}
	
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        _headerView .frame = CGRectMake(0, 0, CGRectGetWidth(_mulipleView.frame), 400);
        [_mulipleView reloadHeaderView];
    } else if (indexPath.row == 4){
        _headerView .frame = CGRectMake(0, 0, CGRectGetWidth(_mulipleView.frame), 80);
        [_mulipleView reloadHeaderView];
    } else if (indexPath.row == 3) {
        
        [_mulipleView updateSectionTitle:@"3213213123" atSection:0];
        
    } else if (indexPath.row == 2) {
        [_mulipleView updateSectionTitle:@"111" atSection:0];
        
    } else if (indexPath.row == 1) {
        _rowNumber = 20;
        [_mulipleView updateTableViewAtSection:0];
    } else if (indexPath.row == 0) {
        _rowNumber = 2;
        [_mulipleView updateTableViewAtSection:0];
    }  else {
        [_mulipleView removeFromSuperview];
    }
    
    
    
}
	
@end
