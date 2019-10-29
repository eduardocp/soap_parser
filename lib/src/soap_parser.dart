import 'dart:ffi';
import 'package:soap/soap_parser.dart';
import 'package:xml/xml.dart' as xml;

class SoapParser {
  final dynamic values;
  final Version version;
  final Map<String, String> namespaces;
  final Map<Type, SoapNamespaceMap> maps;
  final List<SoapHeaderElement> header;
  final String namespaceAlias;

  xml.XmlDocument _document;
  String _defaultNamespaceAlias = 'soapenv';

  SoapParser.parse(
    String method, {
    this.values = null,
    this.namespaceAlias = 'service',
    this.maps = const {},
    this.namespaces = const {},
    this.header = const [],
    this.version = Version.Soap1_1,
  }) {
    var namespaces = <String, String>{
      '$_defaultNamespaceAlias': _getSoapUrl(),
    };

    namespaces.addAll(this.namespaces);

    maps.forEach((key, value) {
      namespaces.putIfAbsent(value.key, () => value.uri);
    });

    if (version == Version.Soap1_2) {
      namespaces.putIfAbsent('$_defaultNamespaceAlias:encodingStyle', () => "http://www.w3.org/2003/05/soap-encoding");
    }

    var builder = new xml.XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('$_defaultNamespaceAlias:Envelope', namespaces: _reverseMapKeyValue(namespaces), nest: () {
      builder.element('$_defaultNamespaceAlias:Header', nest: () => _parseNode(builder, header));
      builder.element('$_defaultNamespaceAlias:Body', nest: () {
        if (method != null && method.isNotEmpty) {
          builder.element('$namespaceAlias:$method', nest: () => _parseNode(builder, values));
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
          builder.element('$namespaceAlias:$key', nest: () => _parseNode(builder, value));
        } else {
          if (value is List<int>) {
            _parseGenericTypedList<int>(builder, key, value);
          } else if (value is List<String>) {
            _parseGenericTypedList<String>(builder, key, value);
          } else if (value is List<bool>) {
            _parseGenericTypedList<bool>(builder, key, value);
          } else if (value is List<Float>) {
            _parseGenericTypedList<Float>(builder, key, value);
          } else if (value is List) {
            _parseList(builder, key, value);
          } else {
            builder.element('$namespaceAlias:$key', nest: () {
              if (value != null) {
                builder.text(value.toString());
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
    var attributes = <String, String>{'xmlns': header.namespace};

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

    builder.element(header.key, attributes: attributes, nest: () => builder.text(header.value));
  }

  void _parseElement(xml.XmlBuilder builder, SoapElement element) {
    var alias = element.key != null && element.key.isEmpty ? element.alias : element.key;
    var key = element.alias;
    var attributes = <String, String>{};

    if (element.encodingStyle != null) {
      attributes.putIfAbsent('encodingStyle', () => element.encodingStyle);
    }

    builder.element('$alias:$key', attributes: attributes, nest: () => _parseNode(builder, element.value));
  }

  void _parseGenericTypedList<T>(xml.XmlBuilder builder, String key, List<T> value) {
    var arrayKey = _getAlias<T>(value);

    if (value.isEmpty) {
      builder.element('$namespaceAlias:$key');
    } else {
      builder.element('$namespaceAlias:$key', nest: () {
        value.forEach((item) => builder.element('$arrayKey:int', nest: () => builder.text(item)));
      });
    }
  }

  void _parseList(xml.XmlBuilder builder, String key, List value) {
    var arrayKey = _getListAlias();

    if (value.isEmpty) {
      builder.element('$namespaceAlias:$key');
    } else {
      builder.element('$namespaceAlias:$key', nest: () {
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
