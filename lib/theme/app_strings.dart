import '../state/app_settings.dart';

/// EN/AR localized strings for the app.
/// Mirrors the i18n table from the original prototype.
class S {
  S._();

  static const Map<String, Map<AppLang, String>> _table = {
    // Generic
    'back':      {AppLang.en: 'Back',      AppLang.ar: 'رجوع'},
    'next':      {AppLang.en: 'Next',      AppLang.ar: 'التالي'},
    'cancel':    {AppLang.en: 'Cancel',    AppLang.ar: 'إلغاء'},
    'confirm':   {AppLang.en: 'Confirm',   AppLang.ar: 'تأكيد'},
    'send':      {AppLang.en: 'Send',      AppLang.ar: 'إرسال'},
    'pay':       {AppLang.en: 'Pay',       AppLang.ar: 'دفع'},
    'done':      {AppLang.en: 'Done',      AppLang.ar: 'تم'},
    'edit':      {AppLang.en: 'Edit',      AppLang.ar: 'تعديل'},
    'total':     {AppLang.en: 'Total',     AppLang.ar: 'المجموع'},
    'balance':   {AppLang.en: 'Balance',   AppLang.ar: 'الرصيد'},
    'available': {AppLang.en: 'available', AppLang.ar: 'متاح'},
    'skip':      {AppLang.en: 'Skip',      AppLang.ar: 'تخطي'},

    // Tabs
    'home':    {AppLang.en: 'Home',    AppLang.ar: 'الرئيسية'},
    'pay_t':   {AppLang.en: 'Pay',     AppLang.ar: 'دفع'},
    'history': {AppLang.en: 'History', AppLang.ar: 'السجل'},
    'profile': {AppLang.en: 'Profile', AppLang.ar: 'الحساب'},
    'stores':  {AppLang.en: 'Stores',  AppLang.ar: 'متاجر'},

    // Dashboard
    'total_balance':  {AppLang.en: 'Total balance',     AppLang.ar: 'إجمالي الرصيد'},
    'across_wallets': {AppLang.en: 'Across {n} wallets', AppLang.ar: 'عبر {n} محافظ'},
    'quick_actions':  {AppLang.en: 'Quick actions',     AppLang.ar: 'إجراءات سريعة'},
    'send_money':     {AppLang.en: 'Send',              AppLang.ar: 'إرسال'},
    'request':        {AppLang.en: 'Request',           AppLang.ar: 'استلام'},
    'split_pay':      {AppLang.en: 'Split pay',         AppLang.ar: 'دفع مقسّم'},
    'scan_pay':       {AppLang.en: 'Scan',              AppLang.ar: 'مسح'},
    'your_wallets':   {AppLang.en: 'Your wallets',      AppLang.ar: 'محافظك'},
    'add_wallet':     {AppLang.en: 'Add wallet',        AppLang.ar: 'إضافة محفظة'},
    'recent':         {AppLang.en: 'Recent activity',   AppLang.ar: 'النشاط الأخير'},
    'see_all':        {AppLang.en: 'See all',           AppLang.ar: 'عرض الكل'},
    'synced':         {AppLang.en: 'Synced',            AppLang.ar: 'متزامن'},
    'updated_now':    {AppLang.en: 'updated now',       AppLang.ar: 'محدّث الآن'},
    'hi':             {AppLang.en: 'Hi,',               AppLang.ar: 'مرحباً،'},
    'omar':           {AppLang.en: 'Omar',              AppLang.ar: 'عمر'},

    // Onboarding
    'welcome':       {
      AppLang.en: 'All your wallets.\nOne place.',
      AppLang.ar: 'كل محافظك.\nمكان واحد.'
    },
    'welcome_sub': {
      AppLang.en: 'Send, receive, and split payments across every Yemeni wallet — without switching apps.',
      AppLang.ar: 'أرسل واستلم واقسم المدفوعات عبر جميع المحافظ اليمنية — دون تبديل التطبيقات.'
    },
    'get_started': {AppLang.en: 'Get started',      AppLang.ar: 'ابدأ الآن'},
    'has_account': {AppLang.en: 'I have an account', AppLang.ar: 'لدي حساب'},
    'link_title':  {AppLang.en: 'Link your wallets', AppLang.ar: 'وصِّل محافظك'},
    'link_sub':    {
      AppLang.en: 'Pick the wallets you already use. You can add more anytime.',
      AppLang.ar: 'اختر المحافظ التي تستخدمها. يمكنك دائماً إضافة المزيد لاحقاً.'
    },
    'link_perm': {
      AppLang.en: 'YemenPay uses an encrypted connection with each wallet. You control granular permissions.',
      AppLang.ar: 'يستخدم يمن باي اتصالاً مشفّراً مع كل محفظة. يمكنك ضبط الصلاحيات بدقة.'
    },
    'continue_with_n': {
      AppLang.en: 'Continue with {n} wallet{s}',
      AppLang.ar: 'متابعة مع {n} محافظ'
    },

    // Send
    'send_money_title': {AppLang.en: 'Send money', AppLang.ar: 'إرسال'},
    'to':               {AppLang.en: 'To',         AppLang.ar: 'إلى'},
    'amount':           {AppLang.en: 'Amount',     AppLang.ar: 'المبلغ'},
    'from_wallet':      {AppLang.en: 'From wallet', AppLang.ar: 'من المحفظة'},

    // Split
    'split_title':     {AppLang.en: 'Split payment', AppLang.ar: 'دفع مقسّم'},
    'smart_split':     {AppLang.en: 'Smart split',   AppLang.ar: 'تقسيم ذكي'},
    'smart_split_sub': {
      AppLang.en: 'YemenPay picks the optimal mix from your wallets.',
      AppLang.ar: 'تختار يمن باي المزيج الأمثل من محافظك.'
    },
    'pay_amount':       {AppLang.en: 'Amount to pay',       AppLang.ar: 'المبلغ المراد دفعه'},
    'split_across':     {AppLang.en: 'Split across wallets', AppLang.ar: 'تقسيم على المحافظ'},
    'covered':          {AppLang.en: '✓ covered',            AppLang.ar: '✓ مكتمل'},
    'short_remaining':  {AppLang.en: 'short',                AppLang.ar: 'متبقي'},
    'confirm_and_pay':  {AppLang.en: 'Confirm & pay',        AppLang.ar: 'تأكيد ودفع'},

    // History
    'history_title':  {AppLang.en: 'History',          AppLang.ar: 'السجل'},
    'inflow':         {AppLang.en: 'Inflow',           AppLang.ar: 'وارد'},
    'outflow':        {AppLang.en: 'Outflow',          AppLang.ar: 'صادر'},
    'last_5_days':    {AppLang.en: 'last 5 days',      AppLang.ar: '5 أيام'},
    'all':            {AppLang.en: 'All',              AppLang.ar: 'الكل'},
    'in':             {AppLang.en: 'In',               AppLang.ar: 'وارد'},
    'out':            {AppLang.en: 'Out',              AppLang.ar: 'صادر'},
    'split':          {AppLang.en: 'Split',            AppLang.ar: 'مقسّم'},
    'filters':        {AppLang.en: 'Filters',          AppLang.ar: 'فلتر'},
    'today':          {AppLang.en: 'Today',            AppLang.ar: 'اليوم'},
    'wallets':        {AppLang.en: 'wallets',          AppLang.ar: 'محافظ'},
    'pending':        {AppLang.en: 'pending',          AppLang.ar: 'قيد المعالجة'},
    'failed':         {AppLang.en: 'failed',           AppLang.ar: 'فشل'},
    'wallet_linked':  {AppLang.en: 'Wallet linked',    AppLang.ar: 'محفظة موصولة'},

    // Checkout
    'pay_with':         {AppLang.en: 'Pay with YemenPay', AppLang.ar: 'ادفع باستخدام يمن باي'},
    'order_total':      {AppLang.en: 'Order total',       AppLang.ar: 'إجمالي الطلب'},
    'pay_now':          {AppLang.en: 'Pay now',           AppLang.ar: 'ادفع الآن'},
    'payment_complete': {AppLang.en: 'Payment complete',  AppLang.ar: 'اكتمل الدفع'},
    'paying':           {AppLang.en: 'Paying',            AppLang.ar: 'الدفع إلى'},
    'order':            {AppLang.en: 'Order',             AppLang.ar: 'رقم الطلب'},
    'secure_by':        {AppLang.en: 'Secure payment by', AppLang.ar: 'دفع آمن عبر'},
    'payment_method':   {AppLang.en: 'Payment method',    AppLang.ar: 'طريقة الدفع'},
    'single_wallet':    {AppLang.en: 'Single wallet',     AppLang.ar: 'محفظة واحدة'},
    'pay_one_wallet':   {AppLang.en: 'Pay from one wallet', AppLang.ar: 'دفع من محفظة واحدة'},
    'split_payment':    {AppLang.en: 'Split payment',     AppLang.ar: 'دفع مقسّم'},
    'combine_multiple': {AppLang.en: 'Combine multiple',  AppLang.ar: 'ادمج عدة محافظ'},
    'insufficient':     {AppLang.en: 'Insufficient',      AppLang.ar: 'رصيد غير كافٍ'},
    'auto_split_info':  {
      AppLang.en: 'YemenPay will auto-split across all 3 wallets at live FX rates. You can adjust on the next screen.',
      AppLang.ar: 'سيقوم يمن باي بحساب أفضل توزيع تلقائياً عبر محافظك الثلاث، مع تحويل العملات بالأسعار اللحظية.'
    },
    'customize_split': {AppLang.en: 'Customize split',    AppLang.ar: 'تخصيص التقسيم'},
    'continue_lbl':    {AppLang.en: 'Continue',           AppLang.ar: 'متابعة'},
    'e2e_protected':   {
      AppLang.en: 'Protected by end-to-end encryption',
      AppLang.ar: 'محمي بتشفير من طرف إلى طرف'
    },
    'how_to_split':   {AppLang.en: 'How to split',     AppLang.ar: 'كيفية التقسيم'},
    'confirm_split':  {AppLang.en: 'Confirm split',    AppLang.ar: 'تأكيد التقسيم'},
    'enter_pin':      {AppLang.en: 'Enter wallet PIN', AppLang.ar: 'أدخل رمز المحفظة'},
    'to_confirm':     {
      AppLang.en: 'To confirm',
      AppLang.ar: 'لتأكيد دفع'
    },
    'use_touch_id': {
      AppLang.en: '👆 Use Touch ID instead',
      AppLang.ar: '👆 استخدم البصمة بدلاً من ذلك'
    },
    'receipt':       {AppLang.en: 'Receipt',         AppLang.ar: 'الإيصال'},
    'total_paid':    {AppLang.en: 'Total paid',      AppLang.ar: 'الإجمالي المدفوع'},
    'share':         {AppLang.en: 'Share',           AppLang.ar: 'مشاركة'},
    'paid_to':       {AppLang.en: 'paid to',         AppLang.ar: 'تم دفع'},

    // Onboarding wallet descriptions
    'desc_jaib':      {AppLang.en: 'Daily transactions in YER', AppLang.ar: 'للمعاملات اليومية بالريال'},
    'desc_alkuraimi': {AppLang.en: 'Cross-border in SAR',       AppLang.ar: 'للتحويلات بالريال السعودي'},
    'desc_onecash':   {AppLang.en: 'International USD',         AppLang.ar: 'للتعاملات الدولية بالدولار'},

    // Permissions
    'perm_view': {AppLang.en: 'VIEW', AppLang.ar: 'عرض'},
    'perm_full': {AppLang.en: 'FULL', AppLang.ar: 'كامل'},
  };

  /// Look up a string by key, with optional `{name}` interpolation.
  static String t(String key, AppLang lang, {Map<String, String> vars = const {}}) {
    var s = _table[key]?[lang] ?? _table[key]?[AppLang.en] ?? key;
    vars.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }
}