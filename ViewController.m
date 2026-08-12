#import "ViewController.h"
#import "exploit.h"

// Função callback que recebe os logs do C
void log_callback(const char *message) {
    // Converte para NSString e envia para o ViewController
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Jailbreak";
    self.isRunning = NO;
    
    // Registra o callback para receber logs do C
    set_log_callback(log_callback);
    
    // Observer para receber logs via Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLog:)
                                                 name:@"LogNotification"
                                               object:nil];
    
    [self setupUI];
}

- (void)setupUI {
    // ----- BOTÃO -----
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.jailbreakButton.frame = CGRectMake(50, 200, 280, 60);
    [self.jailbreakButton setTitle:@"🚀 INICIAR JAILBREAK" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.jailbreakButton setBackgroundColor:[UIColor systemBlueColor]];
    self.jailbreakButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.jailbreakButton.layer.cornerRadius = 14;
    [self.jailbreakButton addTarget:self
                             action:@selector(startJailbreak)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
    
    // ----- TEXTVIEW -----
    self.logTextView = [[UITextView alloc] initWithFrame:CGRectMake(16, 80, self.view.bounds.size.width - 32, 100)];
    self.logTextView.editable = NO;
    self.logTextView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    self.logTextView.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.logTextView.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightBold];
    self.logTextView.text = @"Aguardando início...\n";
    [self.view addSubview:self.logTextView];
    
    // ----- ACTIVITY INDICATOR -----
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.frame = CGRectMake(140, 220, 40, 40);
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.color = [UIColor whiteColor];
    [self.view addSubview:self.activityIndicator];
}

// Recebe logs via Notification
- (void)receiveLog:(NSNotification *)notification {
    NSString *log = notification.userInfo[@"log"];
    if (log) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.logTextView.text = [self.logTextView.text stringByAppendingFormat:@"%@\n", log];
            // Scroll para o final
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
