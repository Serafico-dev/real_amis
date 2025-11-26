import 'package:flutter/material.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';

class HistoryPage extends StatelessWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => HistoryPage());
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarNoNav(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Il club',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec dignissim justo sed faucibus dictum. Suspendisse pellentesque id nunc et rhoncus. Sed non tincidunt purus. Sed faucibus, est eget egestas euismod, dui quam varius quam, et aliquam lectus sapien non felis. Etiam viverra ligula at arcu laoreet, vel ultricies metus scelerisque. Etiam condimentum, libero ac congue sagittis, nisi erat sollicitudin purus, id elementum dolor sapien a diam. Maecenas euismod dolor imperdiet commodo tincidunt. Duis eu porttitor lacus, vitae lobortis diam. Cras non urna quam. Proin ut lectus dolor. Donec vel est dolor. Sed quis nulla in augue dignissim cursus eget a velit. Nullam hendrerit tempor neque vitae faucibus.',
              ),
              SizedBox(height: 40),
              Text(
                'Il presidente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Image.network(
                'https://rewbgtmikocofuylzrov.supabase.co/storage/v1/object/public/player_image/IMG_7238.png',
              ),
              SizedBox(height: 20),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec dignissim justo sed faucibus dictum. Suspendisse pellentesque id nunc et rhoncus. Sed non tincidunt purus. Sed faucibus, est eget egestas euismod, dui quam varius quam, et aliquam lectus sapien non felis. Etiam viverra ligula at arcu laoreet, vel ultricies metus scelerisque. Etiam condimentum, libero ac congue sagittis, nisi erat sollicitudin purus, id elementum dolor sapien a diam. Maecenas euismod dolor imperdiet commodo tincidunt. Duis eu porttitor lacus, vitae lobortis diam. Cras non urna quam. Proin ut lectus dolor. Donec vel est dolor. Sed quis nulla in augue dignissim cursus eget a velit. Nullam hendrerit tempor neque vitae faucibus.',
              ),
              SizedBox(height: 40),
              Text(
                'La squadra',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: 20),
              Image.network(
                'https://rewbgtmikocofuylzrov.supabase.co/storage/v1/object/public/player_image/IMG_2404.JPG',
              ),
              SizedBox(height: 20),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec dignissim justo sed faucibus dictum. Suspendisse pellentesque id nunc et rhoncus. Sed non tincidunt purus. Sed faucibus, est eget egestas euismod, dui quam varius quam, et aliquam lectus sapien non felis. Etiam viverra ligula at arcu laoreet, vel ultricies metus scelerisque. Etiam condimentum, libero ac congue sagittis, nisi erat sollicitudin purus, id elementum dolor sapien a diam. Maecenas euismod dolor imperdiet commodo tincidunt. Duis eu porttitor lacus, vitae lobortis diam. Cras non urna quam. Proin ut lectus dolor. Donec vel est dolor. Sed quis nulla in augue dignissim cursus eget a velit. Nullam hendrerit tempor neque vitae faucibus.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
