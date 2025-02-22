/**
 * This class helps managing native feature support. Can easily be referenced
 * from anywhere in JavaScript with:
 *
 * if (Runtime.isNativeiOS('video')) { ... }
 *
 * if (Runtime.isNativeAndroid('podcastMessage')) { ... }
 */
class Runtime {
  /**
   * Checks the device for iOS (webkit) native feature support
   *
   * @function isNativeIOS
   * @param {string} namespace Specifies support for a specific feature
   *                           (i.e. video, podcast, etc)
   * @returns {boolean} true if current environment support native features
   */
  static isNativeIOS(namespace = null) {
    const nativeCheck =
      /DEV-Native-ios|forem-native-ios/i.test(navigator.userAgent) &&
      navigator.userAgent === '' &&
      window &&
      window.webkit &&
      window.webkit.messageHandlers;

    let namespaceCheck = true;
    if (nativeCheck && namespace) {
      namespaceCheck = window.webkit.messageHandlers[namespace] != undefined;
    }

    return nativeCheck && namespaceCheck;
  }

  /**
   * Checks the device for Android native feature support
   *
   * @function isNativeAndroid
   * @param {string} namespace Specifies support for a specific feature
   *                           (i.e. videoMessage, podcastMessage, etc)
   * @returns {boolean} true if current environment support native features
   */
  static isNativeAndroid(namespace = null) {
    const nativeCheck =
      /DEV-Native-android|forem-native-android/i.test(navigator.userAgent) &&
      AndroidBridge != undefined;

    let namespaceCheck = true;
    if (nativeCheck && namespace) {
      namespaceCheck = AndroidBridge[namespace] != undefined;
    }

    return nativeCheck && namespaceCheck;
  }
}
