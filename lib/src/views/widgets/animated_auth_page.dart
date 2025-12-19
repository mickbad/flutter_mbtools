
import 'package:flutter/material.dart';

import '../../../mbtools.dart';

///
/// Classes de données pour les formulaires
///
class LoginData {
  final String email;
  final String password;
  LoginData({required this.email, required this.password});

  ///
  /// Affichage toString
  ///
  @override
  String toString() {
    return 'LoginData(email: $email, password: $password)';
  }
}

class SignUpData {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  SignUpData({required this.email, required this.password, required this.confirmPassword, required this.name});

  ///
  /// Affichage toString
  ///
  @override
  String toString() {
    return 'SignUpData(email: $email, password: $password, confirmPassword: $confirmPassword, name: $name)';
  }
}

///
/// Textes à appliquer sur le module de login
///
class AnimatedAuthLabels {
  ///
  /// Récupération du mot de passe
  ///
  final String forgotPasswordEmailFailed;
  final String forgotPasswordEmailSent;
  final String forgotPasswordTitle;

  ///
  /// Formulaire Login
  ///
  final String loginFormTitle;
  final String loginFormDescription;
  final String loginFormNoAccount;
  final String loginFormNoAccountLink;

  ///
  /// Formulaire Inscription
  ///
  final String signupFormTitle;
  final String signupFormDescription;
  final String signupFormLegacyPrefix;
  final String signupFormLegacyPrivacyPolicy;
  final String signupFormLegacyTermsOfUse;
  final String signupFormAccount;
  final String signupFormAccountLink;

  // final String signup

  ///
  /// Eléments de formulaires
  ///
  final String formLabelName;
  final String formLabelEmail;
  final String formLabelPassword;
  final String formLabelConfirmPassword;
  final String formLabelSubmit;
  final String formLabelForgotPassword;
  final String formLabelSignup;

  ///
  /// Validation du formulaire
  ///
  final String formValidationEmpty;
  final String formValidationEmail;
  final String formValidationPassword;
  final String formValidationConfirmPassword;
  final String formValidationMinLength;

  ///
  /// Constructeurs
  ///

  // Défault : FR
  const AnimatedAuthLabels({
    this.forgotPasswordTitle = "Mot de passe oublié ?",
    this.forgotPasswordEmailFailed = "Veuillez entrer votre email",
    this.forgotPasswordEmailSent = "Un email vous a été envoyé",

    this.loginFormTitle = "Bon retour !",
    this.loginFormDescription = "Connectez-vous pour accéder à votre compte",
    this.loginFormNoAccount = "Vous n'avez pas de compte ?",
    this.loginFormNoAccountLink = "S'inscrire",

    this.signupFormTitle = "Créer un compte",
    this.signupFormDescription = "Rejoignez-nous dès maintenant",
    this.signupFormLegacyPrefix = "En vous inscrivant, vous acceptez",
    this.signupFormLegacyPrivacyPolicy = "notre Politique de confidentialité",
    this.signupFormLegacyTermsOfUse = "nos CGU",
    this.signupFormAccount = "Déjà un compte ?",
    this.signupFormAccountLink = "Se connecter",

    this.formLabelName = "Votre nom et prénom",
    this.formLabelEmail = "Email",
    this.formLabelPassword = "Mot de passe",
    this.formLabelConfirmPassword = "Confirmer le mot de passe",
    this.formLabelSubmit = "Se connecter",
    this.formLabelForgotPassword = "Mot de passe oublié ?",
    this.formLabelSignup = "S'inscrire",

    this.formValidationEmpty = "Valeur requise",
    this.formValidationEmail = "Email invalide",
    this.formValidationPassword = "Mot de passe invalide",
    this.formValidationMinLength = "Minimum [number] caractères",
    this.formValidationConfirmPassword = "Les mots de passe ne correspondent pas",
  });

  // Constructeur EN
  const AnimatedAuthLabels.en({
    this.forgotPasswordTitle = "Forgot your password?",
    this.forgotPasswordEmailFailed = "Please enter your email address",
    this.forgotPasswordEmailSent = "An email has been sent to you",

    this.loginFormTitle = "Welcome back!",
    this.loginFormDescription = "Sign in to access your account",
    this.loginFormNoAccount = "Don't have an account?",
    this.loginFormNoAccountLink = "Sign up",

    this.signupFormTitle = "Create an account",
    this.signupFormDescription = "Join us today",
    this.signupFormLegacyPrefix = "By signing up, you agree to",
    this.signupFormLegacyPrivacyPolicy = "our Privacy Policy",
    this.signupFormLegacyTermsOfUse = "our Terms of Use",
    this.signupFormAccount = "Already have an account?",
    this.signupFormAccountLink = "Sign in",

    this.formLabelName = "Full name",
    this.formLabelEmail = "Email",
    this.formLabelPassword = "Password",
    this.formLabelConfirmPassword = "Confirm password",
    this.formLabelSubmit = "Sign in",
    this.formLabelForgotPassword = "Forgot password?",
    this.formLabelSignup = "Sign up",

    this.formValidationEmpty = "Required field",
    this.formValidationEmail = "Invalid email address",
    this.formValidationPassword = "Invalid password",
    this.formValidationMinLength = "Minimum [number] characters",
    this.formValidationConfirmPassword = "Passwords do not match",
  });

  // ES
  const AnimatedAuthLabels.es({
    this.forgotPasswordTitle = "¿Olvidaste tu contraseña?",
    this.forgotPasswordEmailFailed = "Por favor, introduce tu correo electrónico",
    this.forgotPasswordEmailSent = "Se ha enviado un correo electrónico",

    this.loginFormTitle = "¡Bienvenido de nuevo!",
    this.loginFormDescription = "Inicia sesión para acceder a tu cuenta",
    this.loginFormNoAccount = "¿No tienes una cuenta?",
    this.loginFormNoAccountLink = "Registrarse",

    this.signupFormTitle = "Crear una cuenta",
    this.signupFormDescription = "Únete ahora",
    this.signupFormLegacyPrefix = "Al registrarte, aceptas",
    this.signupFormLegacyPrivacyPolicy = "nuestra Política de privacidad",
    this.signupFormLegacyTermsOfUse = "nuestros Términos de uso",
    this.signupFormAccount = "¿Ya tienes una cuenta?",
    this.signupFormAccountLink = "Iniciar sesión",

    this.formLabelName = "Nombre completo",
    this.formLabelEmail = "Correo electrónico",
    this.formLabelPassword = "Contraseña",
    this.formLabelConfirmPassword = "Confirmar contraseña",
    this.formLabelSubmit = "Iniciar sesión",
    this.formLabelForgotPassword = "¿Olvidaste tu contraseña?",
    this.formLabelSignup = "Registrarse",

    this.formValidationEmpty = "Campo obligatorio",
    this.formValidationEmail = "Correo electrónico no válido",
    this.formValidationPassword = "Contraseña no válida",
    this.formValidationMinLength = "Mínimo [number] caracteres",
    this.formValidationConfirmPassword = "Las contraseñas no coinciden",
  });

  // DE
  const AnimatedAuthLabels.de({
    this.forgotPasswordTitle = "Passwort vergessen?",
    this.forgotPasswordEmailFailed = "Bitte geben Sie Ihre E-Mail-Adresse ein",
    this.forgotPasswordEmailSent = "Eine E-Mail wurde gesendet",

    this.loginFormTitle = "Willkommen zurück!",
    this.loginFormDescription = "Melden Sie sich an, um auf Ihr Konto zuzugreifen",
    this.loginFormNoAccount = "Noch kein Konto?",
    this.loginFormNoAccountLink = "Registrieren",

    this.signupFormTitle = "Konto erstellen",
    this.signupFormDescription = "Jetzt beitreten",
    this.signupFormLegacyPrefix = "Mit der Registrierung akzeptieren Sie",
    this.signupFormLegacyPrivacyPolicy = "unsere Datenschutzrichtlinie",
    this.signupFormLegacyTermsOfUse = "unsere Nutzungsbedingungen",
    this.signupFormAccount = "Bereits ein Konto?",
    this.signupFormAccountLink = "Anmelden",

    this.formLabelName = "Vor- und Nachname",
    this.formLabelEmail = "E-Mail",
    this.formLabelPassword = "Passwort",
    this.formLabelConfirmPassword = "Passwort bestätigen",
    this.formLabelSubmit = "Anmelden",
    this.formLabelForgotPassword = "Passwort vergessen?",
    this.formLabelSignup = "Registrieren",

    this.formValidationEmpty = "Pflichtfeld",
    this.formValidationEmail = "Ungültige E-Mail-Adresse",
    this.formValidationPassword = "Ungültiges Passwort",
    this.formValidationMinLength = "Mindestens [number] Zeichen",
    this.formValidationConfirmPassword = "Passwörter stimmen nicht überein",
  });

  // IT
  const AnimatedAuthLabels.it({
    this.forgotPasswordTitle = "Password dimenticata?",
    this.forgotPasswordEmailFailed = "Inserisci il tuo indirizzo email",
    this.forgotPasswordEmailSent = "Ti è stata inviata un’email",

    this.loginFormTitle = "Bentornato!",
    this.loginFormDescription = "Accedi per entrare nel tuo account",
    this.loginFormNoAccount = "Non hai un account?",
    this.loginFormNoAccountLink = "Registrati",

    this.signupFormTitle = "Crea un account",
    this.signupFormDescription = "Unisciti a noi ora",
    this.signupFormLegacyPrefix = "Registrandoti, accetti",
    this.signupFormLegacyPrivacyPolicy = "la nostra Informativa sulla privacy",
    this.signupFormLegacyTermsOfUse = "i nostri Termini di utilizzo",
    this.signupFormAccount = "Hai già un account?",
    this.signupFormAccountLink = "Accedi",

    this.formLabelName = "Nome e cognome",
    this.formLabelEmail = "Email",
    this.formLabelPassword = "Password",
    this.formLabelConfirmPassword = "Conferma password",
    this.formLabelSubmit = "Accedi",
    this.formLabelForgotPassword = "Password dimenticata?",
    this.formLabelSignup = "Registrati",

    this.formValidationEmpty = "Campo obbligatorio",
    this.formValidationEmail = "Email non valida",
    this.formValidationPassword = "Password non valida",
    this.formValidationMinLength = "Minimo [number] caratteri",
    this.formValidationConfirmPassword = "Le password non coincidono",
  });

  // Chinois traditionnel
  const AnimatedAuthLabels.zhTw({
    this.forgotPasswordTitle = "忘記密碼？",
    this.forgotPasswordEmailFailed = "請輸入您的電子郵件地址",
    this.forgotPasswordEmailSent = "已向您發送電子郵件",

    this.loginFormTitle = "歡迎回來！",
    this.loginFormDescription = "登入以存取您的帳戶",
    this.loginFormNoAccount = "還沒有帳戶？",
    this.loginFormNoAccountLink = "註冊",

    this.signupFormTitle = "建立帳戶",
    this.signupFormDescription = "立即加入我們",
    this.signupFormLegacyPrefix = "註冊即表示您同意",
    this.signupFormLegacyPrivacyPolicy = "我們的隱私政策",
    this.signupFormLegacyTermsOfUse = "我們的使用條款",
    this.signupFormAccount = "已經有帳戶？",
    this.signupFormAccountLink = "登入",

    this.formLabelName = "姓名",
    this.formLabelEmail = "電子郵件",
    this.formLabelPassword = "密碼",
    this.formLabelConfirmPassword = "確認密碼",
    this.formLabelSubmit = "登入",
    this.formLabelForgotPassword = "忘記密碼？",
    this.formLabelSignup = "註冊",

    this.formValidationEmpty = "必填欄位",
    this.formValidationEmail = "電子郵件格式無效",
    this.formValidationPassword = "密碼無效",
    this.formValidationMinLength = "至少 [number] 個字元",
    this.formValidationConfirmPassword = "密碼不一致",
  });

  // Chinois simplifié
  const AnimatedAuthLabels.zhCn({
    this.forgotPasswordTitle = "忘记密码？",
    this.forgotPasswordEmailFailed = "请输入您的电子邮箱",
    this.forgotPasswordEmailSent = "已向您发送邮件",

    this.loginFormTitle = "欢迎回来！",
    this.loginFormDescription = "登录以访问您的账户",
    this.loginFormNoAccount = "还没有账户？",
    this.loginFormNoAccountLink = "注册",

    this.signupFormTitle = "创建账户",
    this.signupFormDescription = "立即加入我们",
    this.signupFormLegacyPrefix = "注册即表示您同意",
    this.signupFormLegacyPrivacyPolicy = "我们的隐私政策",
    this.signupFormLegacyTermsOfUse = "我们的使用条款",
    this.signupFormAccount = "已有账户？",
    this.signupFormAccountLink = "登录",

    this.formLabelName = "姓名",
    this.formLabelEmail = "电子邮箱",
    this.formLabelPassword = "密码",
    this.formLabelConfirmPassword = "确认密码",
    this.formLabelSubmit = "登录",
    this.formLabelForgotPassword = "忘记密码？",
    this.formLabelSignup = "注册",

    this.formValidationEmpty = "必填项",
    this.formValidationEmail = "邮箱格式无效",
    this.formValidationPassword = "密码无效",
    this.formValidationMinLength = "至少 [number] 个字符",
    this.formValidationConfirmPassword = "两次输入的密码不一致",
  });

  // RU
  const AnimatedAuthLabels.ru({
    this.forgotPasswordTitle = "Забыли пароль?",
    this.forgotPasswordEmailFailed = "Пожалуйста, введите ваш адрес электронной почты",
    this.forgotPasswordEmailSent = "Письмо было отправлено",

    this.loginFormTitle = "С возвращением!",
    this.loginFormDescription = "Войдите, чтобы получить доступ к аккаунту",
    this.loginFormNoAccount = "Нет аккаунта?",
    this.loginFormNoAccountLink = "Зарегистрироваться",

    this.signupFormTitle = "Создать аккаунт",
    this.signupFormDescription = "Присоединяйтесь сейчас",
    this.signupFormLegacyPrefix = "Регистрируясь, вы принимаете",
    this.signupFormLegacyPrivacyPolicy = "нашу Политику конфиденциальности",
    this.signupFormLegacyTermsOfUse = "наши Условия использования",
    this.signupFormAccount = "Уже есть аккаунт?",
    this.signupFormAccountLink = "Войти",

    this.formLabelName = "Имя и фамилия",
    this.formLabelEmail = "Электронная почта",
    this.formLabelPassword = "Пароль",
    this.formLabelConfirmPassword = "Подтвердите пароль",
    this.formLabelSubmit = "Войти",
    this.formLabelForgotPassword = "Забыли пароль?",
    this.formLabelSignup = "Зарегистрироваться",

    this.formValidationEmpty = "Обязательное поле",
    this.formValidationEmail = "Неверный адрес электронной почты",
    this.formValidationPassword = "Неверный пароль",
    this.formValidationMinLength = "Минимум [number] символов",
    this.formValidationConfirmPassword = "Пароли не совпадают",
  });
}

///
/// Module de login souscription retour de mot de passe
///
class AnimatedAuthPage extends StatefulWidget {
  ///
  /// Activation du mode responsive : affichage différent en tablette ou
  /// mobile ou simplement que mobile
  ///
  final bool responsive;

  ///
  /// Padding d'affichage de la zone des formulaires
  ///
  final EdgeInsets padding;

  ///
  /// Padding supplémentaire des formulaires
  ///
  final EdgeInsets formPadding;

  ///
  /// Largeur maximale de la zone des formulaires
  ///
  final double maxWidth;

  ///
  /// Couleur de fond de la zone d'affichage globale
  ///
  final Color? backgroundColor;

  ///
  /// Dégradé de la zone d'affichage globale
  ///
  final LinearGradient? backgroundGradient;

  ///
  /// Couleur de fond de la zone de connexion
  ///
  Color? loginBackgroundColor;

  ///
  /// Couleur de fond de la zone d'inscription
  ///
  Color? signupBackgroundColor;

  ///
  /// Arrondis du container de formulaire de connexion
  ///
  final double loginBorderRadius;

  ///
  /// Arrondis du container de formulaire d'inscription
  ///
  final double signupBorderRadius;

  ///
  /// Affichage du logo
  ///
  final bool showLogo;

  ///
  /// Widget d'affichage du logo des formulaires
  ///
  Widget? logo;

  ///
  /// Url de l'image du logo
  ///
  final String? logoUrl;

  ///
  /// Dimension du container du logo
  ///
  final double logoSize;

  ///
  /// Couleur de fond du container du logo
  ///
  final Color? logoBackgroundColor;

  ///
  /// Url de la politique de confidentialité
  ///
  final String? privacyPolicyUrl;

  ///
  /// Url des CGU
  ///
  final String? termsOfUseUrl;

  ///
  /// Option : affichage des snackbars lors des traitements des formulaires
  ///
  final bool showSnackbar;

  ///
  /// Option : nombre minimal de caractères du mot de passe
  ///
  final int minPasswordLength;

  ///
  /// Textes de l'interface
  ///
  final AnimatedAuthLabels labels;

  ///
  /// Callback de traitement de la connexion utilisateur
  ///
  final Future<String?> Function(LoginData data) onLogin;

  ///
  /// Callback de traitement du mot de passe oublié
  /// si null, la commande ne s'affiche pas
  ///
  final Future<String?> Function(String email)? onForgotPassword;

  ///
  /// Callback de traitement de la création d'un nouvel utilisateur
  /// si null, la commande ne s'affiche pas
  ///
  final Future<String?> Function(SignUpData data)? onSignup;

  AnimatedAuthPage({
    super.key,
    required this.onLogin,
    this.onForgotPassword,
    this.onSignup,
    this.responsive = false,
    this.padding = const EdgeInsets.all(8.0),
    this.formPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.maxWidth = 600,
    this.backgroundColor = Colors.transparent,
    this.backgroundGradient,
    this.loginBackgroundColor,
    this.signupBackgroundColor,
    this.loginBorderRadius = 30,
    this.signupBorderRadius = 30,
    this.showLogo = true,
    this.logo,
    this.logoUrl,
    this.logoSize = 80,
    this.logoBackgroundColor,
    this.privacyPolicyUrl,
    this.termsOfUseUrl,
    this.showSnackbar = true,
    this.minPasswordLength = 6,
    this.labels = const AnimatedAuthLabels(),
  }) {
    // configuration post-argument
    loginBackgroundColor ??= ToolsConfigApp.appWhiteColor.darken();
    signupBackgroundColor ??= ToolsConfigApp.appWhiteColor.darken();
    logo ??= Icon(Icons.login, size: logoSize / 2, color: ToolsConfigApp.appInvertedColor);
  }

  @override
  State<AnimatedAuthPage> createState() => _AnimatedAuthPageState();
}

class _AnimatedAuthPageState extends State<AnimatedAuthPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  bool _isLogin = true;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    _signupNameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    if (_isLogin) {
      _signupEmailController.text = _loginEmailController.text;
      _signupPasswordController.text = _loginPasswordController.text;
      _controller.forward();
    } else {
      _loginEmailController.text = _signupEmailController.text;
      _loginPasswordController.text = _signupPasswordController.text;
      _controller.reverse();
    }
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleLogin() async {
    // suppression du focus
    FocusScope.of(context).unfocus();

    if (!_loginFormKey.currentState!.validate()) return;

    // extract informations
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    setState(() => _isLoading = true);
    ToolsConfigApp.logger.d("[AnimatedAuthPage]: login in with '$email'");
    final error = await widget.onLogin(
      LoginData(
        email: email,
        password: password,
      ),
    );
    setState(() => _isLoading = false);

    if (widget.showSnackbar && error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: ToolsConfigApp.appErrorColor),
      );
    }
  }

  Future<void> _handleSignup() async {
    // suppression du focus
    FocusScope.of(context).unfocus();

    if (widget.onSignup == null) return;

    if (!_signupFormKey.currentState!.validate()) return;

    // extract informations
    final email = _loginEmailController.text.trim();
    final name = _signupNameController.text.trim();

    setState(() => _isLoading = true);
    ToolsConfigApp.logger.d("[AnimatedAuthPage]: Signup in with '$email' ($name)");
    final error = await widget.onSignup!(
      SignUpData(
        email: email,
        password: _signupPasswordController.text,
        confirmPassword: _signupConfirmPasswordController.text,
        name: name,
      ),
    );
    setState(() => _isLoading = false);

    if (widget.showSnackbar && error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: ToolsConfigApp.appErrorColor),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    // suppression du focus
    FocusScope.of(context).unfocus();

    if (widget.onForgotPassword == null) return;

    // extract informations
    final email = _loginEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.labels.forgotPasswordEmailFailed)),
      );
      return;
    }

    setState(() => _isLoading = true);
    ToolsConfigApp.logger.d("[AnimatedAuthPage]: Retrieve password in with '$email'");
    final error = await widget.onForgotPassword!(email);
    setState(() => _isLoading = false);

    if (widget.showSnackbar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? widget.labels.forgotPasswordEmailSent),
          backgroundColor: error != null ? ToolsConfigApp.appAlertColor : ToolsConfigApp.appGreenColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // construction de la fenêtre
    Widget child;
    if (widget.responsive) {
      // choix entre tablette et mobile
      final size = MediaQuery.of(context).size;
      final isTablet = size.width > 600;

      child = isTablet
          ? _buildTabletLayout()
          : _buildMobileLayout();
    } else {
      // fenêtre simple
      child = _buildMobileLayout();
    }

    // design
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundGradient != null ? null : widget.backgroundColor,
        gradient: widget.backgroundGradient,
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     const Color(0xFF667eea),
        //     const Color(0xFF764ba2),
        //     const Color(0xFFf093fb),
        //   ],
        // ),
      ),
      child: SingleChildScrollView(
        child: GestureDetector(
          // Permet de sortir du focus
          onTap: () => FocusScope.of(context).unfocus(),

          child: Padding(
            padding: widget.padding,
            child: child,
          ),
        ),
      ),
    );
  }

  ///
  /// Construction de la vue mobile
  ///
  Widget _buildMobileLayout() {
    // dimensions
    double maxWidth = widget.maxWidth;
    if (maxWidth < 400) {
      maxWidth = 400;
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: Stack(
                children: [
                  Transform.translate(
                    offset: Offset(-_slideAnimation.value * MediaQuery.of(context).size.width, 0),
                    child: Padding(
                      padding: widget.formPadding,
                      child: _buildLoginForm(),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset((1 - _slideAnimation.value) * MediaQuery.of(context).size.width, 0),
                    child: Padding(
                      padding: widget.formPadding,
                      child: _buildSignupForm(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ///
  /// Construction de la vue tablette
  ///
  Widget _buildTabletLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              spacing: 5,
              children: [
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _isLogin ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 500),
                    child: _buildLoginForm(),
                  ),
                ),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _isLogin ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: _buildSignupForm(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ///
  /// Construction du formulaire de connexion
  ///
  Widget _buildLoginForm() {
    // dimensions radius
    double loginBorderRadius = widget.loginBorderRadius;
    if (loginBorderRadius < 0) {
      loginBorderRadius = 0;
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: widget.loginBackgroundColor,
        borderRadius: BorderRadius.circular(loginBorderRadius),
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogo(),
            const SizedBox(height: 24),
            Text(
              widget.labels.loginFormTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ToolsConfigApp.appPrimaryColor, // const Color(0xFF667eea),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.labels.loginFormDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.6), // Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _loginEmailController,
              label: widget.labels.formLabelEmail,
              icon: Icons.email_outlined,
              validator: (v) => v?.contains('@') != true ? widget.labels.formValidationEmail : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _loginPasswordController,
              label: widget.labels.formLabelPassword,
              icon: Icons.lock_outline,
              obscureText: !_showPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              validator: (v) => v?.isEmpty == true ? widget.labels.formValidationPassword : null,
            ),
            const SizedBox(height: 8),

            ///
            /// Bouton de récupération de mot de passe si le callback est activé
            ///
            if (widget.onForgotPassword != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: Text(
                    widget.labels.formLabelForgotPassword,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.6), // const Color(0xFF667eea),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            _buildButton(
              text: widget.labels.formLabelSubmit,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 16),

            ///
            /// Affichage du bouton d'inscription si on a une fonction de callback
            ///
            if (widget.onSignup != null) ...[
              const SizedBox(height: 15),
              Wrap(
                // spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.labels.loginFormNoAccount,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.6), // const Color(0xFF667eea),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _toggleMode,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.labels.loginFormNoAccountLink,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ToolsConfigApp.appPrimaryColor, // const Color(0xFF667eea),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

          ],
        ),
      ),
    );
  }

  ///
  /// Construction du formulaire d'inscription
  ///
  Widget _buildSignupForm() {
    // dimensions radius
    double signupBorderRadius = widget.signupBorderRadius;
    if (signupBorderRadius < 0) {
      signupBorderRadius = 0;
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: widget.signupBackgroundColor,
        borderRadius: BorderRadius.circular(signupBorderRadius),
      ),
      child: Form(
        key: _signupFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogo(),
            const SizedBox(height: 24),
            Text(
              widget.labels.signupFormTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ToolsConfigApp.appPrimaryColor, // const Color(0xFF764ba2),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.labels.signupFormDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                // color: Colors.grey[600],
                color: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _signupNameController,
              label: widget.labels.formLabelName,
              icon: Icons.person_outline,
              validator: (v) => v?.isEmpty == true ? widget.labels.formValidationEmpty : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signupEmailController,
              label: widget.labels.formLabelEmail,
              icon: Icons.email_outlined,
              validator: (v) =>
              v?.contains('@') != true ? widget.labels.formValidationEmail : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signupPasswordController,
              label: widget.labels.formLabelPassword,
              icon: Icons.lock_outline,
              obscureText: !_showPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              validator: (v) => v!.length < widget.minPasswordLength ? widget.labels.formValidationMinLength.replaceAll('[number]', widget.minPasswordLength.toString()) : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signupConfirmPasswordController,
              label: widget.labels.formLabelConfirmPassword,
              icon: Icons.lock_outline,
              obscureText: !_showConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _showConfirmPassword = !_showConfirmPassword),
              ),
              validator: (v) => v != _signupPasswordController.text
                  ? widget.labels.formValidationConfirmPassword
                  : null,
            ),
            const SizedBox(height: 16),

            ///
            /// Acceptation des CGU et politique de confidentialité
            ///
            if (widget.privacyPolicyUrl != null || widget.termsOfUseUrl != null) ...[
              Wrap(
                spacing: 4,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    widget.labels.signupFormLegacyPrefix,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.6),
                    ),
                  ),

                  ///
                  /// Politique de confidentialité
                  ///
                  if (widget.privacyPolicyUrl != null) ...[
                    InkWell(
                      onTap: () {
                        // Ouvrir la politique de confidentialité
                        ToolsHelpers.launchWeb(url: widget.privacyPolicyUrl!);
                      },
                      child: Text(
                        widget.labels.signupFormLegacyPrivacyPolicy,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.6),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),

                  ///
                  /// CGU
                  ///
                  if (widget.termsOfUseUrl != null) ...[
                    InkWell(
                      onTap: () {
                        // Ouvrir les CGU
                        ToolsHelpers.launchWeb(url: widget.termsOfUseUrl!);
                      },
                      child: Text(
                        widget.labels.signupFormLegacyTermsOfUse,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.6),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 24),

            _buildButton(
              text: widget.labels.formLabelSignup,
              onPressed: _handleSignup,
              color: ToolsConfigApp.appSecondaryColor, // const Color(0xFF764ba2),
            ),
            const SizedBox(height: 31),

            ///
            /// Retour au formulaire de login
            ///
            Wrap(
              // spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.labels.signupFormAccount,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ToolsConfigApp.appPrimaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _toggleMode,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.labels.signupFormAccountLink,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ToolsConfigApp.appPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// Affichage du logo de l'application
  ///
  Widget _buildLogo() {
    // gestion d'affichage
    if (!widget.showLogo || widget.logo == null) {
      return const SizedBox.shrink();
    }

    // fabrication du logo avec lien
    Widget child = widget.logo!;
    if (widget.logoUrl != null) {
      child = InkWell(
        onTap: () => ToolsHelpers.launchWeb(url: widget.logoUrl!),
        child: child,
      );
    }

    // design réel
    return Container(
      height: widget.logoSize,
      width: widget.logoSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.logoBackgroundColor ?? ToolsConfigApp.appPrimaryColor,
            (widget.logoBackgroundColor ?? ToolsConfigApp.appPrimaryColor).darken(0.2),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: (widget.logoBackgroundColor == Colors.transparent) ? null : [
          BoxShadow(
            color: (widget.logoBackgroundColor ?? ToolsConfigApp.appPrimaryColor).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  ///
  /// Gestion de la zone de texte
  ///
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ToolsConfigApp.appPrimaryColor, /*const Color(0xFF667eea)*/),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: ToolsConfigApp.appGreyColor,), // Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: ToolsConfigApp.appGreyColor,), // Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(width: 2, color: ToolsConfigApp.appPrimaryColor,), // Color(0xFF667eea), width: 2),
        ),
        floatingLabelStyle: TextStyle(color: ToolsConfigApp.appPrimaryColor),
        floatingLabelAlignment: FloatingLabelAlignment.start,
        filled: true,
        fillColor: ToolsConfigApp.appWhiteColor, // Colors.grey[50],
      ),
    );
  }

  ///
  /// Gestion des boutons
  ///
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: color != null
              ? [color, color.withValues(alpha: 0.8)]
              : [ToolsConfigApp.appPrimaryColor, ToolsConfigApp.appPrimaryColor.darken(0.15)], // [const Color(0xFF667eea), const Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: (color ?? ToolsConfigApp.appPrimaryColor).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: ToolsConfigApp.appInvertedColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
