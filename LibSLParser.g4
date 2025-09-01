parser grammar LibSLParser;

options {
    tokenVocab = LibSLLexer;
}

file:   header?
        globalDecl*
        EOF
    ;

header
    :   (LIBSL libslVersion=DoubleQuotedString SEMICOLON)
        (LIBRARY libraryName=Identifier)
        (VERSION version=DoubleQuotedString)?
        (LANGUAGE language=DoubleQuotedString)?
        (URL url=DoubleQuotedString)?
        SEMICOLON
    ;

globalDecl
    :   ImportStatement # Import
    |   IncludeStatement # Include
    |   semanticTypeSection # SemanticTypeSection
    |   typeAliasDecl # TypeAlias
    |   structDecl # Struct
    |   enumDecl # Enum
    |   annotationDecl # Annotation
    |   actionDecl # Action
    |   automatonDecl # Automaton
    |   functionDecl # Function
    |   variableDecl # Variable
    ;

semanticTypeSection
    :   TYPES
        L_BRACE decls=semanticTypeDecl* R_BRACE
    ;

semanticTypeDecl
    :   annotations=annotation*
        typeName=qualifiedTypeName
        L_BRACKET realType=typeExpr R_BRACKET
        semanticTypeDef
    ;

semanticTypeDef
    :   SEMICOLON # Simple
    |   L_BRACE values=enumSemanticTypeValue* R_BRACE # Enum
    ;

enumSemanticTypeValue
    :   name=Identifier
        COLON expr=atomicExpr
        SEMICOLON
    ;

typeAliasDecl
    :   annotations=annotation*
        TYPEALIAS typeName=qualifiedTypeName
        ASSIGN_OP def=typeExpr
        SEMICOLON
    ;

structDecl
    :   annotations=annotation*
        TYPE typeName=qualifiedTypeName
        targetType=structTargetType?
        whereClause=whereClause?
        (L_BRACE decls=structDefDecl* R_BRACE)?
    ;

structTargetType
    :   (IS isType=typeExpr)?
        FOR forTypes=typeExprList COMMA?
    ;

structDefDecl
    :   variableDecl # Variable
    |   functionDecl # Function
    ;

enumDecl
    :   annotations=annotation*
        ENUM typeName=qualifiedTypeName
        L_BRACE variants=enumDeclVariant* R_BRACE
    ;

enumDeclVariant
    :   name=Identifier ASSIGN_OP value=signedIntLit SEMICOLON
    ;

signedIntLit
    :   sign=sign
        lit=IntegerLiteral
    ;

sign:   MINUS # Minus
    |   PLUS # Plus
    ;

annotationDecl
    :   ANNOTATION name=Identifier
        L_BRACKET (params=annotationParamList COMMA?)? R_BRACKET
        SEMICLON
    ;

annotationParamList
    :   params+=annotationParam
        (COMMA params+=annotationParam)*
    ;

annotationParam
    :   name=Identifier
        COLON typeExpr=typeExpr
        (ASSIGN_OP default=expr)?
    ;

actionDecl
    :   annotations=annotation*
        DEFINE ACTION name=Identifier
        generics=generics?
        L_BRACKET (params=actionParamList COMMA?)? R_BRACKET
        (COLON retTypeExpr=typeExpr)?
        whereClause=whereClause?
        SEMICOLON
    ;

actionParamList
    :   params+=actionParam
        (COMMA params+=actionParam)*
    ;

actionParam
    :   annotations=annotation*
        name=Identifier
        COLON typeExpr=typeExpr
    ;

automatonDecl
    :   annotations=annotation*
        AUTOMATON isConcept=CONCEPT? name=qualifiedTypeName
        (L_BRACKET (constructorVariables=constructorVariableList COMMA?)? R_BRACKET)?
        COLON typeExpr=typeExpr
        (implementedConcepts=implementedConcepts COMMA?)*
        L_BRACE automatonDefDecl* R_BRACE
    ;

constructorVariableList
    :   variables+=constructorVariable
        (COMMA variables+=constructorVariable)*
    ;

constructorVariable
    :   annotations=annotation*
        kind=variableKind
        name=Identifier
        COLON typeExpr=typeExpr
        (ASSIGN_OP init=expr)?
    ;

implementedConcepts
    :   IMPLEMENTS concepts+=Identifier
        (COMMA concepts+=Identifier)*
    ;

automatonDefDecl
    :   stateDecl # State
    |   shiftDecl # Shift
    |   constructorDecl # Constructor
    |   destructorDecl # Destructor
    |   procDecl # Proc
    |   functionDecl # Function
    |   variableDecl # Variable
    ;

functionDecl
    :   annotations=annotation*
        static=STATIC?
        FUN
        (extensionFor=fullName DOT)?
        method=methodSpec?
        name=Identifier
        generics=generics?
        L_BRACKET (params=functionParamList COMMA?)? R_BRACKET
        (COLON retTypeExpr=typeExpr)?
        whereClause=whereClause?
        def=functionDef
    ;

methodSpec
    :   ASTERISK DOT
    ;

functionDef
    :   L_BRACE body=functionBody R_BRACE
    |   SEMICOLON?
    ;

variableDecl
    :   annotations=annotation*
        kind=variableKind
        name=Identifier
        COLON typeExpr=typeExpr
        (ASSIGN_OP init=expr)?
        SEMICOLON
    ;

variableKind
    :   VAR # Var
    |   VAL # Val
    ;

stateDecl
    :   kind=stateKind
        names=identifierList
        SEMICOLON
    ;

stateKind
    :   INITSTATE # Initial
    |   STATE # Regular
    |   FINISHSTATE # Final
    ;

identifierList
    :   names+=Identifier
        (COMMA names+=Identifier)*
    ;

shiftDecl
    :   SHIFT
        from=shiftSourceState
        MINUS_ARROW to=Identifier
        BY by=shiftBy
        SEMICOLON
    ;

shiftSourceState
    :   Identifier # Shorthand
    |   L_BRACKET (states=identifierList COMMA?)? R_BRACKET # List
    ;

shiftBy
    :   signature=functionSignature # Shorthand
    |   L_SQUARE_BRACKET (signatures=functionSignatureList COMMA?)? R_SQUARE_BRACKET # List
    ;

functionSignatureList
    :   signatures+=functionSignature
        (COMMA signatures+=functionSignature)*
    ;

functionSignature
    :   name=Identifier # Shorthand
    |   name=Identifier L_BRACKET (params=typeExprList COMMA?)? R_BRACKET # Qualified
    ;

constructorDecl
    :   annotations=annotation*
        CONSTRUCTOR
        method=methodSpec?
        name=Identifier
        L_BRACKET (params=functionParamList COMMA?)? R_BRACKET
        (COLON retTypeExpr=typeExpr)?
        def=functionDef
    ;

destructorDecl
    :   annotations=annotation*
        DESTRUCTOR
        method=methodSpec?
        name=Identifier
        L_BRACKET (params=functionParamList COMMA?)? R_BRACKET
        (COLON retTypeExpr=typeExpr)?
        def=functionDef
    ;

procDecl
    :   annotations=annotation*
        PROC
        method=methodSpec?
        name=Identifier
        generics=generics?
        L_BRACKET (params=functionParamList COMMA?)? R_BRACKET
        (COLON retTypeExpr=typeExpr)?
        whereClause=whereClause?
        def=functionDef
    ;

functionParamList
    :   params+=functionParam
        (COMMA params+=functionParam)*
    ;

functionParam
    :   annotations=annotation*
        name=Identifier
        COLON typeExpr=typeExpr
    ;

functionBody
    :   contracts=contract*
        stmts=stmt*
    ;

contract
    :   requiresContract # Requires
    |   ensuresContract # Ensures
    |   assignsContract # Assigns
    ;

requiresContract
    :   REQUIRES
        (name=Identifier COLON)?
        expr=expr
        SEMICOLON
    ;

ensuresContract
    :   ENSURES
        (name=Identifier COLON)?
        expr=expr
        SEMICOLON
    ;

assignsContract
    :   ASSIGNS
        (name=Identifier COLON)?
        expr=expr
        SEMICOLON
    ;

annotation
    :   AT name=Identifier
        (L_BRACKET (args=annotationArgList COMMA?)? R_BRACKET)?
    ;

annotationArgList
    :   annotationArg
        (COMMA annotationArg)*
    ;

annotationArg
    :   (name=Identifier ASSIGN_OP)?
        expr=expr
    ;

qualifiedTypeName
    :   typeName=fullName
        generics=generics?
    ;

fullName
    :   components+=Identifier
        (DOT components+=Identifier)*
    ;

whereClause
    :   WHERE constraints+=typeConstraint
        (COMMA constraints+=typeConstraint)*
        COMMA?
    ;

typeConstraint
    :   param=Identifier
        COLON
        variance=variance
        bound=typeArg
    ;

generics
    :   L_ARROW (generics=genericList COMMA?)? R_ARROW
    ;

genericList
    :   generics+=generic
        (COMMA generics+=generic)*
    ;

generic
    :   variance=variance
        name=Identifier
    ;

variance
    :   OUT # Covariant
    |   IN # Contravariant
    |   # Invariant
    ;

typeExprList
    :   typeExprs+=typeExpr
        (COMMA typeExprs+=typeExpr)*
    ;

typeExpr
    :   primitiveLitTypeExpr # PrimitiveLit
    |   nameTypeExpr # Name
    |   pointerTypeExpr # Pointer
    |   intersectionTypeExpr # Intersection
    |   unionTypeExpr # Union
    ;

primitiveLitTypeExpr
    :   lit=primitiveLit
    ;

nameTypeExpr
    :   typeName=fullName
        generics=typeArgs?
    ;

pointerTypeExpr
    :   ASTERISK
        base=typeExpr
    ;

intersectionTypeExpr
    :   lhs=typeExpr
        AMPERSAND
        rhs=typeExpr
    ;

unionTypeExpr
    :   lhs=typeExpr
        BIT_OR
        rhs=typeExpr
    ;

typeArgs
    :   L_ARROW (generics=typeArgList COMMA?)? R_ARROW
    ;

typeArgList
    :   typeArgs+=typeArg
        (COMMA typeArgs+=typeArg)*
    ;

typeArg
    :   typeExpr # TypeExpr
    |   UNBOUNDED # Wildcard
    ;

stmt:   variableDecl # VariableDecl
    |   ifStmt # If
    |   assignStmt # Assign
    |   expr=expr SEMICOLON # Expr
    ;

ifStmt
    :   IF condition=expr
        L_BRACE thenBranch=stmt* R_BRACE
        (ELSE L_BRACE elseBranch=stmt* R_BRACE)?
    ;

assignStmt
    :   lhs=access
        op=assignOp
        rhs=expr
        SEMICOLON
    ;

assignOp
    :   ASSIGN_OP # Assign
    |   PLUS_EQ # AddAssign
    |   MINUS_EQ # SubAssign
    |   ASTERISK_EQ # MulAssign
    |   SLASH_EQ # DivAssign
    |   PERCENT_EQ # ModAssign
    |   AMPERSAND_EQ # BitAndAssign
    |   OR_EQ # BitOrAssign
    |   XOR_EQ # BitXorAssign
    |   L_SHIFT_EQ # LShiftAssign
    |   R_SHIFT_EQ # RShiftAssign
    ;

exprList
    :   exprs+=expr
        (COMMA exprs+=expr)*
    ;

atomicExpr
    :   L_BRACKET expr=atomicExpr R_BRACKET # Paren
    |   primitiveLitExpr # PrimitiveLit
    |   arrayLitExpr # ArrayLit
    |   access # Access
    ;

expr:   L_BRACKET expr=expr R_BRACKET # Paren
    |   primitiveLitExpr # PrimitiveLit
    |   arrayLitExpr # ArrayLit
    |   access=access APOSTROPHE # Prev
    |   procCallExpr # ProcCall
    |   actionCallExpr # ActionCall
    |   instantiationExpr # Instantiation
    |   access # Access
    |   op=unOp rhs=expr # Unary
    |   lhs=access HAS typeExpr=typeExpr # HasConcept
    |   lhs=expr IS typeExpr=typeExpr # TypeComparison
    |   lhs=expr AS typeExpr=typeExpr # Cast
    |   lhs=expr op=mulBinOp rhs=expr # Multiplicative
    |   lhs=expr op=addBinOp rhs=expr # Additive
    |   lhs=expr op=bitShiftOp rhs=expr # Shift
    |   lhs=expr AMPERSAND rhs=expr # BitAnd
    |   lhs=expr XOR rhs=expr # BitXor
    |   lhs=expr OR rhs=expr # BitOr
    |   lhs=expr op=relOp rhs=expr # Relational
    |   lhs=expr DOUBLE_AMPERSAND rhs=expr # And
    |   lhs=expr LOGIC_OR rhs=expr # Or
    ;

unOp:   PLUS # Plus
    |   MINUS # Neg
    |   TILDE # BitNot
    |   EXCLAMATION # Not
    ;

mulBinOp
    :   ASTERISK # Mul
    |   SLASH # Div
    |   PERCENT # Mod
    ;

addBinOp
    :   PLUS # Add
    |   MINUS # Sub
    ;

// TODO: ensure contiguousness.
bitShiftOp
    :   L_ARROW L_ARROW L_ARROW # LogicalLeft
    |   R_ARROW R_ARROW R_ARROW # LogicalRight
    |   L_ARROW L_ARROW # ArithmeticLeft
    |   R_ARROW R_ARROW # ArithmeticRight
    ;

relOp
    :   L_ARROW_EQ # LessEquals
    |   R_ARROW_EQ # GreaterEquals
    |   L_ARROW # Less
    |   R_ARROW # Greater
    |   EQ # Equals
    |   EXCLAMATION_EQ # NotEquals
    ;

primitiveLitExpr
    :   lit=primitiveLit
    ;

primitiveLit
    :   IntegerLiteral # Int
    |   FloatingPointLiteral # Float
    |   DoubleQuotedString # String
    |   CHARACTER # Char
    |   TRUE # True
    |   FALSE # False
    |   NULL # Null
    ;

arrayLitExpr
    :   L_SQUARE_BRACKET (elems=exprList COMMA?)? R_SQUARE_BRACKET
    ;

procCallExpr
    :   callee=access
        generics=typeArgs?
        L_BRACKET (args=exprList COMMA?)? R_BRACKET
    ;

actionCallExpr
    :   ACTION name=Identifier
        generics=typeArgs?
        L_BRACKET (args=exprList COMMA?)? R_BRACKET
    ;

instantiationExpr
    :   NEW name=fullName
        generics=typeArgs?
        L_BRACKET (args=constructorArgList COMMA?)? R_BRACKET
    ;

constructorArgList
    :   args+=constructorArg
        (COMMA args+=constructorArg)*
    ;

constructorArg
    :   STATE ASSIGN_OP expr=atomicExpr # State
    |   name=Identifier ASSIGN_OP expr=expr # Var
    ;

access
    :   name=Identifier # Name
    |   base=access DOT field=Identifier # Field
    |   base=access L_SQUARE_BRACKET index=expr R_SQUARE_BRACKET # Index
    ;
