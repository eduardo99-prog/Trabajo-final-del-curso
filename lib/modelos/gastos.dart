import 'package:hive/hive.dart';

class Gasto {
  final String concepto;
  final double monto;
  final String categoria;
  final DateTime fecha;

  Gasto({
    required this.concepto,
    required this.monto,
    required this.categoria,
    required this.fecha,
  });
}

  class GastoAdapter extends TypeAdapter<Gasto> {
    @override
    final int typeId = 0;

    @override
    Gasto read(BinaryReader reader) {
      final cantidadCampos = reader.readByte();
      final campos = <int, dynamic> {
        for(int i = 0; i < cantidadCampos; i++)
          reader.readByte(): reader.read(),
      };
      return Gasto(
        concepto: campos[0] as String,
        monto: campos[1] as double,
        categoria: campos[2] as String,
        fecha: campos[3] as DateTime,
      );
    }

    @override
    void write(BinaryWriter writer, Gasto obj) {
      writer
        ..writeByte(4)
        ..writeByte(0)
        ..write(obj.concepto)
        ..writeByte(1)
        ..write(obj.monto)
        ..writeByte(2)
        ..write(obj.categoria)
        ..writeByte(3)
        ..write(obj.fecha);
    }

  }