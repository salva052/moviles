import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';

Incidencia _inc(String id, String titulo, String desc, String estado,
    [String prioridad = 'Media']) {
  return Incidencia(
    id: id,
    titulo: titulo,
    descripcion: desc,
    cliente: 'Cliente ficticio',
    categoria: 'Redes',
    estado: estado,
    fecha: '2026-10-12',
    prioridad: prioridad,
  );
}

void main() {
  test('Una incidencia antigua puede convertirse desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
    });
    expect(registro.id, 'INC-DEMO');
    expect(registro.toJson()['estado'], 'Pendiente');
  });

  group('FEAT-001 prioridad', () {
    test('registro sin prioridad usa Media', () {
      final r = Incidencia.desdeJson({'id': 'A', 'titulo': 't'});
      expect(r.prioridad, 'Media');
      expect(r.toJson()['prioridad'], 'Media');
    });

    test('valores invalidos se normalizan a Media y los validos se conservan', () {
      expect(Incidencia.desdeJson({'prioridad': 'Urgente'}).prioridad, 'Media');
      expect(Incidencia.desdeJson({'prioridad': null}).prioridad, 'Media');
      expect(Incidencia.desdeJson({'prioridad': 'Alta'}).prioridad, 'Alta');
      expect(Incidencia.desdeJson({'prioridad': 'baja'}).prioridad, 'Baja');
    });

    test('ida y vuelta por JSON conserva la prioridad', () {
      final r = _inc('A', 't', 'd', 'Pendiente', 'Alta');
      expect(Incidencia.desdeJson(r.toJson()).prioridad, 'Alta');
    });
  });

  group('Busqueda y filtros (BUG-002, FEAT-002)', () {
    final g = GestorIncidencias();
    setUpAll(() {
      g.incidencias = [
        _inc('1', 'WiFi intermitente en recepción', 'Se desconecta', 'En proceso', 'Alta'),
        _inc('2', 'Configuración de VPN', 'No puede establecer túnel seguro', 'En proceso', 'Media'),
        _inc('3', 'Impresora sin respuesta', 'Cola detenida', 'Pendiente', 'Alta'),
        _inc('4', 'Cambio de teclado', 'Caracteres duplicados', 'Resuelta', 'Baja'),
      ];
    });

    test('ignora mayusculas/minusculas', () {
      expect(g.buscar('wifi').map((x) => x.id), ['1']);
      expect(g.buscar('WiFi').map((x) => x.id), ['1']);
    });

    test('busca en la descripcion', () {
      expect(g.buscar('túnel').map((x) => x.id), ['2']);
    });

    test('ignora espacios al inicio y al final', () {
      expect(g.buscar('  wifi  ').map((x) => x.id), ['1']);
    });

    test('sin texto ni filtros devuelve todo', () {
      expect(g.buscar('   ').length, 4);
    });

    test('filtro de estado y de prioridad', () {
      expect(g.buscar('', estado: 'En proceso').length, 2);
      expect(g.buscar('', prioridad: 'Alta').length, 2);
    });

    test('texto + estado + prioridad se combinan', () {
      final r = g.buscar('impresora', estado: 'Pendiente', prioridad: 'Alta');
      expect(r.map((x) => x.id), ['3']);
      expect(g.buscar('impresora', estado: 'Resuelta'), isEmpty);
    });
  });

  group('BUG-003 totales', () {
    test('contar refleja los cambios de estado en memoria', () {
      final g = GestorIncidencias();
      g.incidencias = [
        _inc('1', 'a', 'a', 'Pendiente'),
        _inc('2', 'b', 'b', 'Pendiente'),
        _inc('3', 'c', 'c', 'Resuelta'),
      ];
      expect(g.contar('Pendiente'), 2);
      g.incidencias[0].estado = 'Resuelta';
      expect(g.contar('Pendiente'), 1);
      expect(g.contar('Resuelta'), 2);
    });
  });
}
