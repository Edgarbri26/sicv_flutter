/// Centraliza los 'tokens' de dimensionamiento y espaciado del sistema de diseño.
///
/// Esta clase previene el uso de valores numéricos 'mágicos' (hard-coded),
/// asegurando una UI consistente y facilitando futuros ajustes de diseño.
///
/// El constructor `_` previene la instanciación de esta clase.
class AppSizes {
  AppSizes._();

  // 🔠 Tamaños de fuente

  /// 45.0 - Títulos de módulos y pantallas principales. El más alto en la jerarquía.
  static const double displayL = 45.0;

  /// 36.0 - Encabezados secundarios de alto impacto.
  static const double displayM = 36.0;

  /// 32.0 - Subtítulos principales, complementan a [displayL] o [displayM].
  static const double headlineL = 32.0;

  /// 28.0 - Títulos para secciones internas o grupos de contenido.
  static const double headlineM = 28.0;

  /// 27.0 - Texto principal en formularios, párrafos de contenido y lectura principal.
  static const double bodyL = 27.0;

  /// 18.0 - Texto estándar para botones, etiquetas de formularios y cuerpo secundario.
  static const double bodyM = 18.0;

  /// 12.0 - Texto auxiliar. Ideal para tooltips, mensajes de validación y notas al pie.
  static const double bodyS = 12.0;

  /// 10.0 - Texto muy pequeño. Usado en Chips, Badges y estados.
  static const double labelS = 10.0;

  // 📏 Espaciados
  // Usados para Padding, Margin y SizedBox para mantener un ritmo vertical y horizontal.

  /// 2.0 - Espaciado mínimo, para ajustes finos.
  static const double spacingXXS = 2.0;

  /// 4.0 - Espaciado extra pequeño.
  static const double spacingXS = 4.0;

  /// 8.0 - Espaciado pequeño. Comúnmente usado entre elementos relacionados.
  static const double spacingS = 8.0;

  /// 16.0 - Espaciado mediano. El 'estándar' más común para separar componentes.
  static const double spacingM = 16.0;

  /// 24.0 - Espaciado grande. Para separar grupos de componentes.
  static const double spacingL = 24.0;

  /// 32.0 - Espaciado extra grande.
  static const double spacingXL = 32.0;

  /// 48.0 - Espaciado máximo. Usado para márgenes de pantalla o secciones principales.
  static const double spacingXXL = 48.0;

  // 🧱 Bordes y radios

  /// 4.0 - Radio de borde pequeño. Para elementos como chips o botones internos.
  static const double borderRadiusS = 4.0;

  /// 8.0 - Radio de borde mediano. Estándar para Tarjetas (Cards) y campos de texto.
  static const double borderRadiusM = 8.0;

  /// 16.0 - Radio de borde grande. Usado para Modales (Dialogs) o contenedores de sección.
  static const double borderRadiusL = 16.0;

  /// 1.0 - Grosor de borde estándar. Para `OutlineInputBorder` o `Border`.
  static const double borderWidth = 1.0;

  // 📐 Alturas estándar

  /// 48.0 - Altura estándar para botones (Ej: `ElevatedButton`). Cumple con accesibilidad.
  static const double buttonHeight = 48.0;

  /// 56.0 - Altura estándar para campos de entrada (Ej: `TextFormField`).
  static const double inputHeight = 56.0;

  /// 64.0 - Altura estándar para la `AppBar`.
  static const double appBarHeight = 64.0;

  /// 120.0 - Altura base para tarjetas (Cards) de contenido.
  static const double cardHeight = 120.0;

  // 📦 Tamaños de íconos

  /// 16.0 - Tamaño de ícono pequeño. Usado inline, en chips o texto.
  static const double iconS = 16.0;

  /// 24.0 - Tamaño de ícono estándar. El más común (Ej: `AppBar`, `BottomNavigationBar`).
  static const double iconM = 24.0;

  /// 32.0 - Tamaño de ícono grande. Para íconos de cabecera o decorativos.
  static const double iconL = 32.0;


  /// 680.0 - breakpoint estándar para la pantalla.
  static const double breakpoint = 680.0;

  /// 800.0 - breakpoint estándar para la pantalla.
  static const double breakpointTablet = 800.0;

  /// 1200.0 - breakpoint estándar para la pantalla.
  static const double breakpointDesktop = 1200.0;
}
