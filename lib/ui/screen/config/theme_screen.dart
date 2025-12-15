import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/providers/theme_provider.dart';

class ThemeScreen extends ConsumerStatefulWidget {
  const ThemeScreen({super.key});

  @override
  ConsumerState<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends ConsumerState<ThemeScreen> {
  String _theme = 'sistema';
  String _language = 'es';

  @override
  void initState() {
    super.initState();
    // Initialize state after build frame to access provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentMode = ref.read(themeProvider);
      setState(() {
        _theme = _modeToString(currentMode);
      });
    });
  }

  String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'oscuro';
      case ThemeMode.light:
        return 'claro';
      default:
        return 'sistema';
    }
  }

  ThemeMode _stringToMode(String s) {
    switch (s) {
      case 'oscuro':
        return ThemeMode.dark;
      case 'claro':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themes = ['sistema', 'claro', 'oscuro'];
    final languages = ['es', 'en'];

    return Scaffold(
      appBar: const AppBarApp(title: 'Interfaz y Tema', toolbarHeight: 64.0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropDownApp<String>(
                    labelText: 'Tema de la Aplicación',
                    prefixIcon: Icons.palette,
                    initialValue: _theme,
                    items: themes,
                    itemToString: (s) {
                      switch (s) {
                        case 'claro':
                          return 'Modo Claro';
                        case 'oscuro':
                          return 'Modo Oscuro';
                        default:
                          return 'Automático (del Sistema)';
                      }
                    },
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _theme = value);
                        // Optional: Apply immediately or wait for save?
                        // Applying immediately gives better feedback
                        ref
                            .read(themeProvider.notifier)
                            .setTheme(_stringToMode(value));
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // DropDownApp<String>(
                  //   labelText: 'Idioma del Sistema',
                  //   prefixIcon: Icons.language,
                  //   initialValue: _language,
                  //   items: languages,
                  //   itemToString: (s) => s == 'es' ? 'Español' : 'English',
                  //   onChanged: (value) {
                  //     if (value != null) setState(() => _language = value);
                  //   },
                  // ),

                  // const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tema actual: ${_theme == 'sistema' ? 'Automático' : (_theme == 'claro' ? 'Claro' : 'Oscuro')}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
