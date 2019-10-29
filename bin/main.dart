import 'package:soap/soap_parser.dart';

main() async {
  /* var values = <String, dynamic>{
    'data': <String, dynamic>{
      'CloudAccountEid': 1234,
      'Changes': <String, dynamic>{
        'LimitData': <String, dynamic>{
          'AccountNumber': 85236,
          'CreditLimit': 100.00,
          'AccountNumbers': [1, 2, 3, 4]
        },
      },
    },
  };

  List<SoapHeaderElement> header = [
    SoapHeaderElement('_AuthenticationKey', 'e8f13fd5-7ce3-45f6-869c-cfbfb3759511', relay: true),
  ];

  var namespaces = <String, String>{
    'v1': 'http://multiclubes.com.br/app/consumption/v1',
  };

  var maps = <Type, SoapNamespaceMap>{
    List: SoapNamespaceMap('arr', 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'),
  };

  var editLimitParser = SoapParser.parse("EditLimit", values: values, maps: maps, header: header, namespaces: namespaces);
  var editLimit = editLimitParser.toXmlString();

  var connectParser = SoapParser.parse("Connect", namespaceAlias: 'v1', namespaces: namespaces);
  var connect = connectParser.toXmlString();
  var debug = true; */

  var values = SoapElement(
    'obterCEP',
    <String, dynamic>{
      'logradouro': 'Rua Paris',
      'localidade': 'Volta Redonda',
      'UF': 'RJ',
    },
    key: 'byjg',
    encodingStyle: 'http://schemas.xmlsoap.org/soap/encoding/',
  );

  var namespaces = <String, String>{
    'byjg': 'urn:http://www.byjg.com.br',
    'xsd': 'http://www.w3.org/2001/XMLSchema',
    'xsi': 'http://www.w3.org/2001/XMLSchema-instance',
  };

  var method = "Method1";

  var values2 = <String, dynamic>{
    'data': <String, dynamic>{
      'Property1': 1234,
      'Property2': <String, dynamic>{
        'Property1': <String, dynamic>{
          'Property1': 85236,
          'Property2': 100.00,
        },
      },
    },
  };

  var parser = SoapParser.parse(method, values: values2);
  print(parser.toString());

  var editLimitParser = SoapParser.parse("", values: values, namespaces: namespaces);
  var result = editLimitParser.toXmlString();
  print(result);
}
