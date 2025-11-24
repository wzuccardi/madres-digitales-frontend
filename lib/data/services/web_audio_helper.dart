// Wrapper con import condicional para soportar web y no-web
import 'web_audio_helper_stub.dart' if (dart.library.html) 'web_audio_helper_web.dart' as impl;

void playWebBeep() => impl.playWebBeep();