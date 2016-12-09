//
//  ViewController.m
//  GCD_study
//
//  Created by tcan on 16/7/24.
//  Copyright © 2016年 tcan. All rights reserved.
//
// 是否开线程开同步函数（可以开线程）还是异步函数（不会开线程）
// 执行方式看队列


#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSArray *title_array;//标题数组
@property(nonatomic,strong) UIImageView *imgView;

@end

@implementation ViewController

/**
 *  标题数组
 */
- (NSArray *)title_array{
    
    if (_title_array == nil) {
        
        _title_array = [NSArray arrayWithObjects:
                        @"0.并发队列，异步函数",
                        @"1.串行队列，异步函数",
                        @"2.并发队列，同步函数",
                        @"3.串行队列，同步函数",
                        @"4.主队列，异步函数",
                        @"5.主队列，同步函数",
                        @"6.线程间通信",
                        @"7.栅栏函数",
                        @"8.延迟执行",
                        @"9.一次性代码",
                        @"10.快速迭代",
                        @"11.组队列",
                        nil];
    }
    return _title_array;
}

-(UIImageView *)imgView{
    
    if (_imgView == nil) {
        
        _imgView = [[UIImageView alloc]init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.userInteractionEnabled = YES;
    }
    return _imgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //设置界面
    [self setupView];
    
}

/**
 *  设置界面
 */
- (void)setupView{
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [self.view addSubview:tableView];
    
    self.imgView.frame = self.view.bounds;
    [self.view addSubview:self.imgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImgV)];
    [self.imgView addGestureRecognizer:tap];
    self.imgView.hidden = YES;
}

- (void)hideImgV{
    self.imgView.image = nil;
    self.imgView.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.title_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString  *cellId = @"gcdCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.title_array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    
    NSLog(@"%@",self.title_array[row]);
    
    switch (row) {
        case 0:
            //并发队列，异步函数
            [self asyncConcurrent];
            break;
        case 1:
            //串行队列，异步函数
            [self asyncSerial];
            break;
        case 2:
            //并发队列，同步函数
            [self syncConcurrent];
            break;
        case 3:
            //串行队列，同步函数
            [self syncSerial];
            break;
        case 4:
            //主队列，异步函数
            [self asyncMain];
            break;
        case 5:
            //主队列，同步函数
            [self syncMain];
            break;
        case 6:
            //线程间通信
            [self downloadImage];
            break;
        case 7:
            //栅栏函数
            [self barrier];
            break;
        case 8:
            //延迟执行
            [self delay];
            break;
        case 9:
            //一次性代码
            [self once];
            break;
        case 10:
            //快速迭代
            [self apply];
            break;
        case 11:
            //组队列
            [self group];
            break;
            
        default:
            break;
    }
}


/**
 *  线程间通信,开子线程下载图片，主线程刷新UI
 */
- (void)downloadImage{
    
    self.imgView.hidden = NO;
    
    //获取队列（并发）
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //异步函数
    dispatch_async(queue, ^{
        
        NSURL *url = [NSURL URLWithString:@"http://img3.imgtn.bdimg.com/it/u=3810730783,3518612718&fm=206&gp=0.jpg"];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        
        UIImage *img = [UIImage imageWithData:imgData];
        
        NSLog(@"下载线程---%@",[NSThread currentThread]);
        
        //主线程刷新ui
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self.imgView.image = img;
            NSLog(@"刷新UI线程,点击图片隐藏---%@",[NSThread currentThread]);
        });
    });
}

/**
 *  栅栏函数
 */
- (void)barrier{
    
    //创建一个并发队列，使用函数时不能用全局并发队列
    dispatch_queue_t queue = dispatch_queue_create("barrier", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i < 3; i++) {
            
            NSLog(@"%d--mission1--%@",i,[NSThread currentThread]);
        }
       
    });
    dispatch_async(queue, ^{
        
        for (int i = 0; i < 3; i++) {
            
            NSLog(@"%d--mission2--%@",i,[NSThread currentThread]);
        }
        
    });
    
    dispatch_barrier_async(queue, ^{
       
        NSLog(@"栅栏函数，把任务分隔开，控制前面的并发执行完，再执行栅栏函数，再执行后面的");
    });
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i < 3; i++) {
            
            NSLog(@"%d--mission3--%@",i,[NSThread currentThread]);
        }
        
    });
}

/**
 *  延迟执行
 */
- (void)delay{
    
    NSLog(@"两秒后会有打印");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSLog(@"延迟两秒后的打印");
    });
}

/**
 *  一次性代码
 */
- (void)once{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"只会执行一次，之后再调该方法不会继续进来打印");
    });
}

/**
 *  快速迭代
 */
- (void)apply{
    
    //创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("apply", DISPATCH_QUEUE_CONCURRENT);
    
    /**
     *  快速迭代
     *
     *  第一个参数    迭代的次数
     *  第二个参数    在哪个队列中执行
     *  第三个参数    block要执行的任务
     */
    dispatch_apply(10, queue, ^(size_t index) {
        
        NSLog(@"%zd -- %@",index,[NSThread currentThread]);
    });
}

/**
 *  队列组
 */
- (void)group{
    
    self.imgView.hidden = NO;
    
    __block UIImage *image1;
    __block UIImage *image2;
    //创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    //开子线程下载图片
    
    //创建队列(并发)
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //下载图片1
    dispatch_group_async(group, queue, ^{
        
        NSURL *url = [NSURL URLWithString:@"http://img3.imgtn.bdimg.com/it/u=3810730783,3518612718&fm=206&gp=0.jpg"];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        image1 = [UIImage imageWithData:imgData];
    });
    
    //下载图片2
    dispatch_group_async(group, queue, ^{
        
        NSURL *url = [NSURL URLWithString:@"http://www.027art.com/shaoer/UploadFiles_5898/201502/2015022407275494.jpg"];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        image2 = [UIImage imageWithData:imgData];
    });
    
    //合成
    dispatch_group_notify(group, queue, ^{
        
        //开启图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(300, 300));
        
        //画图1
        [image1 drawInRect:CGRectMake(0, 0, 300, 150)];
        
        //画图2
        [image2 drawInRect:CGRectMake(0, 100, 300, 150)];
        
        //根据图形上下文获得图片
        UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
        
        //关闭上下文
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imgView.image = image;
            NSLog(@"%@--刷新UI,点击图片隐藏",[NSThread currentThread]);
        });
        
    });
}


/**
 *  异步函数＋并发队列：会开新的线程（开多少，系统决定），任务并发执行
 */
- (void)asyncConcurrent{
    
    /**
     *  创建并发队列
     *
     *  第一个参数：C语言字符串，标签
     *  第二个参数：DISPATCH_QUEUE_CONCURRENT（并发队列）
     *            DISPATCH_QUEUE_SERIAL    （串行队列）
     *
     */
//    dispatch_queue_t queue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
    
    
    /**
     *  另一种较为常用的方法，直接获得全局并发队列
     *
     *  第一个参数：队列的优先级
     *  第二个参数：永远传0
     *
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"asyncConcurrent---start");
    //注：异步函数，会先打印了end
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission1--%@",[NSThread currentThread]);
    });
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission2--%@",[NSThread currentThread]);
    });
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission3--%@",[NSThread currentThread]);
    });
    
    NSLog(@"asyncConcurrent---end");
}

/**
 *  异步函数＋串行队列 会开启一条线程，任务串行执行
 */
- (void)asyncSerial{
    
    //创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission1--%@",[NSThread currentThread]);
    });
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission2--%@",[NSThread currentThread]);
    });
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission3--%@",[NSThread currentThread]);
    });
}

/**
 *  同步函数＋并发队列  不会开线程，任务串行执行
 */
- (void)syncConcurrent{
    
    //并发队列
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"syncConcurrent---start");
    
    //注：同步函数会马上执行，执行完再到打印end
    dispatch_sync(queue, ^{
        
        NSLog(@"mission1--%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        
        NSLog(@"mission2--%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        
        NSLog(@"mission3--%@",[NSThread currentThread]);
    });
    
    NSLog(@"syncConcurrent---end");
}

/**
 *  同步函数＋串行队列  不会开线程，任务串行执行
 */
- (void)syncSerial{
    
    //串行队列
    dispatch_queue_t queue = dispatch_queue_create("syncserial", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        
        NSLog(@"mission1--%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        
        NSLog(@"mission2--%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        
        NSLog(@"mission3--%@",[NSThread currentThread]);
    });
}

/**
 *  异步函数＋主队列：不会开线程，任务串行执行
 */
- (void)asyncMain{
    
    /**
     *  获得主队列
     *  主队列是GCD自带的一种特殊的串行队列
     *  放在主队列中的任务，都会放到主线程中执行
     */
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission1--%@",[NSThread currentThread]);
    });
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission2--%@",[NSThread currentThread]);
    });
    
    //异步函数
    dispatch_async(queue, ^{
        
        NSLog(@"mission3--%@",[NSThread currentThread]);
    });
}

//同步函数＋主队列：不会开线程，任务串行执行（若无新开线程执行该方法，该方法在主线程执行，会死锁）
- (void)syncMain{

    NSLog(@"会卡死，死锁");
    
    /**
     *  原因：syncMain方法和下面三个同步函数都在主线程中执行
     *       三个同步函数的执行需要等syncMain方法执行完，
     *       而syncMain方法执行完则需要里面的三个同步函数执行完，
     *       造成死锁。
     */
    
    //主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        
        NSLog(@"mission1--%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        
        NSLog(@"mission2--%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        
        NSLog(@"mission3--%@",[NSThread currentThread]);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
