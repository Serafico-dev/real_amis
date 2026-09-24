import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

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
                const Text(
                  'Ultimo aggiornamento: 24 settembre 2026',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
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
                _SectionTitle(text: 'Titolare del trattamento', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'Il titolare del trattamento dei dati raccolti tramite '
                      'l’applicazione "Real Amis" è la società/associazione '
                      'sportiva Real Amis. Per qualsiasi richiesta relativa alla '
                      'presente Privacy Policy o ai dati trattati, puoi scrivere a '
                      'realamis.app@gmail.com.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: 'Dati che raccogliamo', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      '• Email e password, per creare e accedere al tuo account '
                      '(la password è gestita in modo sicuro dal nostro fornitore '
                      'di autenticazione e non è mai visibile a noi in chiaro)\n'
                      '• Stato di amministratore, per determinare se il tuo account '
                      'può modificare i contenuti del club\n'
                      '• Foto profilo dei giocatori, solo se un amministratore le '
                      'carica, previa autorizzazione esplicita all’accesso alla '
                      'libreria foto del dispositivo\n'
                      '• Dati di rosa, partite e statistiche (nome, ruolo, eventuale '
                      'data di nascita dei giocatori, risultati)\n\n'
                      'Non raccogliamo dati di localizzazione, non utilizziamo '
                      'strumenti pubblicitari o di profilazione, e non vendiamo né '
                      'condividiamo i tuoi dati con terze parti a scopo commerciale.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  text: 'Dati di terzi (giocatori) inseriti dagli amministratori',
                  color: titleColor,
                ),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'Alcuni dati in app (nome, foto, eventuale data di nascita '
                      'dei giocatori) possono riguardare persone diverse '
                      'dall’utente che li inserisce, nell’ambito della normale '
                      'gestione di una rosa sportiva amatoriale, sulla base del '
                      'legittimo interesse del club a organizzare la propria '
                      'attività. Se sei un giocatore (o il genitore/tutore di un '
                      'giocatore minorenne) e vuoi che i tuoi dati vengano rimossi '
                      'o corretti, scrivi a realamis.app@gmail.com.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: 'Dove sono conservati i dati', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'I dati sono ospitati su server del nostro fornitore di '
                      'infrastruttura (Supabase) situati all’interno dell’Unione '
                      'Europea, e le comunicazioni tra l’app e i server avvengono '
                      'sempre tramite connessione cifrata (HTTPS). L’accesso ai '
                      'dati è protetto da policy di sicurezza che permettono le '
                      'operazioni di modifica solo agli account amministratore '
                      'autorizzati.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  text: 'Per quanto tempo conserviamo i dati',
                  color: titleColor,
                ),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'I dati del tuo account restano archiviati finché l’account '
                      'rimane attivo. Puoi eliminare definitivamente il tuo account '
                      'e i dati ad esso collegati in qualsiasi momento dall’app, '
                      'da Impostazioni → Elimina account: l’operazione è immediata '
                      'e irreversibile.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: 'I tuoi diritti', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'Hai diritto ad accedere ai dati che ti riguardano, chiederne '
                      'la rettifica, la cancellazione (anche direttamente dall’app), '
                      'opporti o limitarne il trattamento, richiederne la '
                      'portabilità e proporre reclamo al Garante per la protezione '
                      'dei dati personali. Per esercitare questi diritti scrivi a '
                      'realamis.app@gmail.com.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: 'Minori', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'L’app non è pensata per la creazione di account da parte di '
                      'minori di 14 anni. I dati di eventuali giocatori minorenni '
                      'presenti nella rosa sportiva sono inseriti e gestiti '
                      'esclusivamente dagli amministratori del club, come '
                      'descritto sopra.',
                ),
                const SizedBox(height: 24),
                _SectionTitle(text: 'Contatti', color: titleColor),
                _SectionBody(
                  color: bodyColor,
                  text:
                      'Per qualsiasi domanda sui Termini o sulla Privacy, puoi '
                      'contattarci scrivendo a realamis.app@gmail.com.',
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(Constants.privacyPolicyUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Apri la versione online aggiornata'),
                  ),
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
