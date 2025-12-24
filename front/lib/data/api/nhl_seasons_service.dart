import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'nhl_seasons_service.g.dart';

@RestApi()
abstract class NhlSeasonsService {
  factory NhlSeasonsService(Dio dio, {String baseUrl}) = _NhlSeasonsService;

  @GET('/season')
  Future<List<int>> getSeasons();
}
