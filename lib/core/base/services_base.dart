abstract class ServicesInterface<T> {
  Future<List<T>> getAll();
  Future<T> getById(int id);
  /// Crea un recurso y devuelve el objeto creado según la respuesta del backend.
  Future<T> create(Map<String, dynamic> data);
  /// Actualiza un recurso y devuelve el recurso actualizado si el backend lo retorna.
  Future<T> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
  Future<void> deactivate(int id);
  Future<void> activate(int id);
}
