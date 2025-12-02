/// Clase centralizada que contiene todos los códigos de permisos del sistema.
/// 
/// Estos strings deben coincidir EXACTAMENTE con los códigos ('code') 
/// definidos en la base de datos del Backend.
class AppPermissions {
  // Constructor privado para evitar que la clase sea instanciada.
  // Solo queremos usar sus constantes estáticas.
  AppPermissions._();

  // ==========================================================
  // 1. ADMINISTRACIÓN (Usuarios y Roles)
  // ==========================================================
  
  /// Permite gestionar usuarios.
  static const String manageUsers = "manage:users";
  
  /// Permite gestionar roles y permisos.
  static const String manageRoles = "manage:roles";


  // ==========================================================
  // 2. PRODUCTOS E INVENTARIO
  // ==========================================================

  /// Permite registrar nuevos productos en el catálogo.
  static const String createProduct = "create:product";
  
  /// Permite ver el catálogo de productos.
  static const String readProducts = "read:products";
  
  /// Permite editar información de productos (precios, nombres).
  static const String updateProduct = "update:product";
  
  /// Permite eliminar productos del sistema.
  static const String deleteProduct = "delete:product";
  
  /// Permite ver el Kardex o historial de movimientos.
  static const String readMovements = "read:movements";


  // ==========================================================
  // 3. VENTAS
  // ==========================================================

  /// Permite registrar nuevas ventas.
  static const String createSale = "create:sale";

  /// Permite gestionar ventas.
  static const String manageSales = "confirm:sale";

  /// Permite ver el historial de ventas realizadas.
  static const String readSales = "read:sales";
  
  /// Permite anular una venta ya procesada.
  static const String cancelSale = "cancel:sale";


  // ==========================================================
  // 4. COMPRAS
  // ==========================================================

  /// Permite registrar entradas de mercancía por compra a proveedores.
  static const String createPurchase = "create:purchase";
  
  /// Permite ver el historial de compras.
  static const String readPurchases = "read:purchases";
  
  /// Permite anular una orden de compra.
  static const String cancelPurchase = "cancel:purchase";


  // ==========================================================
  // 5. ENTIDADES (Clientes y Proveedores)
  // ==========================================================

  // --- Clientes ---
  static const String manageClient = "manage:client";


  // --- Proveedores ---
  static const String manageProvider = "manage:provider";


  // ==========================================================
  // 6. CONFIGURACIÓN
  // ==========================================================

  /// Gestión de Categorías de productos.
  static const String manageCategories = "manage:categories";
  
  /// Gestión de Almacenes/Depósitos físicos.
  static const String manageDepots = "manage:depots";
  
  /// Gestión de tipos de pago (Efectivo, Tarjeta, etc.).
  static const String managePaymentTypes = "manage:paymenttypes";
  
  /// Ver historial de tasa de cambio (divisas).
  // static const String readExchangeRate = "read:exchangerate";


  // ==========================================================
  // 7. REPORTES Y SUPER ADMIN
  // ==========================================================

  /// Acceso al Dashboard de reportes y estadísticas.
  static const String viewReports = "view:reports";
  
  /// Permiso maestro ("Dios"). Tiene acceso a todo sin restricciones.
  static const String allPermissions = "all:permissions";
}