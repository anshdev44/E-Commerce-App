// Web-only implementation using dart:js
import 'dart:js' as js;

class RazorpayJS {
  static dynamic createOptions(Map<String, dynamic> options) {
    return js.JsObject.jsify(options);
  }

  static dynamic allowInterop(Function callback) {
    return js.allowInterop(callback);
  }

  static dynamic getRazorpayFromContext() {
    return js.context['Razorpay'];
  }

  static dynamic createRazorpayInstance(dynamic razorpay, List<dynamic> args) {
    return js.JsObject(razorpay, args);
  }
}



