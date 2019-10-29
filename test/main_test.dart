import 'package:soap/soap_parser.dart';
import 'package:test/test.dart';

void main() {
  test("call none paramenters", () {
    const result = '<?xml version="1.0"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><service:test/></soapenv:Body></soapenv:Envelope>';

    var method = "test";
    var parser = SoapParser.parse(method);

    expect(parser.toString(), result);
  });

  test("parse simple header", () {
    const result =
        '<?xml version="1.0"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><HeaderTag xmlns="ns">value</HeaderTag></soapenv:Header><soapenv:Body><service:test/></soapenv:Body></soapenv:Envelope>';

    List<SoapHeaderElement> header = [
      SoapHeaderElement('HeaderTag', 'value'),
    ];

    var method = "test";
    var parser = SoapParser.parse(method, header: header);

    expect(parser.toString(), result);
  });

  test("parse simple json", () {
    const result =
        '<?xml version="1.0"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><service:Method1><service:data><service:Property1>1234</service:Property1><service:Property2><service:Property1><service:Property1>85236</service:Property1><service:Property2>100.0</service:Property2></service:Property1></service:Property2></service:data></service:Method1></soapenv:Body></soapenv:Envelope>';

    var method = "Method1";
    var values = <String, dynamic>{
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

    var parser = SoapParser.parse(method, values: values);

    expect(parser.toString(), result);
  });
}
