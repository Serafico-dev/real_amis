import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final titleColor = isDark
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;
    final bodyColor = isDark
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBarYesNav(title: const Text('Termini e Privacy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(text: 'Termini e Condizioni', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'Utilizzando questa applicazione accetti i presenti '
                      'Termini e Condizioni. L’app è fornita "così com’è", '
                      'senza garanzie di alcun tipo, esplicite o implicite.\n\n'
                      'L’utente è responsabile dell’uso corretto dell’applicazione '
                      'e dei contenuti inseriti. È vietato utilizzare il servizio '
                      'per scopi illegali o non autorizzati.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: 'Privacy Policy', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'La tua privacy è importante per noi. I dati personali '
                      'raccolti vengono utilizzati esclusivamente per fornire '
                      'le funzionalità dell’app e migliorare l’esperienza utente.\n\n'
                      'I dati non vengono condivisi con terze parti senza il tuo '
                      'consenso, salvo nei casi previsti dalla legge.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: 'Dati raccolti', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      '• Informazioni di account (email)\n'
                      '• Dati inseriti dall’utente\n'
                      '• Informazioni tecniche anonime per il corretto '
                      'funzionamento del servizio',
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: 'Contatti', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'Per qualsiasi domanda sui Termini o sulla Privacy, '
                      'puoi contattarci tramite la sezione Supporto nelle impostazioni.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionTitle({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionBody({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, height: 1.5, color: color),
      ),
    );
  }
}
