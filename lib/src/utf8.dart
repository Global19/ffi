// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// [Utf8] implements conversion between Dart strings and zero-terminated
/// UTF-8 encoded "char*" strings in C.
///
/// [Utf8] is represented as a struct so that `Pointer<Utf8>` can be used in
/// native function signatures.
//
// TODO(https://github.com/dart-lang/ffi/issues/4): No need to use
// 'asTypedList' when Pointer operations are performant.
class Utf8 extends Opaque {
  /// Returns the length of a zero-terminated string &mdash; the number of
  /// bytes before the first zero byte.
  static int strlen(Pointer<Utf8> string) {
    final Pointer<Uint8> array = string.cast<Uint8>();
    int length = 0;
    while (array[length] != 0) {
      length++;
    }
    return length;
  }

  /// Creates a [String] containing the characters UTF-8 encoded in [string].
  ///
  /// Either the [string] must be zero-terminated or its [length] &mdash; the
  /// number of bytes &mdash; must be specified as a non-negative value. The
  /// byte sequence must be valid UTF-8 encodings of Unicode scalar values. A
  /// [FormatException] is thrown if the input is malformed. See [Utf8Decoder]
  /// for details on decoding.
  ///
  /// Returns a Dart string containing the decoded code points.
  static String fromUtf8(Pointer<Utf8> string, {int? length}) {
    if (length != null) {
      RangeError.checkNotNegative(length, 'length');
    } else {
      length = strlen(string);
    }
    return utf8.decode(string.cast<Uint8>().asTypedList(length));
  }

  /// Convert a [String] to a UTF-8 encoded zero-terminated C string.
  ///
  /// If [string] contains NULL characters, the converted string will be truncated
  /// prematurely. Unpaired surrogate code points in [string] will be encoded
  /// as replacement characters (U+FFFD, encoded as the bytes 0xEF 0xBF 0xBD)
  /// in the UTF-8 encoded result. See [Utf8Encoder] for details on encoding.
  ///
  /// Returns a [allocator]-allocated pointer to the result.
  static Pointer<Utf8> toUtf8(String string, {Allocator allocator = calloc}) {
    final units = utf8.encode(string);
    final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
    final Uint8List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}
