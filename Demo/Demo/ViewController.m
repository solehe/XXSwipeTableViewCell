//
//  ViewController.m
//  Demo
//
//  Created by solehe on 2021/2/20.
//

#import "ViewController.h"
#import "CustomTableViewCell.h"

@interface ViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    XXSwipeTableViewCellDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
        
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell.textLabel setText:@"XXXXXXXXX"];
    [cell setSwipeDelegate:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - XXSwipeTableViewCellDelegate

- (void)swipeTableViewCell:(XXSwipeTableViewCell *)cell didClicked:(XXSwipeItemView *)swipeItemView {
    NSString *text = [(UIButton *)swipeItemView.customView titleLabel].text;
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:1];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"知道啦" style:0 handler:^(UIAlertAction *action) {
        [cell hiddenSwipeView];
    }]];
    [self presentViewController:alertVc animated:YES completion:nil];
}


@end
