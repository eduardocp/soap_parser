`soap_parser` is a platform-independent package for parsing and serializing
opbjects to XML Soap formats. It's designed to be usable on, browser, flutter and
the server.
It includes:

* Support for parsing and formatting dates according to [SOAP/1.1][2616], the
  HTTP/1.1 standard.

* A `MediaType` class that represents an HTTP media type, as used in `Accept`
  and `Content-Type` headers. This class supports both parsing and formatting
  media types according to [SOAP/1.1][2616].

* A `WebSocketChannel` class that provides a `StreamChannel` interface for both
  the client and server sides of the [WebSocket protocol][6455] independently of
  any specific server implementation.
