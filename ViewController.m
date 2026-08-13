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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLog:) name:@"LogNotification" object:nil];
    [self setupUI];
}

- (void)setupUI {
    // Botão no topo
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.jailbreakButton setTitle:@"🔓 INICIAR JAILBREAK" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.jailbreakButton setBackgroundColor:[UIColor systemBlueColor]];
    self.jailbreakButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.jailbreakButton.layer.cornerRadius = 12;
    [self.jailbreakButton addTarget:self action:@selector(startJailbreak) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
    
    // Activity dentro do botão
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.color = [UIColor whiteColor];
    [self.jailbreakButton addSubview:self.activityIndicator];
    
    // TextView (logs)
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logTextView.editable = NO;
    self.logTextView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    self.logTextView.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.logTextView.font = [UIFont monospacedSystemFontOfSize:10 weight:UIFontWeightBold];
    self.logTextView.layer.cornerRadius = 8;
    self.logTextView.text = @"Aguardando...\n";
    self.logTextView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.view addSubview:self.logTextView];
    
    // Constraints - botão no topo
    [NSLayoutConstraint activateConstraints:@[
        // Botão no topo
        [self.jailbreakButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [self.jailbreakButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.jailbreakButton.widthAnchor constraintEqualToConstant:200],
        [self.jailbreakButton.heightAnchor constraintEqualToConstant:44],
        
        // Activity no centro do botão
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.jailbreakButton.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.jailbreakButton.centerYAnchor],
        
        // TextView ocupa o resto
        [self.logTextView.topAnchor constraintEqualToAnchor:self.jailbreakButton.bottomAnchor constant:8],
        [self.logTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:8],
        [self.logTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-8],
        [self.logTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-8],
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
                [weakSelf.jailbreakButton setTitle:@"✅ OK!" forState:UIControlStateNormal];
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
