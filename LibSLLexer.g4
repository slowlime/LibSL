lexer grammar LibSLLexer;

SEMICOLON : ';' ;

EQ : '=' ;

EQ_EQ : '==' ;

L_BRACE : '{' ;

R_BRACE : '}' ;

L_PAREN : '(' ;

R_PAREN : ')' ;

L_BRACKET : '[' ;

R_BRACKET : ']' ;

DOT : '.' ;

COLON : ':' ;

COMMA : ',' ;

ARROW : '->' ;

L_ANGLE : '<' ;

R_ANGLE : '>' ;

ASTERISK : '*' ;

SLASH : '/' ;

PERCENT : '%' ;

PLUS : '+' ;

MINUS : '-' ;

PLUS_EQ : '+=' ;

MINUS_EQ : '-=' ;

ASTERISK_EQ : '*=' ;

SLASH_EQ : '/=' ;

PERCENT_EQ : '%=' ;

BANG : '!' ;

BANG_EQ : '!=' ;

L_ANGLE_EQ : '<=' ;

R_ANGLE_EQ : '>=' ;

AMP : '&' ;

AMP_AMP : '&&' ;

PIPE : '|' ;

PIPE_PIPE : '||' ;

CARET : '^' ;

TILDE : '~' ;

AMP_EQ : '&=' ;

PIPE_EQ : '|=' ;

CARET_EQ : '^=' ;

R_ANGLE_R_ANGLE_EQ: '>>=' ;

L_ANGLE_L_ANGLE_EQ: '<<=' ;

QUOTE : '\'' ;

BACKTICK : '`' ;

ImportStatement
   :   IMPORT .*? ';'
   ;

IncludeStatement
   :   INCLUDE .*? ';'
   ;

IMPORT
   :   'import'
   ;

INCLUDE
   :   'include'
   ;

LIBSL
   :   'libsl'
   ;

LIBRARY
   :   'library'
   ;

VERSION
   :   'version'
   ;

LANGUAGE
   :   'language'
   ;

URL
   :   'url'
   ;

TYPEALIAS
   :   'typealias'
   ;

TYPE
   :   'type'
   ;

TYPES
   :   'types'
   ;

ENUM
   :   'enum'
   ;

ANNOTATION
   :   'annotation'
   ;

AUTOMATON
   :   'automaton'
   ;

CONCEPT
   :   'concept'
   ;

VAR
   :   'var'
   ;

VAL
   :   'val'
   ;

INITSTATE
   :   'initstate'
   ;

STATE
   :   'state'
   ;

FINISHSTATE
   :   'finishstate'
   ;

SHIFT
   :   'shift'
   ;

NEW
   :   'new'
   ;

FUN
   :   'fun'
   ;

CONSTRUCTOR
   :   'constructor'
   ;

DESTRUCTOR
   :   'destructor'
   ;

PROC
   :   'proc'
   ;

AT
   :   '@'
   ;

ACTION
   :   'action'
   ;

REQUIRES
   :   'requires'
   ;

ENSURES
   :   'ensures'
   ;

ASSIGNS
   :   'assigns'
   ;

TRUE
   :   'true'
   ;

FALSE
   :   'false'
   ;

DEFINE
   :   'define'
   ;

IF
   :   'if'
   ;

ELSE
   :   'else'
   ;

BY
   :   'by'
   ;

IS
   :   'is'
   ;

AS
   :   'as'
   ;

NULL
   :   'null'
   ;

IN
   :   'in'
   ;

OUT
   :   'out'
   ;

WHERE
   :   'where'
   ;

FOR:    'for';

IMPLEMENTS
    :   'implements'
    ;

STATIC
    :   'static'
    ;

HAS:    'has';

QUESTION
    :   '?'
    ;


IntegerLit
    :   DecimalIntegerLit
    |   HexIntegerLit
    |   OctalIntegerLit
    |   BinaryIntegerLit
    ;

fragment DecimalIntegerLit: DecimalNumeral IntegerTypeSuffix?;

fragment HexIntegerLit: HexNumeral IntegerTypeSuffix?;

fragment OctalIntegerLit: OctalNumeral IntegerTypeSuffix?;

fragment BinaryIntegerLit: BinaryNumeral IntegerTypeSuffix?;

fragment DecimalNumeral: '0' | NonZeroDigit (Digits?);

fragment IntegerTypeSuffix: [lLxsu] | 'ux' | 'us' | 'uL';

FloatLit: DecimalFloatLit;

fragment DecimalFloatLit
    :   Digits '.' Digits? ExponentPart? FloatTypeSuffix?
    |   Digits ExponentPart FloatTypeSuffix?
    |   Digits FloatTypeSuffix
    ;

fragment ExponentPart: ExponentIndicator SignedInteger;

fragment ExponentIndicator: [eE];

fragment SignedInteger: Sign? Digits;

fragment Sign: [+-];

fragment FloatTypeSuffix: [fFdD];

Identifier
   :   [a-zA-Z_$][a-zA-Z0-9_$]*
   |   '`' .*? '`'
   ;

fragment ESCAPED_QUOTE
   : '\\"'
   ;

StringLit
   :   '"' ( ESCAPED_QUOTE | ~('\n'|'\r') )*? '"'
   ;

CharacterLit
   :   '\'' SingleCharacter '\''
   |   '\'' EscapeSequence '\''
   ;

fragment SingleCharacter
    :   ~['\\\r\n]
    ;

fragment EscapeSequence
    :   '\\' [btnfr"'\\]
        | UnicodeEscape
        | OctalEscape
    ;

fragment UnicodeEscape: '\\' 'u'+ Hex Hex Hex Hex;

fragment OctalEscape
    :   '\\' OctalDigit
    |   '\\' OctalDigit OctalDigit
    |   '\\' ZeroToThree OctalDigit OctalDigit
    ;

fragment ZeroToThree: [0-3];

fragment Digits: Digit+;

Digit: ('0'..'9');

fragment NonZeroDigit: [1-9];

fragment Hex: Digit | [a-fA-F];

fragment HexNumeral: '0' [xX] Hex+;

fragment OctalNumeral: '0' OctalDigit+;

fragment OctalDigit: [0-7];

fragment BinaryNumeral: '0' [bB] BinaryDigit+;

fragment BinaryDigit: [01];

fragment NEWLINE
  : '\r' '\n'
  | '\n'
  | '\r'
  ;

/*
 *  Whitespace and comments
 */
WS
   :   [ \t]+ -> channel(HIDDEN)
   ;

BR
   :   [\r\n\u000C]+ -> channel(HIDDEN)
   ;

COMMENT
   :   '/*' .*? '*/' -> channel(HIDDEN)
   ;

LINE_COMMENT
   :   ('//' ~[\r\n]*) -> channel(HIDDEN)
   ;
