import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart';

/// Triggers real file download in web browser or saves to disk.
void downloadFile(String filename, List<int> bytes, {String mimeType = 'application/octet-stream'}) {
  downloadBytesImpl(filename, bytes, mimeType: mimeType);
}
