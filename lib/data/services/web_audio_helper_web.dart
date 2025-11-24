// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

void playWebBeep() {
  try {
    js.context.callMethod('eval', ['''
      (function() {
        try {
          var audioContext = new (window.AudioContext || window.webkitAudioContext);
          var oscillator = audioContext.createOscillator();
          var gainNode = audioContext.createGain();
          oscillator.connect(gainNode);
          gainNode.connect(audioContext.destination);
          oscillator.frequency.value = 1000;
          oscillator.type = 'square';
          gainNode.gain.value = 0.5;
          oscillator.start(0);
          setTimeout(function() { oscillator.stop(0); }, 200);
        } catch(e) { console.error('Error generando beep:', e); }
      })();
    ''']);
  } catch (_) {}
}