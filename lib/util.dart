import 'package:encrypt/encrypt.dart';
import 'dart:convert';

const String KeyStr = '1234567812345key';
const String IVStr = 'iv12345678123456';

String aesEncode(String plainText) {
  return encrypt().encrypt(plainText).base64;
}

String aesDecode(String cipherText) {
  return encrypt().decrypt(Encrypted(base64Decode(cipherText)));
}

Encrypter encrypt() {
  final key = Key.fromUtf8(KeyStr);
  final iv = IV.fromUtf8(IVStr);
  return Encrypter(AES(key, iv, mode: AESMode.cbc));
}
