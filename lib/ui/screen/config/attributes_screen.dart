import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo de Atributos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Usamos un colorScheme para que PrimaryButtonApp encuentre los colores
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        // Estilos para que el TabBar se vea bien sobre blanco
      ),
      home: const AttributesScreen(),
    );
  }
}

// -------------------------------------------------------------------
// 0. CLASE SIMULADA (MOCK) DE AppColors
// (Necesaria porque tus widgets la usan)
// -------------------------------------------------------------------
class AppColors {
  static const Color background = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color secondary = Color(0xFFF0F0F0); // Gris claro
  static const Color border = Colors.grey;
  static const Color textPrimary = Colors.black;
}

// -------------------------------------------------------------------
// 1. PLANTILLA: PrimaryButtonApp
// -------------------------------------------------------------------
class PrimaryButtonApp extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final double maxWidth;

  const PrimaryButtonApp({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.maxWidth = 250,
  });

  @override
  Widget build(BuildContext context) {
    // Determina el tamaño del ícono para que el spinner lo iguale
    final iconSize = Theme.of(context).iconTheme.size ?? 24.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ElevatedButton.icon(
          // --- AQUÍ ESTÁ EL CAMBIO ---
          icon: isLoading
              ? SizedBox(
                  // 1. El spinner AHORA es el ícono
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                    strokeWidth: 3,
                  ),
                )
              : Icon(icon ?? Icons.save), // 2. El ícono normal

          label: Text(
            // 3. El texto SIEMPRE se muestra
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),

          // --- FIN DEL CAMBIO ---
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(64, 50),
          ),

          onPressed: isLoading ? null : onPressed,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 2. PLANTILLA: DropDownApp
// -------------------------------------------------------------------
class DropDownApp<ItemType> extends StatelessWidget {
  // 2. Usamos 'ItemType' para el valor, la lista y el onChanged
  final ItemType? initialValue;
  final List<ItemType> items;
  final ValueChanged<ItemType?>? onChanged;

  // 3. Esta función recibe un 'ItemType' y devuelve el String a mostrar
  final String Function(ItemType item) itemToString;

  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;

  const DropDownApp({
    super.key,
    this.initialValue,
    required this.items,
    required this.onChanged,
    required this.itemToString,
    required this.labelText,
    this.prefixIcon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    // 4. El Dropdown es de tipo 'ItemType'
    return DropdownButtonFormField<ItemType>(
      dropdownColor: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      iconSize: 24,
      menuMaxHeight: 500.0,
      isExpanded: true,
      decoration: InputDecoration(
        labelStyle: const TextStyle(
          fontSize: 16.0,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.secondary,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3.0, color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 3.0,
            color: AppColors.textSecondary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
      ),
      initialValue: initialValue,

      // 5. Mapeamos la lista de 'ItemType'
      items: items.map((ItemType item) {
        // 6. El DropdownMenuItem también es de tipo 'ItemType'
        return DropdownMenuItem<ItemType>(
          value: item,
          child: Text(
            // 7. Usamos la función para convertir el 'ItemType' a String
            itemToString(item),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}

// -------------------------------------------------------------------
// 3. PLANTILLA: SearchTextFieldApp
// -------------------------------------------------------------------
class SearchTextFieldApp extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String labelText;
  final String? hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;

  const SearchTextFieldApp({
    super.key,
    required this.onChanged,
    required this.labelText,
    this.hintText,
    this.prefixIcon = Icons.search, // Icono de búsqueda por defecto
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15.0, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.secondary,
        labelText: labelText, // Usa el parámetro
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, size: 20), // Usa el parámetro
        labelStyle: const TextStyle(
          fontSize: 14.0,
          color: AppColors.textSecondary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3.0, color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 3.0,
            color: AppColors.textSecondary,
          ),
        ),
        // Tu padding original era 'vertical: 0'
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      // 1. Simplemente notifica al padre del cambio
      onChanged: onChanged,
    );
  }
}

// -------------------------------------------------------------------
// 4. PLANTILLA: TextFieldApp
// -------------------------------------------------------------------
class TextFieldApp extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon; // Añadido para más flexibilidad (ej. contraseñas)
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const TextFieldApp({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.obscureText = false, // Añadido para contraseñas
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        fontSize: 15.0,
        color: AppColors.textPrimary, // Estilo del texto que escribes
      ),
      decoration: InputDecoration(
        labelStyle: const TextStyle(
          fontSize: 16.0,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.secondary,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
        suffixIcon: suffixIcon, // <-- AÑADIDO
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3.0, color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 3.0,
            color: AppColors.textSecondary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 5. PANTALLA PRINCIPAL: AttributesScreen
// (Ya no necesita imports locales)
// -------------------------------------------------------------------
class AttributesScreen extends StatelessWidget {
  const AttributesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // --- INICIO DE LA FUSIÓN DEL APPBAR ---

          // Estilos del AppBar (plantilla 5)
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            // Aseguramos que solo haga pop() si puede
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),

          // Contenido del AppBar (plantilla 6)
          title: const Text(
            'Atributos y Campos',
            // Estilo de texto (plantilla 5)
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Atributos (Variantes)', icon: Icon(Icons.style)),
              Tab(text: 'Campos Personalizados', icon: Icon(Icons.text_fields)),
            ],
          ),
          // --- FIN DE LA FUSIÓN DEL APPBAR ---
        ),
        body: const TabBarView(
          children: [
            GestionListaWidget(
              tipo: 'Atributo',
              initialItems: ['Talla', 'Color', 'Material'],
              icono: Icons.style,
            ),
            GestionListaWidget(
              tipo: 'Campo Personalizado',
              initialItems: ['N° de Serie', 'Fecha de Vencimiento'],
              icono: Icons.text_fields,
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 6. WIDGET DE GESTIÓN (usa los widgets de plantilla)
// -------------------------------------------------------------------
class GestionListaWidget extends StatefulWidget {
  final String tipo;
  final List<String> initialItems;
  final IconData icono;

  const GestionListaWidget({
    super.key,
    required this.tipo,
    required this.initialItems,
    required this.icono,
  });

  @override
  State<GestionListaWidget> createState() => _GestionListaWidgetState();
}

class _GestionListaWidgetState extends State<GestionListaWidget> {
  late List<String> _items;
  late List<String> _filtered;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
    _filtered = List.from(_items);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _items.where((e) => e.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _agregarItem() async {
    final TextEditingController controller = TextEditingController();
    String? selectedTipo; // ejemplo para DropDownApp si quieres usarlo

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Agregar ${widget.tipo}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // USA LA PLANTILLA TextFieldApp
              TextFieldApp(
                controller: controller,
                labelText: widget.tipo,
                prefixIcon: widget.icono,
              ),
              const SizedBox(height: 12),

              // USA LA PLANTILLA DropDownApp
              DropDownApp<String>(
                initialValue: selectedTipo,
                items: const ['Opción A', 'Opción B'],
                itemToString: (s) => s,
                labelText: 'Categoría',
                onChanged: (v) {
                  selectedTipo = v;
                },
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            // USA LA PLANTILLA PrimaryButtonApp
            PrimaryButtonApp(
              text: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
              maxWidth: 130,
            ),
            // USA LA PLANTILLA PrimaryButtonApp
            PrimaryButtonApp(
              text: 'Agregar',
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _items.add(text);
                    _onSearchChanged(); // Actualiza el filtro
                  });
                }
                Navigator.of(context).pop();
              },
              maxWidth: 130,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            // USA LA PLANTILLA SearchTextFieldApp
            child: SearchTextFieldApp(
              controller: _searchController,
              labelText: 'Buscar ${widget.tipo.toLowerCase()}',
              onChanged: (_) {}, // el controlador ya actualiza la lista
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                return ListTile(
                  leading: Icon(widget.icono),
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // editar -> puedes implementar un diálogo similar
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // USA LA PLANTILLA PrimaryButtonApp
      floatingActionButton: PrimaryButtonApp(
        text: 'Agregar ${widget.tipo}',
        icon: Icons.add,
        onPressed: _agregarItem,
        maxWidth: 220,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
