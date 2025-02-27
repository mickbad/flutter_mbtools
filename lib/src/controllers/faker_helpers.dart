import 'package:http/http.dart';

///
/// classe faker qui ne sert qu'à bien exécuter le code pour le web
/// et faire fonctionner pocketbase en realtime
///

enum RequestMode { cors, sameOrigin, navigate }

class FetchClient extends BaseClient {
  FetchClient({RequestMode mode = RequestMode.cors});

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    // TODO: implement send
    throw UnimplementedError();
  }
}
