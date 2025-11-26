import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/auth/pages/signin.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';

class ResetPasswordFromLinkPage extends StatefulWidget {
  const ResetPasswordFromLinkPage({super.key});
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const ResetPasswordFromLinkPage());

  @override
  State<ResetPasswordFromLinkPage> createState() =>
      _ResetPasswordFromLinkPageState();
}

class _ResetPasswordFromLinkPageState extends State<ResetPasswordFromLinkPage> {
  final _pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _sub;
  String? _accessToken;
  String? _expiresIn;
  bool _loadingLink = true;

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    try {
      // API corretta per app_links 7.0.0
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _extractTokenFromUri(initialUri);
    } catch (_) {
      // ignore
    } finally {
      setState(() => _loadingLink = false);
    }

    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) _extractTokenFromUri(uri);
      },
      onError: (_) {
        // ignore
      },
    );
  }

  void _extractTokenFromUri(Uri uri) {
    String? token;
    String? expiresIn;
    if (uri.fragment.isNotEmpty) {
      final fragParams = Uri.splitQueryString(uri.fragment);
      token = fragParams['access_token'] ?? fragParams['token'];
      expiresIn = fragParams['expires_in'] ?? fragParams['expires_at'];
    }
    if (token == null) {
      token =
          uri.queryParameters['access_token'] ?? uri.queryParameters['token'];
      expiresIn = expiresIn ?? uri.queryParameters['expires_in'];
    }
    if (token != null) {
      setState(() {
        _accessToken = token;
        _expiresIn = expiresIn;
      });
    } else {
      showSnackBar(context, 'Link di reset non valido (token non trovato).');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_accessToken == null) {
      showSnackBar(context, 'Token di reset mancante.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final newPw = _pwController.text.trim();

    // Calcola expires_at se abbiamo expires_in
    int? expiresAt;
    if (_expiresIn != null) {
      try {
        final int expiresInSec = int.parse(_expiresIn!);
        expiresAt =
            DateTime.now()
                .toUtc()
                .add(Duration(seconds: expiresInSec))
                .millisecondsSinceEpoch ~/
            1000;
      } catch (_) {
        expiresAt = null;
      }
    }

    final sessionMap = <String, dynamic>{
      'access_token': _accessToken!,
      if (expiresAt != null) 'expires_at': expiresAt,
      'token_type': 'bearer',
      'user': {},
    };

    final sessionJson = jsonEncode(sessionMap);

    try {
      await Supabase.instance.client.auth.setSession(sessionJson);

      context.read<AuthBloc>().add(
        AuthCompletePasswordReset(
          accessToken: _accessToken!,
          newPassword: newPw,
        ),
      );
    } on AuthException catch (e) {
      showSnackBar(context, e.message);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imposta nuova password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetCompleted) {
              showSnackBar(context, 'Password aggiornata. Effettua il login.');
              Navigator.pushAndRemoveUntil(
                context,
                SigninPage.route(),
                (route) => false,
              );
            } else if (state is AuthFailure) {
              showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (_loadingLink || state is AuthLoading) return const Loader();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_accessToken == null)
                  const Text(
                    'Sto aspettando il link di reset o il link non è valido. Apri la mail e tocca il link per tornare qui.',
                  ),
                if (_accessToken != null)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pwController,
                          decoration: const InputDecoration(
                            hintText: 'Nuova password',
                          ),
                          obscureText: true,
                          validator: (v) => v == null || v.length < 6
                              ? 'Minimo 6 caratteri'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        BasicAppButton(
                          title: 'Aggiorna password',
                          onPressed: _onSubmit,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
