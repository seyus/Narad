
abstract class CloudMessageRepository {
  Future<String> getToken();
  void configure(context);
}

typedef void MessageHandler(String senderId);