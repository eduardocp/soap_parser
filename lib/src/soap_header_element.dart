class SoapHeaderElement {
  final String namespace;
  final String key;
  final String value;
  final bool mustUnderstand;
  final String encodingStyle;
  final String role;
  final bool relay;

  SoapHeaderElement(this.key, this.value, {this.namespace = 'ns', this.mustUnderstand = null, this.encodingStyle = null, this.role = null, this.relay = null});
}
