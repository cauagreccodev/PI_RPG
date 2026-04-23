import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSocialAuth(String provider) async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.loginWithProvider(provider);
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conectado via $provider!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail inválido.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    bool success;
    if (isLogin) {
      success = await authService.login(email, password);
    } else {
      success = await authService.register(email, password, name);
    }
    
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLogin ? 'Bem-vindo de volta!' : 'Personagem forjado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLogin ? 'Erro na autenticação. Verifique os dados.' : 'E-mail já cadastrado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  isLogin ? 'BEM-VINDO' : 'NOVO HERÓI',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE0C9A6),
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin ? 'Entre na Taverna' : 'Forje seu destino no reino',
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    color: const Color(0xFF8B4513),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Name Field (Only for Signup)
                if (!isLogin) ...[
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nome do Personagem',
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'E-mail do Aventureiro',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Chave de Acesso',
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                // Main Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: const Color(0xFFF0E68C),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: Color(0xFFF0E68C), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 8,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFFF0E68C), strokeWidth: 2))
                    : Text(
                        isLogin ? 'ENTRAR' : 'CRIAR PERSONAGEM',
                        style: GoogleFonts.cinzelDecorative(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),

                const SizedBox(height: 24),

                // Diver (OU)
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFF8B4513), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OU', style: GoogleFonts.merriweather(color: const Color(0xFF8B4513), fontSize: 12)),
                    ),
                    const Expanded(child: Divider(color: Color(0xFF8B4513), thickness: 1)),
                  ],
                ),

                const SizedBox(height: 16),

                // Social Buttons (Google & Facebook)
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onTap: () => _handleSocialAuth('Google'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSocialButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        onTap: () => _handleSocialAuth('Facebook'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const SizedBox(height: 16),

                // Switch Login/Signup
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'Deseja criar um novo herói?'
                        : 'Já possui um herói? Volte aqui.',
                    style: GoogleFonts.merriweather(
                      color: const Color(0xFFE0C9A6).withAlpha(150),
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.merriweather(color: const Color(0xFFE0C9A6)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.merriweather(color: const Color(0xFF8B4513), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: const Color(0xFF3D3D3D),
        border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF8B4513))),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF8B4513))),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xFFF0E68C)),
      label: Text(label, style: GoogleFonts.merriweather(color: const Color(0xFFE0C9A6), fontSize: 12)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF8B4513)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
