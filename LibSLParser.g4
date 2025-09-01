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
    :   ImportStatement # GlobalDeclImport
    |   IncludeStatement # GlobalDeclInclude
    |   semanticTypeSectionDecl # GlobalDeclSemanticTypeSection
    |   typeAliasDecl # GlobalDeclTypeAlias
    |   structDecl # GlobalDeclStruct
    |   enumDecl # GlobalDeclEnum
    |   annotationDecl # GlobalDeclAnnotation
    |   actionDecl # GlobalDeclAction
    |   automatonDecl # GlobalDeclAutomaton
    |   functionDecl # GlobalDeclFunction
    |   variableDecl # GlobalDeclVariable
    ;

semanticTypeSectionDecl
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
    :   SEMICOLON # SemanticTypeDefSimple
    |   L_BRACE values=enumSemanticTypeValue* R_BRACE # SemanticTypeDefEnum
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
    :   variableDecl # StructDefDeclVariable
    |   functionDecl # StructDefDeclFunction
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

sign:   MINUS # MinusSign
    |   PLUS # PlusSign
    ;

annotationDecl
    :   ANNOTATION name=Identifier
        L_BRACKET (params=annotationParamList COMMA?)? R_BRACKET
        SEMICOLON
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
    :   stateDecl # AutomatonDefDeclState
    |   shiftDecl # AutomatonDefDeclShift
    |   constructorDecl # AutomatonDefDeclConstructor
    |   destructorDecl # AutomatonDefDeclDestructor
    |   procDecl # AutomatonDefDeclProc
    |   functionDecl # AutomatonDefDeclFunction
    |   variableDecl # AutomatonDefDeclVariable
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
    :   VAR # VariableKindVar
    |   VAL # VariableKindVal
    ;

stateDecl
    :   kind=stateKind
        names=identifierList
        SEMICOLON
    ;

stateKind
    :   INITSTATE # StateKindInitial
    |   STATE # StateKindRegular
    |   FINISHSTATE # StateKindFinal
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
    :   Identifier # ShiftSourceStateShorthand
    |   L_BRACKET (states=identifierList COMMA?)? R_BRACKET # ShiftSourceStateList
    ;

shiftBy
    :   signature=functionSignature # ShiftByShorthand
    |   L_SQUARE_BRACKET (signatures=functionSignatureList COMMA?)? R_SQUARE_BRACKET # ShiftByList
    ;

functionSignatureList
    :   signatures+=functionSignature
        (COMMA signatures+=functionSignature)*
    ;

functionSignature
    :   name=Identifier # FunctionSignatureShorthand
    |   name=Identifier L_BRACKET (params=typeExprList COMMA?)? R_BRACKET # FunctionSignatureQualified
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
    :   requiresContract # ContractRequires
    |   ensuresContract # ContractEnsures
    |   assignsContract # ContractAssigns
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
    :   primitiveLitTypeExpr # TypeExprPrimitiveLit
    |   nameTypeExpr # TypeExprName
    |   pointerTypeExpr # TypeExprPointer
    |   intersectionTypeExpr # TypeExprIntersection
    |   unionTypeExpr # TypeExprUnion
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
    :   typeExpr # TypeArgTypeExpr
    |   UNBOUNDED # TypeArgWildcard
    ;

stmt:   variableDecl # StmtVariableDecl
    |   ifStmt # StmtIf
    |   assignStmt # StmtAssign
    |   expr=expr SEMICOLON # StmtExpr
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
    :   ASSIGN_OP # OpAssign
    |   PLUS_EQ # OpAddAssign
    |   MINUS_EQ # OpSubAssign
    |   ASTERISK_EQ # OpMulAssign
    |   SLASH_EQ # OpDivAssign
    |   PERCENT_EQ # OpModAssign
    |   AMPERSAND_EQ # OpBitAndAssign
    |   OR_EQ # OpBitOrAssign
    |   XOR_EQ # OpBitXorAssign
    |   L_SHIFT_EQ # OpLShiftAssign
    |   R_SHIFT_EQ # OpRShiftAssign
    ;

exprList
    :   exprs+=expr
        (COMMA exprs+=expr)*
    ;

atomicExpr
    :   L_BRACKET expr=atomicExpr R_BRACKET # AtomicExprParen
    |   primitiveLitExpr # AtomicExprPrimitiveLit
    |   arrayLitExpr # AtomicExprArrayLit
    |   access # AtomicExprAccess
    ;

expr:   L_BRACKET expr=expr R_BRACKET # ExprParen
    |   primitiveLitExpr # ExprPrimitiveLit
    |   arrayLitExpr # ExprArrayLit
    |   access=access APOSTROPHE # ExprPrev
    |   procCallExpr # ExprProcCall
    |   actionCallExpr # ExprActionCall
    |   instantiationExpr # ExprInstantiation
    |   access # ExprAccess
    |   op=unOp rhs=expr # ExprUnary
    |   lhs=access HAS typeExpr=typeExpr # ExprHasConcept
    |   lhs=expr IS typeExpr=typeExpr # ExprTypeComparison
    |   lhs=expr AS typeExpr=typeExpr # ExprCast
    |   lhs=expr op=mulBinOp rhs=expr # ExprMultiplicative
    |   lhs=expr op=addBinOp rhs=expr # ExprAdditive
    |   lhs=expr op=bitShiftOp rhs=expr # ExprShift
    |   lhs=expr AMPERSAND rhs=expr # ExprBitAnd
    |   lhs=expr XOR rhs=expr # ExprBitXor
    |   lhs=expr BIT_OR rhs=expr # ExprBitOr
    |   lhs=expr op=relOp rhs=expr # ExprRelational
    |   lhs=expr DOUBLE_AMPERSAND rhs=expr # ExprAnd
    |   lhs=expr LOGIC_OR rhs=expr # ExprOr
    ;

unOp:   PLUS # UnOpPlus
    |   MINUS # UnOpNeg
    |   TILDE # UnOpBitNot
    |   EXCLAMATION # UnOpNot
    ;

mulBinOp
    :   ASTERISK # BinOpMul
    |   SLASH # BinOpDiv
    |   PERCENT # BinOpMod
    ;

addBinOp
    :   PLUS # BinOpAdd
    |   MINUS # BinOpSub
    ;

// TODO: ensure contiguousness.
bitShiftOp
    :   L_ARROW L_ARROW L_ARROW # BinOpLogicalLeft
    |   R_ARROW R_ARROW R_ARROW # BinOpLogicalRight
    |   L_ARROW L_ARROW # BinOpArithmeticLeft
    |   R_ARROW R_ARROW # BinOpArithmeticRight
    ;

relOp
    :   L_ARROW_EQ # BinOpLessEquals
    |   R_ARROW_EQ # BinOpGreaterEquals
    |   L_ARROW # BinOpLess
    |   R_ARROW # BinOpGreater
    |   EQ # BinOpEquals
    |   EXCLAMATION_EQ # BinOpNotEquals
    ;

primitiveLitExpr
    :   lit=primitiveLit
    ;

primitiveLit
    :   IntegerLiteral # PrimitiveLitInt
    |   FloatingPointLiteral # PrimitiveLitFloat
    |   DoubleQuotedString # PrimitiveLitString
    |   CHARACTER # PrimitiveLitChar
    |   TRUE # PrimitiveLitTrue
    |   FALSE # PrimitiveLitFalse
    |   NULL # PrimitiveLitNull
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
    :   STATE ASSIGN_OP expr=atomicExpr # ConstructorArgState
    |   name=Identifier ASSIGN_OP expr=expr # ConstructorArgVar
    ;

access
    :   name=Identifier # AccessName
    |   base=access DOT field=Identifier # AccessField
    |   base=access L_SQUARE_BRACKET index=expr R_SQUARE_BRACKET # AccessIndex
    ;
