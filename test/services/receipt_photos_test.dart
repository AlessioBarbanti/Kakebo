import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/services/receipt_scanner.dart';

void main() {
  late Directory root;
  setUp(() {
    root = Directory.systemTemp.createTempSync('kakebo');
    ReceiptPhotos.dir = Directory('${root.path}/receipts');
  });
  tearDown(() {
    ReceiptPhotos.dir = null;
    root.deleteSync(recursive: true);
  });

  test("a photo is copied into the app's folder under a name of its own, its kind kept", () async {
    final picked = File('${root.path}/scaled_IMG_1234.JPG')..writeAsBytesSync([1, 2, 3]);
    final name = await ReceiptPhotos.keep(picked.path);
    expect(name, endsWith('.jpg'));
    expect(ReceiptPhotos.file(name)!.readAsBytesSync(), [1, 2, 3]);
    expect(await ReceiptPhotos.keep(picked.path), isNot(name), reason: 'a second receipt never overwrites the first');
  });

  test('photos no expense points to are deleted; the kept ones and any newer than the call stay', () async {
    final folder = ReceiptPhotos.dir!..createSync();
    for (final n in ['kept.jpg', 'orphan.jpg']) {
      File('${folder.path}/$n')
        ..writeAsBytesSync([0])
        ..setLastModifiedSync(DateTime.now().subtract(const Duration(minutes: 1)));
    }
    File('${folder.path}/just_read.jpg').writeAsBytesSync([0]); // a receipt read while the app starts
    File('${folder.path}/just_read.jpg').setLastModifiedSync(DateTime.now().add(const Duration(minutes: 1)));
    await ReceiptPhotos.clean({'kept.jpg'});
    expect({for (final f in folder.listSync()) f.uri.pathSegments.last}, {'kept.jpg', 'just_read.jpg'});
  });

  test('nothing to clean before the first receipt, or when the folder is unknown', () async {
    await ReceiptPhotos.clean({});
    ReceiptPhotos.dir = null;
    await ReceiptPhotos.clean({});
    expect(ReceiptPhotos.file('a.jpg'), isNull);
  });
}
