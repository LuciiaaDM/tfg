import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/post_detail_screen.dart';
import 'models/post_model.dart';
import 'screens/create_incidence_screen.dart'; 
import 'screens/incidences_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/my_posts_screen.dart';
import 'screens/my_reservations_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/edit_review_screen.dart';
import 'models/reservation_model.dart';
import 'screens/reservation_detail_screen.dart';
import 'screens/add_balance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Journey',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/create': (context) => CreateScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/chats': (context) => ChatsScreen(),
        '/createIncidence': (context) => CreateIncidenceScreen(), 
        '/incidences': (context) => IncidencesScreen(),
        '/editProfile': (context) => ProfileEditScreen(),
        '/myPosts': (context) => MyPostsScreen(),
        '/myReservations': (context) => MyReservationsScreen(),
        '/saved': (context) => SavedScreen(),
        '/addBalance': (context) => AddBalanceScreen(),
        '/editReview': (context) => EditReviewScreen(post: ModalRoute.of(context)!.settings.arguments as Post),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/postDetail') {
          final post = settings.arguments as Post;
          return MaterialPageRoute(
            builder: (context) {
              return PostDetailScreen(post: post);
            },
          );
        } else if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>;
          final chatId = args['chatId'] as String;
          final recipientName = args['recipientName'] as String;
          return MaterialPageRoute(
            builder: (context) {
              return ChatScreen(chatId: chatId, recipientName: recipientName);
            },
          );
        } else if (settings.name == '/reservationDetail') {
          final reservation = settings.arguments as Reservation;
          return MaterialPageRoute(
            builder: (context) {
              return ReservationDetailScreen(reservation: reservation);
            },
          );
        }
        return null;
      },
    );
  }
}
