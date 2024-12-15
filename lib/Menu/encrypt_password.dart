import 'dart:convert';
import 'package:crypto/crypto.dart';
class EncryptPassword {
    static toMD5(String passwords) {
    var bytes = utf8.encode(passwords);
    // create the md5 hash
    var pwd = md5.convert(bytes);
    return pwd.toString();
  }
}
