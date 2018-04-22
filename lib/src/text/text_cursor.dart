import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:quiver_hashcode/hashcode.dart';

import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_utilities.dart';
import 'package:time_machine/time_machine_calendars.dart';
import 'package:time_machine/time_machine_timezones.dart';
import 'package:time_machine/time_machine_text.dart';

/// <summary>
/// Provides a cursor over text being parsed. None of the methods in this class throw exceptions (unless
/// there is a bug in Noda Time, in which case an exception is appropriate) and none of the methods
/// have ref parameters indicating failures, unlike subclasses. This class is used as the basis for both
/// value and pattern parsing, so can make no judgement about what's wrong (i.e. it wouldn't know what
/// type of failure to indicate). Instead, methods return Boolean values to indicate success or failure.
/// </summary>
@internal abstract class TextCursor {
  /// <summary>
  /// Gets the length of the string being parsed.
  /// </summary>
  @internal final int Length;

  /// <summary>
  /// Gets the string being parsed.
  /// </summary>
  @internal final String Value;

  /// <summary>
  /// A nul character. This character is not allowed in any parsable string and is used to
  /// indicate that the current character is not set.
  /// </summary>
  @internal static const String Nul = '\0';

  /// <summary>
  /// Initializes a new instance to parse the given value.
  /// </summary>
// Validated by caller.
  @protected TextCursor(this.Value) : Length = Value.length {
    Move(-1);
  }

  /// <summary>
  /// Gets the current character.
  /// </summary>
  String _current;
  @internal String get Current => _current;

  /// <summary>
  /// Gets a value indicating whether this instance has more characters.
  /// </summary>
  /// <value>
  /// <c>true</c> if this instance has more characters; otherwise, <c>false</c>.
  /// </value>
  @internal bool get HasMoreCharacters => (Index + 1) < Length;

  /// <summary>
  /// Gets the current index into the string being parsed.
  /// </summary>
  // todo: { get; private set; }
  @internal int Index;

  /// <summary>
  /// Gets the remainder the string that has not been parsed yet.
  /// </summary>
  @internal String get Remainder => Value.substring(Index);

  /// <summary>
  ///   Returns a <see cref="System.String" /> that represents this instance.
  /// </summary>
  /// <returns>
  ///   A <see cref="System.String" /> that represents this instance.
  /// </returns>
  @override String toString() => stringInsert(Value, Index, '^');

  /// <summary>
  /// Returns the next character if there is one or <see cref="Nul" /> if there isn't.
  /// </summary>
  /// <returns></returns>
  @internal String PeekNext() => (HasMoreCharacters ? Value[Index + 1] : Nul);

  /// <summary>
  /// Moves the specified target index. If the new index is out of range of the valid indicies
  /// for this string then the index is set to the beginning or the end of the string whichever
  /// is nearest the requested index.
  /// </summary>
  /// <param name="targetIndex">Index of the target.</param>
  /// <returns><c>true</c> if the requested index is in range.</returns>
  @internal bool Move(int targetIndex) {
    if (targetIndex >= 0) {
      if (targetIndex < Length) {
        Index = targetIndex;
        _current = Value[Index];
        return true;
      }
      else {
        _current = Nul;
        Index = Length;
        return false;
      }
    }
    _current = Nul;
    Index = -1;
    return false;
  }

  /// <summary>
  /// Moves to the next character.
  /// </summary>
  /// <returns><c>true</c> if the requested index is in range.</returns>
  @internal bool MoveNext() {
    // Logically this is Move(Index + 1), but it's micro-optimized as we
    // know we'll never hit the lower limit this way.
    int targetIndex = Index + 1;
    if (targetIndex < Length) {
      Index = targetIndex;
      _current = Value[Index];
      return true;
    }
    _current = Nul;
    Index = Length;
    return false;
  }

  /// <summary>
  /// Moves to the previous character.
  /// </summary>
  /// <returns><c>true</c> if the requested index is in range.</returns>
  @internal bool MovePrevious() {
    // Logically this is Move(Index - 1), but it's micro-optimized as we
    // know we'll never hit the upper limit this way.
    if (Index > 0) {
      Index--;
      _current = Value[Index];
      return true;
    }
    _current = Nul;
    Index = -1;
    return false;
  }
}