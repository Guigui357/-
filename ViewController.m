#import "ViewController.h"
#import "exploit.h"

void log_callback(const char *message) {
    NSString *msg = [NSString stringWithUTF8String:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LogNotification"
                                                        object:nil
                                                      userInfo:@{@"log": msg}];
}

@interface ViewController ()
@property (nonatomic, strong) UIButton *jailbreakButton;
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL isRunning;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Jailbreak";
    
    set_log_callback(log_callback);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLog:)
                                                 name:@"LogNotification"
                                               object:nil];
    
    [self setupUI];
}

- (void)setupUI {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"🔓 iOS 27 Beta 4 Jailbreak";
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor systemBlueColor];
    [self.view addSubview:titleLabel];
    
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logTextView.editable = NO;
    self.logTextView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    self.logTextView.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.logTextView.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightBold];
    self.logTextView.layer.cornerRadius = 12;
    self.logTextView.text = @"Aguardando início...\n";
    self.logTextView.contentInset = UIEdgeInsetsMake(12, 12, 12, 12);
    [self.view addSubview:self.logTextView];
    
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.jailbreakButton setTitle:@"🔓 INICIAR JAILBREAK" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.jailbreakButton setBackgroundColor:[UIColor systemBlueColor]];
    self.jailbreakButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.jailbreakButton.layer.cornerRadius = 14;
    [self.jailbreakButton addTarget:self
                             action:@selector(startJailbreak)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.color = [UIColor whiteColor];
    [self.jailbreakButton addSubview:self.activityIndicator];
    
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [titleLabel.heightAnchor constraintEqualToConstant:40],
        
        [self.logTextView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:12],
        [self.logTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:12],
        [self.logTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-12],
        [self.logTextView.heightAnchor constraintEqualToConstant:500],
        
        [self.jailbreakButton.topAnchor constraintEqualToAnchor:self.logTextView.bottomAnchor constant:20],
        [self.jailbreakButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.jailbreakButton.widthAnchor constraintEqualToConstant:280],
        [self.jailbreakButton.heightAnchor constraintEqualToConstant:55],
        
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.jailbreakButton.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.jailbreakButton.centerYAnchor],
    ]];
}

- (void)receiveLog:(NSNotification *)notification {
    NSString *log = notification.userInfo[@"log"];
    if (log) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.logTextView.text = [self.logTextView.text stringByAppendingFormat:@"%@\n", log];
            NSRange range = NSMakeRange(self.logTextView.text.length - 1, 1);
            [self.logTextView scrollRangeToVisible:range];
        });
    }
}

- (void)appendLog:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.text = [self.logTextView.text stringByAppendingFormat:@"%@\n", msg];
        NSRange range = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:range];
    });
}

- (void)startJailbreak {
    if (self.isRunning) return;
    self.isRunning = YES;
    
    [self.jailbreakButton setEnabled:NO];
    [self.jailbreakButton setTitle:@"" forState:UIControlStateNormal];
    [self.jailbreakButton setBackgroundColor:[UIColor systemGrayColor]];
    [self.activityIndicator startAnimating];
    self.logTextView.text = @"";
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int result = run_jailbreak();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.activityIndicator stopAnimating];
            [weakSelf.jailbreakButton setEnabled:YES];
            
            if (result == 0) {
                [weakSelf.jailbreakButton setTitle:@"✅ JAILBREAK OK!" forState:UIControlStateNormal];
                [weakSelf.jailbreakButton setBackgroundColor:[UIColor systemGreenColor]];
            } else {
                [weakSelf.jailbreakButton setTitle:@"❌ FALHOU" forState:UIControlStateNormal];
                [weakSelf.jailbreakButton setBackgroundColor:[UIColor systemRedColor]];
            }
            
            weakSelf.isRunning = NO;
        });
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
