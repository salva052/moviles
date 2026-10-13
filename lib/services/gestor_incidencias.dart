import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  }

  static const String todosEstados = 'Todos';
  static const String todasPrioridades = 'Todas';

  /// Aplica juntas todas las condiciones activas (FEAT-002): texto, estado y prioridad.
  /// [estado] = 'Todos' y [prioridad] = 'Todas' significan "sin filtro".
  List<Incidencia> buscar(
    String texto, {
    String estado = todosEstados,
    String prioridad = todasPrioridades,
  }) {
    // BUG-002: antes era contains() sensible a mayúsculas, solo en título y sin trim.
    final consulta = texto.trim().toLowerCase();
    return incidencias.where((x) {
      if (estado != todosEstados && x.estado != estado) return false;
      if (prioridad != todasPrioridades && x.prioridad != prioridad) return false;
      if (consulta.isEmpty) return true;
      return x.titulo.toLowerCase().contains(consulta) ||
          x.descripcion.toLowerCase().contains(consulta);
    }).toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    // BUG-003: antes 'Pendiente' usaba un contador guardado que no se actualizaba
    // al cambiar estados. Ahora siempre se calcula sobre la lista actual completa.
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    final item = porId(id);
    if (item == null) return;
    final anterior = item.estado;
    item.estado = estado;
    try {
      // BUG-001: antes solo se modificaba la lista en memoria y nunca se guardaba.
      await datos.guardar(incidencias);
    } catch (e) {
      item.estado = anterior; // no dejar en pantalla algo que no se guardó
      rethrow;
    }
  }

  Future<void> cambiarPrioridad(String id, String prioridad) async {
    final item = porId(id);
    if (item == null) return;
    final anterior = item.prioridad;
    item.prioridad = Incidencia.normalizarPrioridad(prioridad);
    try {
      await datos.guardar(incidencias);
    } catch (e) {
      item.prioridad = anterior;
      rethrow;
    }
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria,
      [String prioridad = Incidencia.prioridadPorDefecto]) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      prioridad: Incidencia.normalizarPrioridad(prioridad),
      fecha: DateTime.now().toIso8601String().split('T').first,
    );
    incidencias.insert(0, nuevo);
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
