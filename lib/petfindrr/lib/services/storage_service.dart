import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadPetImage(File image, String sellerId) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('pets/$sellerId/$fileName');
    
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<List<String>> uploadMultiplePetImages(
    List<File> images,
    String sellerId,
  ) async {
    final urls = <String>[];
    for (final image in images) {
      final url = await uploadPetImage(image, sellerId);
      urls.add(url);
    }
    return urls;
  }
}