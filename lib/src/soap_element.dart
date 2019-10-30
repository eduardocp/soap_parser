class SoapElement {
  final String key;
  final String name;
  final dynamic value;
  final String type;
  final String encodingStyle;

  SoapElement(
    this.name,
    this.value, {
    this.type = null,
    this.key = null,
    this.encodingStyle = null,
  });
}
