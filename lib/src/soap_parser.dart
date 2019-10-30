import 'dart:ffi';
import 'package:soap/soap_parser.dart';
import 'package:xml/xml.dart' as xml;

class SoapParser {
  final dynamic values;
  final Version version;
  final Map<String, String> namespaces;
  final Map<Type, SoapNamespaceMap> maps;
  final List<SoapHeaderElement> header;
  final String serviceKey;

  static Map<Type, SoapSerializer> serializers = {
    DateTime: SoapDateTimeSerializer('ddMMyyyy'),
    int: SoapIntSerializer(),
    double: SoapDoubleSerializer(),
  };

  xml.XmlDocument _document;
  String _envelopeKey = 'soapenv';

  SoapParser.parse(
    String method, {
    this.values = null,
    this.serviceKey = 'service',
    this.maps = const {},
    this.namespaces = const {},
    this.header = const [],
    this.version = Version.Soap1_1,
  }) {
    var namespaces = <String, String>{
      '$_envelopeKey': _getSoapUrl(),
    };

    namespaces.addAll(this.namespaces);

    maps.forEach((key, value) {
      namespaces.putIfAbsent(value.key, () => value.uri);
    });

    if (version == Version.Soap1_2) {
      namespaces.putIfAbsent('$_envelopeKey:encodingStyle', () => "http://www.w3.org/2003/05/soap-encoding");
    }

    var builder = new xml.XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('$_envelopeKey:Envelope', namespaces: _reverseMapKeyValue(namespaces), nest: () {
      builder.element('$_envelopeKey:Header', nest: () => _parseNode(builder, header));
      builder.element('$_envelopeKey:Body', nest: () {
        if (method != null && method.isNotEmpty) {
          builder.element('$serviceKey:$method', nest: () => _parseNode(builder, values));
        } else {
          _parseNode(builder, values);
        }
      });
    });

    _document = builder.build();
  }

  void _parseNode(xml.XmlBuilder builder, dynamic instance) {
    if (instance == null) return;

    if (instance is SoapElement) {
      _parseElement(builder, instance);
    } else if (instance is Map<String, dynamic>) {
      instance.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          builder.element('$serviceKey:$key', nest: () => _parseNode(builder, value));
        } else {
          if (value is Iterable<int>) {
            _parseGenericTypedList<int>(builder, key, value);
          } else if (value is Iterable<double>) {
            _parseGenericTypedList<double>(builder, key, value);
          } else if (value is Iterable<String>) {
            _parseGenericTypedList<String>(builder, key, value);
          } else if (value is Iterable<bool>) {
            _parseGenericTypedList<bool>(builder, key, value);
          } else if (value is Iterable<Float>) {
            _parseGenericTypedList<Float>(builder, key, value);
          } else if (value is Iterable) {
            _parseList(builder, key, value);
          } else {
            builder.element('$serviceKey:$key', nest: () {
              if (value != null) {
                var serializer = SoapParser.serializers.containsKey(value.runtimeType) ? SoapParser.serializers[value.runtimeType] : null;
                builder.text(serializer != null ? serializer.serialize(value) : value.toString());
              }
            });
          }
        }
      });
    } else if (instance is List<SoapHeaderElement>) {
      instance.forEach((header) => _parseHeader(builder, header));
    }
  }

  String _getSoapUrl() {
    if (version == Version.Soap1_1) {
      return "http://schemas.xmlsoap.org/soap/envelope/";
    }

    return "http://www.w3.org/2003/05/soap-envelope/";
  }

  Map<String, String> _reverseMapKeyValue(Map<String, String> source) {
    Map<String, String> result = {};

    source.forEach((key, value) {
      result.putIfAbsent(value, () => key);
    });

    return result;
  }

  void _parseHeader(xml.XmlBuilder builder, SoapHeaderElement header) {
    var attributes = header.namespace.isEmpty ? {} : <String, String>{'xmlns': header.namespace};

    if (header.mustUnderstand != null) {
      attributes.putIfAbsent('mustUnderstand', () => header.mustUnderstand.toString());
    }

    if (header.encodingStyle != null) {
      attributes.putIfAbsent('encodingStyle', () => header.encodingStyle);
    }

    if (header.role != null) {
      attributes.putIfAbsent('role', () => header.role);
    }

    if (header.relay != null) {
      attributes.putIfAbsent('relay', () => header.relay.toString());
    }

    var elementName = header.key.isEmpty ? '${header.key}:${header.name}' : header.name;

    builder.element(elementName, attributes: attributes, nest: () => builder.text(header.value));
  }

  void _parseElement(xml.XmlBuilder builder, SoapElement element) {
    var name = element.key != null && element.key.isNotEmpty ? '${element.key}:{element.name}' : element.name;
    var attributes = <String, String>{};

    if (element.encodingStyle != null) {
      attributes.putIfAbsent('encodingStyle', () => element.encodingStyle);
    }

    builder.element(name, attributes: attributes, nest: () => _parseNode(builder, element.value));
  }

  void _parseGenericTypedList<T>(xml.XmlBuilder builder, String key, Iterable<T> value) {
    var arrayKey = _getAlias<T>(value);

    if (value.isEmpty) {
      builder.element('$serviceKey:$key');
    } else {
      builder.element('$serviceKey:$key', nest: () {
        value.forEach((item) => builder.element('$arrayKey:int', nest: () => builder.text(item)));
      });
    }
  }

  void _parseList(xml.XmlBuilder builder, String key, Iterable value) {
    var arrayKey = _getListAlias();

    if (value.isEmpty) {
      builder.element('$serviceKey:$key');
    } else {
      builder.element('$serviceKey:$key', nest: () {
        value.forEach((item) {
          builder.element('$arrayKey:int', nest: () => builder.text(item));
        });
      });
    }
  }

  String _getAlias<T>(List<T> value) {
    var type = value.runtimeType.toString();
    var alias = maps.containsKey(value.runtimeType) ? maps[value.runtimeType] : null;
    if (alias == null) alias = maps.containsKey(List) ? maps[List] : null;
    if (alias == null) throw NamespaceNotFoundException('Namespace for $type or List not found');

    return alias.key;
  }

  String _getListAlias() {
    var alias = maps.containsKey(List) ? maps[List] : null;
    if (alias == null) throw NamespaceNotFoundException('Namespace for List not found');

    return alias.key;
  }

  @override
  String toString() {
    return _document.toString();
  }

  String toXmlString() {
    return _document.toXmlString(pretty: true, indent: '  ');
  }
}
