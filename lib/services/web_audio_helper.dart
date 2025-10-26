// Helper para reproducir audio en Flutter Web
// Este archivo solo se usa en la plataforma web

import 'dart:js' as js;

/// Reproduce un beep usando Web Audio API del navegador
void playWebBeep() {
  try {
    js.context.callMethod('eval', ['''
      (function() {
        try {
          var audioContext = new (window.AudioContext || window.webkitAudioContext)();
          var oscillator = audioContext.createOscillator();
          var gainNode = audioContext.createGain();
          
          oscillator.connect(gainNode);
          gainNode.connect(audioContext.destination);
          
          oscillator.frequency.value = 1000; // 1000 Hz
          oscillator.type = 'square'; // Onda cuadrada
          gainNode.gain.value = 0.5; // Volumen 50%
          
          oscillator.start(0);
          setTimeout(function() {
            oscillator.stop(0);
          }, 200);
        } catch(e) {
          console.error('Error generando beep:', e);
        }
      })();
    ''']);
  } catch (e) {
    print('Error en playWebBeep: $e');
  }
}

