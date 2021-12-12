//
//  ViewController.m
//  常驻线程
//
//  Created by 李文仲 on 2020/7/2.
//  Copyright © 2020 CLAY. All rights reserved.
//

#import "ViewController.h"
#import "LWZSingleton.h"
#import <objc/runtime.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <Masonry.h>

#import "UIButton+enlargeHitTest.h"
#import "ReactiveObjC.h"
#import "NSObject+RACKVOWrapper.h"
#import "SendActionBtn.h"

#import "AVFoundation/AVFoundation.h"

#import "MyThread.h"

#import <UIImageView+WebCache.h>

#import "AsyncView.h"

//Pet - Dog  验证+initialize相关
@interface Pet : NSObject

- (void)run;

@end

@implementation Pet

+ (void)initialize {
//    NSLog(@"%@ -- %s",self,__func__);
//    [self name];

//    if (self == [Pet class]) { //这样只会调用一次, 否则父类到子类都要调用一次
//        NSLog(@"%@ -- %s",self,__func__);
//        [self name];
//    }
}

- (void)run {
    NSLog(@"%@ run...",self);
}

+ (void)echo {
    [self name];
}

+ (void)name {
    NSLog(@"name:pet");
}

@end

@interface Dog : Pet

@end

@implementation Dog

//验证父类是否能调用子类imp  : 不能
+ (void)load {
    Method originMethod = class_getInstanceMethod(self, @selector(run));
    Method swizzleMethod = class_getInstanceMethod(self, @selector(x_run));
    method_exchangeImplementations(originMethod, swizzleMethod); //亲测崩溃 -[Pet x_run]: unrecognized selector sent to instance

//    BOOL didAddMethod = class_addMethod(self, @selector(run), method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
//    if (didAddMethod) {
//        class_replaceMethod(self, @selector(x_run), method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
//    } else {
//        method_exchangeImplementations(originMethod, swizzleMethod);
//    }
}

- (void)x_run {
    NSLog(@"------ Hook run --------");
    [self x_run];
}

////并没有改变结果
//+ (void)initialize {
//    NSLog(@"%@ ~~ %s",self,__func__);
//    [self name];
//}

+ (void)name {
    NSLog(@"name:dog");
}

@end


@interface ViewController ()
@property (nonatomic, strong) NSString *mark;
//@property (atomic, strong) NSString *mark;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, weak) NSString *poolStr;
@property (nonatomic, weak) NSArray *weakArr;
@property (nonatomic, weak) AFHTTPSessionManager *weakManager;

@property (nonatomic, strong) NSLock *testLock;
@property (nonatomic, strong) NSCondition *testCondition;
@property (nonatomic, strong) NSConditionLock *testConditionLock;
@property (nonatomic, strong) NSRecursiveLock *testRecursiveLock;

@end

NSString *mutexStr = @"";


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    //injectione的通知, 功能等价于 - (void)injected {方法.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureView) name:@"INJECTION_BUNDLE_NOTIFICATION" object:nil];

////#ifdef DEBUG //都可
//#if DEBUG
//    NSLog(@"debug");
//#else
//    NSLog(@"release");
//#endif

//    if (@available(iOS 13,*)) {
//
//    }

//    [self gcdAndThread]; //常驻线程
//    [self taggedPointer];
    [self singletonAndKVO]; //单例和KVO
//    [self pointer_and_object_test];
//    [self invocation_invoke_test]; //invocation的使用 performSelector返回值 方法转发
//    [self btn_hitTest]; //增加btn点击范围; 动态库注入injection;
//    [self some_stringTest]; //一些特殊字符串
//    [self AFN_test]; //AFN使用
//    [self sessionAbout]; //session使用
//    (void)self.masonryAbout; //masonry使用
//    [self operationTest]; //线程调用
//    [self mutexAndSpinLock]; //锁的实践 NSLock
//    [self RAC_test]; //RAC基本使用
//    [self sendActionBtn]; //按钮btn
//    [self gcd_barrier]; //gcd barrier
//    [self audioAndMovie]; //音视频
//    (void)self.aboutArray; //数组与copy/strong
//    UIColor *color = [UIColor performSelector:@selector(redColor)]; //isa应用. 类调用NSObject的实例方法
//    [self testPerformSel_returnType]; //测试performSel的返回值是否是id? 虽然写的是,但可能不是, 强行当id用还会崩溃
//    [self for_forin_enumerate]; //字典遍历3种方式
//    [self gcd_dispatch_semaphore]; //信号量 gcd锁 //信号量semaphore , +1 signal, -1 wait,  >=0都不阻塞
//    [self initializeAbout]; //+initialize 初始化方法相关
//    [self testMethodSwizzling]; //测试MethodSwizzling, 为什么非要判断 "origin方法在是在父类 而非当前类"
//    [self sdwebimage]; //SDWebImage框架解析

//    [self lock_and_condition_and_conditionLock]; //测试4种锁,nslock, nscondition, nsconditionlock, nsrecursivelock
//    [self testDrawRect];
//    [self testOffScreenRender]; // 离屏渲染, 圆角测试
}

- (void)testOffScreenRender {
    UIImage *img = [UIImage imageNamed:@"test2"];

    //不会
    //只有单背景的圆角渲染
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(50, 100, 50, 50);
    btn1.backgroundColor = UIColor.blueColor;
    btn1.layer.cornerRadius = 25;
    btn1.clipsToBounds = YES;
    [self.view addSubview:btn1];

    //会
    //虽然单图片, 但是或许因为还有背景 虽然没上色,  还有titleLabel 虽然没设置... 我猜的, 反正不如imageview优化好
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(50, 275, 50, 50);
//    btn1.backgroundColor = UIColor.blueColor;
    [btn2 setBackgroundImage:img forState:UIControlStateNormal];
    btn2.layer.cornerRadius = 25;
    btn2.clipsToBounds = YES;
    [self.view addSubview:btn2];

    //不会
    //单UIImageView的图片圆角 不会 (优化过)
    UIImageView *v1 = [[UIImageView alloc] initWithImage:img];
    v1.frame = CGRectMake(50, 340, 50, 50);
    v1.layer.cornerRadius = 25;
    v1.clipsToBounds = YES;
    [self.view addSubview:v1];

    //会
    //除了图片. 还有背景色,  渲染多个圆角, 依然会离屏
    UIImageView *v2 = [[UIImageView alloc] initWithImage:img];
    v2.backgroundColor = UIColor.blueColor;
    v2.frame = CGRectMake(50, 400, 50, 50);
    v2.layer.cornerRadius = 25;
    v2.clipsToBounds = YES;
    [self.view addSubview:v2];


}

- (void)testDrawRect {
    AsyncView *v = [AsyncView new];
    v.frame = self.view.bounds;
    [self.view addSubview:v];
}

- (void)lock_and_condition_and_conditionLock {
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(50, 100, 80, 50)];
    [self.view addSubview:s];

    _testLock = [NSLock new];
    _testCondition = [NSCondition new];
    _testConditionLock = [NSConditionLock new];
    _testRecursiveLock = [NSRecursiveLock new];

//    //NSLock
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"testlock1");
//        [self test_lock];
//        [self test_lock];
////        [self test_lock2];
//    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"testlock2");
//        [self test_lock];
//    });
    //try timeout
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self test_try_lock];
//        [self test_try_lock];
//    });


//    //递归锁
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self test_recursive_lock];
//        [self test_recursive_lock2];
//    });

//    //条件锁
//    //condition
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self test_condition];
//    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self test_condition2];
//    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self test_condition_not_mutex];
//        [self test_condition_not_mutex];
//    });


    //condition lock
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self test_condition_lock];
//        [self test_condition_lock2];
//    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self test_condition_lock3];
//    });

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self test_condition_lock_is_mutex];
//        [self test_condition_lock_is_mutex];
//    });
}

- (void)test_condition_lock {
    [_testConditionLock lock];
    NSLog(@"开始执行 test_condition_lock1...");
    [_testConditionLock unlockWithCondition:2];
}

- (void)test_condition_lock2 {
    [_testConditionLock lockWhenCondition:1]; // 若在主线程, 此方法因为cond而得不到锁, 则会卡死在这. lock3方法不会去执行
    NSLog(@"开始执行 test_condition_lock2...");
    [_testConditionLock unlockWithCondition:2];
}

- (void)test_condition_lock3 {
    [_testConditionLock lockWhenCondition:2];
    NSLog(@"开始执行 test_condition_lock3...");
    [_testConditionLock unlockWithCondition:1];
}

- (void)test_condition_lock_is_mutex {
    [_testConditionLock lock];
    NSLog(@"开始执行 test_condition_not_mutex...");
    sleep(3);
    [_testConditionLock unlock];
}

- (void)test_condition {
    [_testCondition lock];
    NSLog(@"开始执行 test_condition1...");
    [_testCondition wait]; //之后的不会执行, 除非被_testCondition对象被唤醒 signal
    NSLog(@"condition 等待1");
    [_testCondition unlock];
}

- (void)test_condition2 {
    [_testCondition lock]; //这个可以在没有锁的情况下, 得到锁(lock) .
//    [_testCondition signal];
    NSLog(@"开始执行 test_condition2...");
//    [_testCondition wait]; //之后的不会执行, 除非被_testCondition对象被唤醒 signal
//    NSLog(@"condition 等待2");
    [_testCondition unlock];
}

- (void)test_condition_not_mutex {
    [_testCondition lock]; //这个可以在没有锁的情况下, 得到锁(lock) . 现在测试又互斥锁了...
    NSLog(@"开始执行 test_condition_not_mutex...");
    sleep(3);
    [_testCondition wait];
    [_testCondition unlock];
}

- (void)test_lock {
    [_testLock lock];
    NSLog(@"开始执行 test lock...");
//    [_testLock lock];  //会直接永远卡在这
//    NSLog(@"开始执行 递归锁...");
//    [_testLock unlock];

    sleep(3);
    [_testLock unlock];
}


- (void)test_try_lock {
    NSDate *date = [NSDate date];
    [date dateByAddingTimeInterval:1];
    [_testLock lockBeforeDate:date]; //和trylock一样, 并不会无视锁, 只是返回是否获得锁成功
    NSLog(@"开始执行 test_try_lock...");
    sleep(5);
    [_testLock unlock];
}

- (void)test_lock2 {
    [_testLock lock];
    NSLog(@"开始执行 test lock2...");
    sleep(3);
    [_testLock unlock];
}

- (void)test_recursive_lock {
    [_testRecursiveLock lock];
    NSLog(@"开始执行 test test_recursive_lock...");
//    [_testRecursiveLock lock];
//    NSLog(@"开始执行 递归 test_recursive_lock...");
//    [_testRecursiveLock unlock];
    sleep(3);
    [_testRecursiveLock unlock];
}

- (void)test_recursive_lock2 {
    [_testRecursiveLock lock]; //若_testRecursiveLock被用了, 还没归还unlock. 则此处卡主 无法lock.
    NSLog(@"开始执行 test test_recursive_lock2...");
    [_testRecursiveLock unlock];
}


- (void)sdwebimage {
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    NSString *urlString = @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi0.hdslb.com%2Fbfs%2Farticle%2F44715554d10b95e00e4029a79aecda869b0383e1.jpg&refer=http%3A%2F%2Fi0.hdslb.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1630401067&t=5d42a27fe95547fcd4fa1c212f633576";
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
}

- (void)testMethodSwizzling {
    Dog *dog = [Dog new];
    [dog run];
    Pet *pet = [Pet new];
    [pet run];
}


- (void)initializeAbout {

    __unused Dog *dog = [[Dog alloc] init];
    __unused Dog *dog2 = [[Dog alloc] init];

//    Pet *pet = [[Pet alloc] init];
//    Pet *pet2 = [[Pet alloc] init];

//    //那应该就是+initialize方法特殊了. 其调用从父类到子类都调用, 并且receiver也会从父类到子类
//    [Dog echo];
}


//static dispatch_semaphore_t semap;
- (void)gcd_dispatch_semaphore {  //信号量semaphore , +1 signal, -1 wait,  >=0都不阻塞
//    dispatch_semaphore_t semap = dispatch_semaphore_create(1);//会崩溃, 应该是局部变量释放了  在block造成野指针问题.  使用全局变量保证semap始终存在, 或者静态局部估计也行.
    static dispatch_semaphore_t semap;
    semap = dispatch_semaphore_create(0);
    NSLog(@"start");
//    long ret =  dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);//wait 没锁住返回0, 若锁住了则返回非0
    long ret =  dispatch_semaphore_wait(semap, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
    NSLog(@"%li",ret);
//    NSLog(@"0"); //semaphore = 0时, 打印

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"queue");
        dispatch_semaphore_signal(semap);
    });
    
    dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);
    NSLog(@"-1");


}

- (void)for_forin_enumerate {
    NSDictionary *dic = @{@"1":@"one",@"2":@"two",@"3":@"three"};

    //1.
    NSArray *keys = dic.allKeys;
    for (int i = 0; i<dic.count; i++) {
        NSLog(@"%@ - %@",keys[i],dic[keys[i]]);
    }

    //2.
    for (id key in dic) {
        NSLog(@"%@ - %@",key,dic[key]);
    }

    //3.
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"%@ - %@",key,obj);
        *stop = YES;
    }];
}

- (void)testPerformSel_returnType {
        //测试performSel的返回值是否是id? 虽然写的是,但可能不是, 强行当id用还会崩溃
        [self performSelector:@selector(fooo)];
    //    NSLog(@"performSel return value = %@",i);
}

- (int)fooo{
    return 3;
}

- (void)aboutArray {
    NSArray *arr = [NSArray array];
    NSLog(@"1 arr= %@",arr);
    NSMutableArray *mArr = [NSMutableArray arrayWithObjects:@1, nil];

    arr = mArr;
    NSLog(@"2 arr= %@",arr);

    [mArr addObject:@2];
    NSLog(@"3 arr= %@",arr);
}

- (void)audioAndMovie {
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (void)gcd_barrier {
    dispatch_queue_t q = dispatch_queue_create("barrier_conc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(q, ^{
        NSLog(@"任务1");
        sleep(2);
    });
    dispatch_async(q, ^{
        NSLog(@"任务2");
        sleep(2);
    });
    dispatch_barrier_async(q, ^{  //一旦加入, 栅栏就形成了.  前面未执行完的继续执行, 后面的要等栅栏执行完毕.
        NSLog(@"barrier 执行!");
        sleep(2);
    });
    dispatch_async(q, ^{
        NSLog(@"任务3");
    });
}

- (void)sendActionBtn {
    SendActionBtn *btn = [[SendActionBtn alloc] initWithFrame:CGRectMake(80, 200, 50, 50)];
    btn.backgroundColor = UIColor.yellowColor;
    [btn addTarget:self action:@selector(sendAct) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)sendAct {
    NSLog(@"sendAct!!");
}

- (void)injected {
    NSLog(@"i've been injected: %@",self);
    [self configureView];
}

- (void)configureView {
    NSLog(@"configureView");
    UIView *v = [UIView new];
    v.frame = CGRectMake(100, 300, 30, 30);
    v.backgroundColor = UIColor.blueColor;
    [self.view addSubview:v];
    [self viewDidLoad]; //... 反正能改btn_hitTest方法的view颜色
}

- (void)RAC_test {
    //1.创建信号, 信号有容量为1的可变数组
    RACSubject *subject = [RACSubject subject];
    //2.订阅信号 方法里有创建订阅者 订阅者保存了block动作, 信号的数组保存了订阅者
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"execute-> %@",x);
    }];
    //3.发送信号  回调动作block
    [subject sendNext:@"lwz"];


    //把任何都可以包装成信号, 并subscribeNext: 传入block. 返回的RACDisposable可以取消订阅.
    //rac皆为block形式, 在哪订阅在哪写代码.
    //按钮点击
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"tap!! %@",x);
        btn.frame = CGRectMake(10, 10, 30, 40);
    }];
    btn.backgroundColor = UIColor.redColor;
    btn.frame = CGRectMake(50, 50, 50, 30);
    [self.view addSubview:btn];

    //方法调用
    [[self rac_signalForSelector:@selector(rac_sel:)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"rac监听参数:%@",x);
    }];
    [self rac_sel:@"哦吼"];//一个方法的调用,其他类的方法也都可以

    //kvo / 属性
    //"NSObject+RACKVOWrapper.h" 的方法, 保留系统kvo风格, 但是啰嗦
    [btn rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        NSLog(@"btn frame 被set了!");
    }];

    //直接观察键值
    RACDisposable *disposable = [[btn rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id  _Nullable x) {
        NSLog(@"btn frame 被set了!");
    }];
    [disposable dispose]; //可以取消掉监听

    //RAC宏
    [RACObserve(btn, frame) subscribeNext:^(id  _Nullable x) {
        NSLog(@"btn frame 被set了!");
    }];


    //通知
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    field.backgroundColor = [UIColor grayColor];
    field.placeholder = @"在此输入";
    [self.view addSubview:field];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"键盘要弹出啦!");
    }];

    //监听文本框 textField
    [field.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"内容为: %@",x);
    }];

    //定时器
    [[RACSignal interval:1.0 onScheduler:[RACScheduler scheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"%@ --timer-- %@",x,[NSThread currentThread]);  //common mode, 子线程, x返回的时间
    }];

    //combineLatest
//    RACSubject *s1 = [RACSubject subject];
//    RACSubject *s2 = [RACSubject subject];
//    [RACSignal combineLatest:@[s1,s2] reduce:^id _Nonnull{
//        <#code#>
//    }]
}

- (void)rac_sel:(NSString *)str {

}

- (void)mutexAndSpinLock {
//    self.lock = [[NSRecursiveLock alloc] init];  //递归锁 可嵌套lock
    self.lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self changeMutexStr:@"1"];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self changeMutexStr:@"2"];
    });

    NSLog(@"end");
}

- (void)changeMutexStr:(NSString *)str {
//    @synchronized (self) {
//        sleep(2);
//        NSLog(@"sleep");
//        mutexStr = str;
//    }


//    self.lock = [[NSLock alloc] init];  //这样多线程进来调用,不是同一把锁 lock无效
    [_lock lock];
//    [_lock lock]; //非递归锁  不可嵌套lock
    NSLog(@"mutex: %@",str);
    sleep(2);
    NSLog(@"sleep");
//    [_lock unlock];
    [_lock unlock];

}



- (void)operationTest {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //default1 -1不限制, 1串行, >1 并行.
    queue.maxConcurrentOperationCount = -1;
    [queue addOperationWithBlock:^{
        NSLog(@"addOperationWithBlock! ");
    }];

    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(btnAction) object:nil];
//    [invocationOperation start];

    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation!");
    }];
//    [blockOperation start];
    [invocationOperation addDependency:blockOperation];
    [queue addOperation:invocationOperation];
    [queue addOperation:blockOperation];

}

- (void)masonryAbout {
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.blueColor;
    [self.view addSubview:view];
    NSArray *constraints = [view mas_makeConstraints:^(MASConstraintMaker *make) {
        //maker.height返回MASViewConstraint, make.height.width返回MASCompositeConstraint.
//        make.height.mas_equalTo(30);
        make.height.width.mas_equalTo(60);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
    NSLog(@"%@",constraints);
//2020-11-13 15:54:52.204099+0800 常驻线程[34274:63261770] (
//    "<MASCompositeConstraint: 0x6000032f0e70>",
//    "<MASViewConstraint: 0x6000018afd80>",
//    "<MASViewConstraint: 0x6000018afde0>"
//)



//    //block是否可以修改形参, 这里本就是引用/指针, 有何不可改.
//    NSMutableString *str = [NSMutableString stringWithString:@"哈"];
//    NSLog(@"%@",str);
//    void (^block)(NSMutableString *) = ^(NSMutableString *s){
//        [s appendString:@"喽"];
//    };
//    block(str);
//    NSLog(@"%@",str);
////    2020-11-12 14:26:40.287432+0800 常驻线程[31372:63019234] 哈
////    2020-11-12 14:26:40.287613+0800 常驻线程[31372:63019234] 哈喽
//    int i = 1;
//    NSLog(@"%i",i);
//    void (^block2)(int a) = ^(int a) {
//        a += 100;
//    };
//    block2(i);
//    NSLog(@"%i",i);
////    2020-11-12 14:31:35.475151+0800 常驻线程[31417:63026675] 1
////    2020-11-12 14:31:35.475245+0800 常驻线程[31417:63026675] 1

}

//网络相关
- (void)sessionAbout {
    //stringByAddingPercentEncodingWithAllowedCharacters 网络请求url编码,只有汉字需要被额外percent编码
    //还原是 [str stringByRemovingPercentEncoding:]
    NSString *str1 = @"233xyz";
    NSString *str2 = @"233xyz哈喽";
    NSLog(@"str1 percent convert = %@",[str1 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
    NSLog(@"str2 percent convert = %@",[str2 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
//    2020-11-11 14:57:16.612902+0800 常驻线程[28995:62770842] str1 percent convert = 233xyz
//    2020-11-11 14:57:16.613095+0800 常驻线程[28995:62770842] str2 percent convert = 233xyz%E5%93%88%E5%96%BD


    //加载网络图片
    NSString *urlStr = @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3670756122,3973698678&fm=26&gp=0.jpg";
    //imageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 300, 500)];
    imageView.backgroundColor = UIColor.blackColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];

    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //NSURLSessionTask的子类之一, dataTask.
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error = %@",error);
        } else {
            //success
            NSLog(@"data = %@",data);
            NSLog(@"thread = %@",NSThread.currentThread);
            dispatch_async(dispatch_get_main_queue(), ^{ //UI刷新必须在主线程
                imageView.image = [UIImage imageWithData:data];
            });
        }
    }];
    //resume
    [dataTask resume];

}

- (void)gcdAndThread {
    __unused dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    MyThread *thread = [[MyThread alloc] initWithTarget:self selector:@selector(threadElse) object:nil];
    thread.name = @"my private thread";
    [thread start];

//    常驻线程
//    [NSThread detachNewThreadSelector:@selector(threadElse) toTarget:self withObject:nil]; //detach则不需要start
//
//    [self performSelector:@selector(threadElse) onThread:thread withObject:nil waitUntilDone:YES];
}

- (void)singletonAndKVO {
    //单例 signleton
    LWZSingleton *sigleton = [[LWZSingleton alloc] init];
    LWZSingleton *singleton2 = [LWZSingleton shareSingleton]; //地址一样
    NSLog(@"%@\n%@",sigleton,singleton2);
    [LWZSingleton tearDown];
    LWZSingleton *singleton3 = [LWZSingleton shareSingleton]; //新单例出现
    NSLog(@"%@\n%@\n%@",sigleton,singleton2,singleton3);

    //kvo
    LWZSingleton *singleton = [LWZSingleton shareSingleton];
    [singleton addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:@"haha"];
    singleton.age = 2;

//    //kvo触发唯一条件, 这两个缺一不可
//    [singleton willChangeValueForKey:@"age"];
//    [singleton didChangeValueForKey:@"age"];

//    [singleton performSelector:@selector(changeAge)];

//    [singleton setValue:@123 forKey:@"height"]; //若未调用set方法,只是修改成员变量,不会触发kvo
}

- (void)pointer_and_object_test {
    //对象与指针, 赋值
    NSString *s1 = @"2333";
    NSString *s2 = s1; //赋值操作, s2 s1指针内容一致, 均指向@"2333"这块内存
    s1 = nil; //只是清空s1指针, s2指针依然指向@"2333"这个对象 这块内存数据.
    NSLog(@"s1=%@,\ns2=%@",s1,s2);


    //    //autoreleasepool
    ////    NSString *poolstr = [NSString stringWithFormat:@"poolstr"]; //字符常量区,始终存在
    //    NSString *poolstr = [NSString stringWithFormat:@"poolstrfsdafas"]; //正常字符对象,再堆区. 故runloop之外的DidAppear poolstr对象已经被释放掉; 而WillAppear虽然计数为0 但是他和viewDidLoad在一个runloop还没到beforeWaiting还没被释放
    //    _poolStr = poolstr;

    //    _poolStr = [NSString stringWithFormat:@"poolstrfsdafas"];
    //    NSLog(@"load --- %@",_poolStr);

    //    @autoreleasepool { //里面的对象内存会在}后直接计算并决定释放
    //        NSString *poolstr = [NSString stringWithFormat:@"poolstrfsdafas"];
    //        _poolStr = poolstr;
    //    }
    //
    //    NSLog(@"load --- %@",_poolStr); //null 都是null

    //非autorelease对象 出}直接销毁了,因为和autoreleasePool无关,故也和runloop无关
    NSArray *weakArr = [[NSArray alloc] initWithObjects:@"haha", nil];
    _weakArr= weakArr;
    NSLog(@"_weakArr= %@",_weakArr);

    //    NSString *s1 = [NSString stringWithFormat:@"1"]; //NSTaggedPointerString
    //    NSString *s2 = [NSString stringWithFormat:@"poolstr"]; //NSTaggedPointerString
    //    NSString *s3 = [NSString stringWithFormat:@"1sadfadsfsfsdfds"]; //__NSCFString
    //    NSLog(@"%@\n%@\n%@",s1,s2,s3);
}

- (void)invocation_invoke_test {
    //invocation invoke
    NSString *str = @"我的调用";
    __unused NSMethodSignature *signature = [ViewController instanceMethodSignatureForSelector:@selector(wz_nslog:)];
//    NSMethodSignature *s = [NSMethodSignature methodSignatureForSelector:@selector(wz_nslog:)]; // s=nil 下一步崩溃.
    NSMethodSignature *s = [NSMethodSignature signatureWithObjCTypes:"v@:@"]; // 这个可以
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:s]; //ObjCTypes = @"v@:@" void self对象 _cmd id对象
//    invocation.target = self;
    invocation.selector = @selector(wz_nslog:);
    [invocation setArgument:&str atIndex:2];
    [invocation invokeWithTarget:self];

    //消息转发 _msg_forwarding
//    [self performSelector:@selector(foo)];

    //测试- (id)performSelector: , 调用返回值非id类型, 是否有返回值.
    BOOL b = [self performSelector:@selector(testReturnTypeOfPerformSel)];
    NSLog(@"BOOL = %i",b);
    //NSLog(@"BOOL = %@",[self performSelector:@selector(testReturnTypeOfPerformSel)]); //会崩溃


    //有返回值的invocation
    NSLog(@"------测试-----有返回值的invocation------");
//    NSMethodSignature *ss = [NSMethodSignature methodSignatureForSelector:@selector(invocationRetype:)]; //崩溃 因为ss返回为nil.
    //methodSignatureForSelector: 是去找sel, 必须指明对象, 才能根据isa找到对应的方法!
    NSMethodSignature *ss = [self methodSignatureForSelector:@selector(invocationRetype:)];
    const char *returnType = ss.methodReturnType;
    if (strcmp(returnType, @encode(NSInteger)) == 0) {
        NSLog(@"类型为:%s",returnType);

        NSInvocation *ii = [NSInvocation invocationWithMethodSignature:ss];
        [ii setSelector:@selector(invocationRetype:)];
        [ii setTarget:self];
        NSInteger integer = 123;
        [ii setArgument:&integer atIndex:2];
        [ii invoke];
        NSInteger returnValue = 0;
        [ii getReturnValue:&returnValue];
        NSLog(@"getReturnValue: %li",returnValue);
    } else {
        NSLog(@"类型不对! 不是NSInteger!");
    }
}

- (NSInteger)invocationRetype:(NSInteger)x {
    NSLog(@"invocationRetype!");
    return x;
}

- (NSInteger)testReturnTypeOfPerformSel {
    NSLog(@"testReturnTypeOfPerformSel!");
    return 233;
}

- (void)decimal_number {
    //防止精度丢失
    NSString *num = @"1";
    NSLog(@"%li",num.integerValue);
    NSLog(@"%lf",num.floatValue);
    NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:num];
    NSLog(@"%lf",decimalNum.floatValue);
}

- (void)btn_hitTest {
    //测试injection
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 400, 400, 50)];
    label.textColor = UIColor.redColor;
    label.text = @"圣诞节发了肯定是gggg";
    [self.view addSubview:label];

    //uiview
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.yellowColor;
    view.frame = CGRectMake(20, 20, 300, 300);
    [self.view addSubview:view];

    //UIButton+enlargeHitTest 扩大按钮点击范围
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.userInteractionEnabled = NO;
    [btn setBackgroundImage:[UIImage imageNamed:@"IMG_4989"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 50, 80);
    [view addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [btn setEnlargeEdge:50];
//    btn.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"ffdasfsafasfasfafdsfaasdssef"];
}

- (void)some_stringTest {

//    NSLog(@"\\"); //转义字符\
//    NSNumber *num1 = [[NSNumber alloc] initWithInt:1];
//    NSNumber *num2 = @2;
//    NSNumber *num3 = [NSNumber numberWithInt:1];
//    NSString *s1 = @"1";
//    NSString *s2 = [NSString stringWithFormat:@"%li",12];
}


- (void)AFN_test {
//    NSLog(@"caches path:\n%@",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES));
    //AFN
    NSString *urlStr = @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3670756122,3973698678&fm=26&gp=0.jpg";

//    NSString *ssl_str = @"https://www.baidu.com/s?wd=ios&rsv_spt=1&rsv_iqid=0xc60716730000179c&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&rqlang=cn&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_btype=t&inputT=810&rsv_t=4cd8T9fffLAqYmzGhdU2oAuktuZga89Ylltj21G8bhMs6xyk6Y8c9xaHiT0SWnamNdtW&oq=ios%2520uuid&rsv_pq=a515c4200001bd76&rsv_sug3=20&rsv_sug1=15&rsv_sug7=100&rsv_sug2=0&rsv_sug4=810";

    //imageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 300, 500)];
    imageView.backgroundColor = UIColor.blackColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
//    [imageView setImageWithURL:[NSURL URLWithString:urlStr]]; //相比httpManager一步就可以.

    //manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //默认是json(键值对字符串), 我们是图片数据 所以要设置下
//    [manager GET:ssl_str parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
//
    [manager GET:urlStr parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"progress = %@",downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"response = %@\nresponseObject = %@",task, responseObject);
        NSLog(@"thread: %@",NSThread.currentThread);
        imageView.image = [UIImage imageWithData:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];

    //测试manager生命周期  - 关键是其被session强引用, 导致相互引用
    _weakManager = manager;
    [self performSelector:@selector(invalidAFNManager) withObject:nil afterDelay:5];



//    manager.completionQueue = dispatch_get_global_queue(0, 0);//默认从主队列回调
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"image/jpeg", nil];
    //有很多这种block, set方法, 把繁琐的代理设置成block. 很方便用户去使用.
//    [manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
//
//    }];

    //https证书验证的代理方法 block()
//    [manager setAuthenticationChallengeHandler:^id _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, void (^ _Nonnull completionHandler)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable)) {
//        <#code#>
//    }];

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [manager GET:urlStr parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//            NSLog(@"progress = %@",downloadProgress);
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"response = %@\nresponseObject = %@",task, responseObject);
//            NSLog(@"thread: %@",NSThread.currentThread);
//            imageView.image = [UIImage imageWithData:responseObject];
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"error = %@",error);
//        }];
//    });


        /*
         typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
             AFNetworkReachabilityStatusUnknown          = -1,
             AFNetworkReachabilityStatusNotReachable     = 0,
             AFNetworkReachabilityStatusReachableViaWWAN = 1,
             AFNetworkReachabilityStatusReachableViaWiFi = 2,
         };

         */
    //    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];





//    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        switch (status) {
//            case AFNetworkReachabilityStatusUnknown:
//                NSLog(@"未知网络~");
//                break;
//            case AFNetworkReachabilityStatusNotReachable:
//                NSLog(@"无网络~");
//                break;
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//                NSLog(@"使用数据网络~");
//                break;
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//                NSLog(@"使用wifi~");
//                break;
//            default:
//                break;
//        }
//    }];
//    //开始监控
//    [manager.reachabilityManager startMonitoring];
}

- (void)invalidAFNManager {
    [_weakManager invalidateSessionCancelingTasks:YES resetSession:NO];
}


- (void)btnAction {
    NSLog(@"btnAction!!!");
}

//消息转发 _msg_forwarding
+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(foo)) {
//        class_addMethod(self, @selector(foo), msg_forwarding, "v@:"); // v-void   @-self   :-_cmd
//        return YES;
//    }
//    class_replaceMethod(<#Class  _Nullable __unsafe_unretained cls#>, <#SEL  _Nonnull name#>, <#IMP  _Nonnull imp#>, <#const char * _Nullable types#>)
    return [super resolveInstanceMethod:sel];
}

//把消息receiver移交给其他对象
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return  [super forwardingTargetForSelector:aSelector];
}

//只要返回了 NSMethodSignature, 这个方法就不会崩溃了, 即使之后不再处理.
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(foo)) {
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        return signature;
    }
    return [super methodSignatureForSelector:aSelector];
}

//这里已经不会崩溃了( 可以什么都不做m,但是至少重写出此方法), 可以根据情况自由发挥了.
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (anInvocation.selector == @selector(foo)) {
        anInvocation.selector = @selector(invocationSel);
        [anInvocation invoke];
//        [anInvocation invokeWithTarget:self];
        //甚至创造一个全新invocation, 或者直接调用其他方法都可...
    }

}

void msg_forwarding() {
    NSLog(@"消息转发 +resolveInstanceMethod; ");
}

- (void)invocationSel {
    NSLog(@"消息转发 invoke other invocation;");
}



- (void)wz_nslog:(NSString *)str {
    NSLog(@"invoke log ==> %@",str);
}

//kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@\n %@\n%@\n%@",object,keyPath,change,context);
    NSLog(@"%@",change[@"new"]);
    //object 是被观察对象,  keyPath被观察属性, change属性值字典 old new,   context观察时传入的参数.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"WillAppear --- %@",_poolStr);
//    NSLog(@"WillAppear --- %@",_weakArr);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSLog(@"DidAppear --- %@",_poolStr);
//    NSLog(@"WillAppear --- %@",_weakArr);
}


- (void)threadElse {
//    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"timer 1");
    }]; //若repeat改成NO, 则thread销毁, 会打印下面的after.
    [NSRunLoop.currentRunLoop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes]; //也可以保活runloop,从而保活线程
    [[NSRunLoop currentRunLoop] run];
    NSLog(@"after");
}


//崩溃原因是,属性nonatomic, 然后被release的原指针 同时其再次被另一个线程release,即野指针调用的崩溃.(也不是100%崩溃)
- (void)taggedPointer {
    NSString *str1 = [NSString stringWithFormat:@"%d",0];
    NSString *str2 = @"0";
    NSLog(@"%s\n%s",object_getClassName(str1),object_getClassName(str2));
    
    dispatch_queue_t queue = dispatch_queue_create("concurrent mark", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<1000000; i++) {
        dispatch_async(queue, ^{ //改成sync或者后面再执行NSLog都不会导致并发的崩溃.
//            self.mark = [NSString stringWithFormat:@"ksddkjalksdfafsdfadfassdfsadasdjd%d",i];
            self.mark = [NSString stringWithFormat:@"%d",i];
        });
//        NSLog(@"%d",i);
    }
}


@end
