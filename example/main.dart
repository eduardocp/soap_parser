import 'package:soap/soap_parser.dart';

main() async {
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

  var editLimitParser = SoapParser.parse("ConsultaCEP", values: values, namespaces: namespaces);
  print(editLimitParser.toXmlString());
}
