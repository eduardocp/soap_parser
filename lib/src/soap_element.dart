class SoapElement {
  final String key;
  final String alias;
  final dynamic value;
  final String encodingStyle;

  SoapElement(this.alias, this.value, {this.key = null, this.encodingStyle = null});
}
