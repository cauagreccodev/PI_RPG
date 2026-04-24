import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Future<Db> connect() async {
    var db = await Db.create("mongodb+srv://cauagrecco11_db_user:270609@rpg-puc-cluster.cobh8by.mongodb.net/?appName=RPG-PUC-Cluster");

    await db.open();
    print("Conexão com Banco de Dados RPG realizada com sucesso!!!");

    return db;
  }
}
