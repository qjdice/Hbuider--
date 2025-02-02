//
//  BLETableViewController.m
//  HBuilder-Hello
//
//  Created by hennychen on 10/14/16.
//  Copyright © 2016 DCloud. All rights reserved.
//

#import "BLETableViewController.h"

#import "SEPrinterManager.h"
#import "PluginTest.h"

@interface BLETableViewController ()
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)   NSArray<CBPeripheral *>              *deviceArray;  /**< 蓝牙设备个数 */
@end

@implementation BLETableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"未连接";

    // new一个SEPinter对象
    SEPrinterManager *_manager = [SEPrinterManager sharedInstance];
    [_manager startScanPerpheralTimeout:10 Success:^(NSArray<CBPeripheral *> *perpherals,BOOL isTimeout) {
        NSLog(@"-----%@",perpherals);
        
//
        self.deviceArray = perpherals;
        [self.tableView reloadData];
    } failure:^(SEScanError error) {
        NSLog(@"error:%ld",(long)error);
    }];
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"打印" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    if ([SEPrinterManager sharedInstance].connectedPerpheral) {
    //        self.title = [SEPrinterManager sharedInstance].connectedPerpheral.name;
    //    } else {
    //        [[SEPrinterManager sharedInstance] autoConnectLastPeripheralTimeout:10 completion:^(CBPeripheral *perpheral, NSError *error) {
    //            NSLog(@"自动重连返回");
    //            self.title = [SEPrinterManager sharedInstance].connectedPerpheral.name;
    // 因为自动重连后，特性还没扫描完，所以延迟一会开始写入数据
    //            [self performSelector:@selector(rightAction) withObject:nil afterDelay:1.0];
    //        }];
    //    }
}

- (HLPrinter *)getPrinter
{
    HLPrinter *printer = [[HLPrinter alloc] init];
    NSString *title = @"测试电商";
    NSString *str1 = @"测试电商服务中心(销售单)";
    [printer appendText:title alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
    [printer appendText:str1 alignment:HLTextAlignmentCenter];
    [printer appendBarCodeWithInfo:@"RN3456789012"];
    [printer appendSeperatorLine];
    
    [printer appendTitle:@"时间:" value:@"2016-04-27 10:01:50" valueOffset:150];
    [printer appendTitle:@"订单:" value:@"4000020160427100150" valueOffset:150];
    [printer appendText:@"地址:深圳市南山区学府路东深大店" alignment:HLTextAlignmentLeft];
    
    [printer appendSeperatorLine];
    [printer appendLeftText:@"商品" middleText:@"数量" rightText:@"单价" isTitle:YES];
    CGFloat total = 0.0;
    NSDictionary *dict1 = @{@"name":@"铅笔测试一下哈哈",@"amount":@"5",@"price":@"2.0"};
    NSDictionary *dict2 = @{@"name":@"abcdefghijfdf",@"amount":@"1",@"price":@"1.0"};
    NSDictionary *dict3 = @{@"name":@"abcde笔记本啊啊",@"amount":@"3",@"price":@"3.0"};
    NSArray *goodsArray = @[dict1, dict2, dict3];
    for (NSDictionary *dict in goodsArray) {
        [printer appendLeftText:dict[@"name"] middleText:dict[@"amount"] rightText:dict[@"price"] isTitle:NO];
        total += [dict[@"price"] floatValue] * [dict[@"amount"] intValue];
    }
    
    [printer appendSeperatorLine];
    NSString *totalStr = [NSString stringWithFormat:@"%.2f",total];
    [printer appendTitle:@"总计:" value:totalStr];
    [printer appendTitle:@"实收:" value:@"100.00"];
    NSString *leftStr = [NSString stringWithFormat:@"%.2f",100.00 - total];
    [printer appendTitle:@"找零:" value:leftStr];
    
    [printer appendSeperatorLine];
    
    [printer appendText:@"位图方式二维码" alignment:HLTextAlignmentCenter];
    [printer appendQRCodeWithInfo:@"www.baidu.com"];
    
    [printer appendSeperatorLine];
    [printer appendText:@"指令方式二维码" alignment:HLTextAlignmentCenter];
    [printer appendQRCodeWithInfo:@"www.baidu.com" size:10];
    
    [printer appendFooter:nil];
    [printer appendImage:[UIImage imageNamed:@"ico180"] alignment:HLTextAlignmentCenter maxWidth:300];
    
    // 你也可以利用UIWebView加载HTML小票的方式，这样可以在远程修改小票的样式和布局。
    // 注意点：需要等UIWebView加载完成后，再截取UIWebView的屏幕快照，然后利用添加图片的方法，加进printer
    // 截取屏幕快照，可以用UIWebView+UIImage中的catogery方法 - (UIImage *)imageForWebView
    
    return printer;
}

- (void)rightAction
{
    //方式一：
    HLPrinter *printer = [self getPrinter];
    
    NSData *mainData = [printer getFinalData];
    [[SEPrinterManager sharedInstance] sendPrintData:mainData completion:^(CBPeripheral *connectPerpheral, BOOL completion, NSString *error) {
        NSLog(@"写入结：%d---错误:%@",completion,error);
    }];
    
    //方式二：
    //    [_manager prepareForPrinter];
    //    [_manager appendText:title alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
    //    [_manager appendText:str1 alignment:HLTextAlignmentCenter];
    ////    [_manager appendBarCodeWithInfo:@"RN3456789012"];
    //    [_manager appendSeperatorLine];
    //
    //    [_manager appendTitle:@"时间:" value:@"2016-04-27 10:01:50" valueOffset:150];
    //    [_manager appendTitle:@"订单:" value:@"4000020160427100150" valueOffset:150];
    //    [_manager appendText:@"地址:深圳市南山区学府路东深大店" alignment:HLTextAlignmentLeft];
    //
    //    [_manager appendSeperatorLine];
    //    [_manager appendLeftText:@"商品" middleText:@"数量" rightText:@"单价" isTitle:YES];
    //    CGFloat total = 0.0;
    //    NSDictionary *dict1 = @{@"name":@"铅笔",@"amount":@"5",@"price":@"2.0"};
    //    NSDictionary *dict2 = @{@"name":@"橡皮",@"amount":@"1",@"price":@"1.0"};
    //    NSDictionary *dict3 = @{@"name":@"笔记本",@"amount":@"3",@"price":@"3.0"};
    //    NSArray *goodsArray = @[dict1, dict2, dict3];
    //    for (NSDictionary *dict in goodsArray) {
    //        [_manager appendLeftText:dict[@"name"] middleText:dict[@"amount"] rightText:dict[@"price"] isTitle:NO];
    //        total += [dict[@"price"] floatValue] * [dict[@"amount"] intValue];
    //    }
    //
    //    [_manager appendSeperatorLine];
    //    NSString *totalStr = [NSString stringWithFormat:@"%.2f",total];
    //    [_manager appendTitle:@"总计:" value:totalStr];
    //    [_manager appendTitle:@"实收:" value:@"100.00"];
    //    NSString *leftStr = [NSString stringWithFormat:@"%.2f",100.00 - total];
    //    [_manager appendTitle:@"找零:" value:leftStr];
    //
    //    [_manager appendFooter:nil];
    //
    ////    [_manager appendImage:[UIImage imageNamed:@"ico180"] alignment:HLTextAlignmentCenter maxWidth:300];
    //
    //    [_manager printWithResult:nil];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"deviceId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CBPeripheral *peripherral = [self.deviceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"名称:%@",peripherral.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *peripheral = [self.deviceArray objectAtIndex:indexPath.row];
    

    [[SEPrinterManager sharedInstance] connectPeripheral:peripheral completion:^(CBPeripheral *perpheral, NSError *error) {
        if (error) {
//            [SVProgressHUD showErrorWithStatus:@"连接失败"];
            NSLog(@"连接：%@",@"连接失败");
        } else {
            self.title = @"已连接";
//            [SVProgressHUD showSuccessWithStatus:@"连接成功"];
            NSLog(@"连接：%@",@"连接成功");
            [self closeview];
        }
    }];
    
}
-(void)closeview{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (void)dealloc {
//    [_tableView release];
//    [super dealloc];
//}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
