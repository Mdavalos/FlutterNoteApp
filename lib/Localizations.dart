import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart' show SynchronousFuture;

class DemoLocalizations {
  DemoLocalizations(this.locale);
  final Locale locale;
  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'titleNote': 'Notes',
      'newNote': 'New Note',
      'untitledNote':
          'Untitled Note',
      'hintTextNote': 'Type your notes here',
      'noteTitle': 'Title'
    },
    'es': {
      'titleNote': 'Notas',
      'newNote': 'Nueva Nota',
      'untitledNote':
          'Nota Sin Título',
      'hintTextNote': 'Escribir sus notas aquí',
      'noteTitle': 'Título'
    },
  };
  String get titleNote {
    return _localizedValues[locale.languageCode]['titleNote'];
  }

  String get newNote {
    return _localizedValues[locale.languageCode]['newNote'];
  }

  String get untitledNote {
    return _localizedValues[locale.languageCode]['untitledNote'];
  }

  String get newNoteTitle {
    return _localizedValues[locale.languageCode]['newNoteTitle'];
  }

  String get hintTextNote {
    return _localizedValues[locale.languageCode]['hintTextNote'];
  }

  String get noteTitle {
    return _localizedValues[locale.languageCode]['noteTitle'];
  }
}

class DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return new SynchronousFuture<DemoLocalizations>(
        new DemoLocalizations(locale));
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
