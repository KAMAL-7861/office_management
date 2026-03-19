import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageRepository {}

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorage storage;

  StorageRepositoryImpl({required this.storage});
}
