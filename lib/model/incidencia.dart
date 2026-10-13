class Incidencia {
  /// Valores aprobados por el cliente (FEAT-001).
  static const List<String> prioridades = ['Baja', 'Media', 'Alta'];
  static const String prioridadPorDefecto = 'Media';

  /// Devuelve una prioridad válida; cualquier valor ausente o desconocido
  /// (p. ej. registros antiguos sin el campo) se convierte en 'Media'.
  static String normalizarPrioridad(Object? valor) {
    final texto = valor?.toString().trim() ?? '';
    for (final p in prioridades) {
      if (p.toLowerCase() == texto.toLowerCase()) return p;
    }
    return prioridadPorDefecto;
  }

  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  String prioridad;

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    this.prioridad = prioridadPorDefecto,
  });

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: m['estado']?.toString() ?? 'Pendiente',
      fecha: m['fecha']?.toString() ?? '',
      prioridad: normalizarPrioridad(m['prioridad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      'prioridad': prioridad,
    };
  }
}
