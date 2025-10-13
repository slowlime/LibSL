parser grammar LibSLParser;

options {
    tokenVocab = LibSLLexer;
}

file
    :   header?
        decls+=globalDecl*
        EOF
    ;

header
    :   LIBSL libslVersion=StringLit SEMICOLON
        LIBRARY libraryName=ident
        (VERSION version=StringLit)?
        (LANGUAGE language=StringLit)?
        (URL url=StringLit)?
        SEMICOLON
    ;

globalDecl
    :   importDecl # GlobalDeclImport
    |   includeDecl # GlobalDeclInclude
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

importDecl
    :   IMPORT path SEMICOLON
    ;

includeDecl
    :   INCLUDE path SEMICOLON
    ;

path
    :   StringLit # PathStringLit
    |   BarePath # PathBare
    ;

semanticTypeSectionDecl
    :   TYPES
        L_BRACE decls+=semanticTypeDecl* R_BRACE
    ;

semanticTypeDecl
    :   annotations+=annotation*
        typeName=qualifiedTypeName
        L_PAREN realType=typeExpr R_PAREN
        semanticTypeDef
    ;

semanticTypeDef
    :   SEMICOLON # SemanticTypeDefSimple
    |   L_BRACE values+=enumSemanticTypeValue* R_BRACE # SemanticTypeDefEnum
    ;

enumSemanticTypeValue
    :   name=ident
        COLON value=atomicExpr
        SEMICOLON
    ;

typeAliasDecl
    :   annotations+=annotation*
        TYPEALIAS typeName=qualifiedTypeName
        EQ def=typeExpr
        SEMICOLON
    ;

structDecl
    :   annotations+=annotation*
        TYPE typeName=qualifiedTypeName
        targetType=structTargetType?
        typeConstraints=whereClause?
        (L_BRACE decls+=structDefDecl* R_BRACE)?
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
    :   annotations+=annotation*
        ENUM typeName=qualifiedTypeName
        L_BRACE variants+=enumDeclVariant* R_BRACE
    ;

enumDeclVariant
    :   name=ident EQ value=signedIntLit SEMICOLON
    ;

signedIntLit
    :   sign
        lit=IntegerLit
    ;

sign
    :   MINUS # MinusSign
    |   PLUS # PlusSign
    ;

annotationDecl
    :   ANNOTATION name=ident
        L_PAREN (params=annotationParamList COMMA?)? R_PAREN
        SEMICOLON
    ;

annotationParamList
    :   params+=annotationParam
        (COMMA params+=annotationParam)*
    ;

annotationParam
    :   name=ident
        COLON type=typeExpr
        (EQ default=expr)?
    ;

actionDecl
    :   annotations+=annotation*
        DEFINE ACTION name=ident
        typeParams=generics?
        L_PAREN (params=actionParamList COMMA?)? R_PAREN
        (COLON retType=typeExpr)?
        typeConstrants=whereClause?
        SEMICOLON
    ;

actionParamList
    :   params+=actionParam
        (COMMA params+=actionParam)*
    ;

actionParam
    :   annotations+=annotation*
        name=ident
        COLON type=typeExpr
    ;

automatonDecl
    :   annotations+=annotation*
        AUTOMATON concept=CONCEPT? name=qualifiedTypeName
        (L_PAREN (constructorVariables=constructorVariableList COMMA?)? R_PAREN)?
        COLON type=typeExpr
        (implements=implementedConcepts COMMA?)*
        typeConstraints=whereClause?
        L_BRACE decls+=automatonDefDecl* R_BRACE
    ;

constructorVariableList
    :   variables+=constructorVariable
        (COMMA variables+=constructorVariable)*
    ;

constructorVariable
    :   annotations+=annotation*
        kind=variableKind
        name=ident
        COLON type=typeExpr
        (EQ init=expr)?
    ;

implementedConcepts
    :   IMPLEMENTS concepts+=ident
        (COMMA concepts+=ident)*
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
    :   annotations+=annotation*
        static=STATIC?
        FUN
        (extensionFor=fullName DOT)?
        method=methodSpec?
        name=ident
        typeParams=generics?
        L_PAREN (params=functionParamList COMMA?)? R_PAREN
        (COLON retType=typeExpr)?
        typeConstraints=whereClause?
        def=functionDef
    ;

methodSpec
    :   ASTERISK DOT
    ;

functionDef
    :   L_BRACE body=functionBody R_BRACE # FunctionDefBraced
    |   SEMICOLON? # FunctionDefSemicolon
    ;

variableDecl
    :   annotations+=annotation*
        kind=variableKind
        name=ident
        COLON type=typeExpr
        (EQ init=expr)?
        SEMICOLON
    ;

variableKind
    :   VAR # VariableKindVar
    |   VAL # VariableKindVal
    ;

stateDecl
    :   kind=stateKind
        names=identList
        SEMICOLON
    ;

stateKind
    :   INITSTATE # StateKindInitial
    |   STATE # StateKindRegular
    |   FINISHSTATE # StateKindFinal
    ;

identList
    :   names+=ident
        (COMMA names+=ident)*
    ;

shiftDecl
    :   SHIFT
        from=shiftSourceState
        ARROW to=ident
        BY by=shiftBy
        SEMICOLON
    ;

shiftSourceState
    :   ident # ShiftSourceStateShorthand
    |   L_PAREN (states=identList COMMA?)? R_PAREN # ShiftSourceStateList
    ;

shiftBy
    :   signature=functionSignature # ShiftByShorthand
    |   L_BRACKET (signatures=functionSignatureList COMMA?)? R_BRACKET # ShiftByList
    ;

functionSignatureList
    :   signatures+=functionSignature
        (COMMA signatures+=functionSignature)*
    ;

functionSignature
    :   name=ident # FunctionSignatureShorthand
    |   name=ident L_PAREN (params=typeExprList COMMA?)? R_PAREN # FunctionSignatureQualified
    ;

constructorDecl
    :   annotations+=annotation*
        CONSTRUCTOR
        method=methodSpec?
        name=ident?
        L_PAREN (params=functionParamList COMMA?)? R_PAREN
        (COLON retType=typeExpr)?
        def=functionDef
    ;

destructorDecl
    :   annotations+=annotation*
        DESTRUCTOR
        method=methodSpec?
        name=ident?
        L_PAREN (params=functionParamList COMMA?)? R_PAREN
        (COLON retType=typeExpr)?
        def=functionDef
    ;

procDecl
    :   annotations+=annotation*
        PROC
        method=methodSpec?
        name=ident
        typeParams=generics?
        L_PAREN (params=functionParamList COMMA?)? R_PAREN
        (COLON retType=typeExpr)?
        typeConstraints=whereClause?
        def=functionDef
    ;

functionParamList
    :   params+=functionParam
        (COMMA params+=functionParam)*
    ;

functionParam
    :   annotations+=annotation*
        name=ident
        COLON type=typeExpr
    ;

functionBody
    :   contracts+=contract*
        stmts+=stmt*
    ;

contract
    :   requiresContract # ContractRequires
    |   ensuresContract # ContractEnsures
    |   assignsContract # ContractAssigns
    ;

requiresContract
    :   REQUIRES
        (name=ident COLON)?
        spec=expr
        SEMICOLON
    ;

ensuresContract
    :   ENSURES
        (name=ident COLON)?
        spec=expr
        SEMICOLON
    ;

assignsContract
    :   ASSIGNS
        (name=ident COLON)?
        spec=expr
        SEMICOLON
    ;

annotation
    :   AT name=ident
        (L_PAREN (args=annotationArgList COMMA?)? R_PAREN)?
    ;

annotationArgList
    :   args+=annotationArg
        (COMMA args+=annotationArg)*
    ;

annotationArg
    :   (name=ident EQ)?
        value=expr
    ;

qualifiedTypeName
    :   typeName=fullName
        typeParams=generics?
    ;

fullName
    :   components+=ident
        (DOT components+=ident)*
    ;

whereClause
    :   WHERE constraints+=typeConstraint
        (COMMA constraints+=typeConstraint)*
        COMMA?
    ;

typeConstraint
    :   param=ident
        COLON
        bound=typeExpr
    ;

generics
    :   L_ANGLE (list=genericList COMMA?)? R_ANGLE
    ;

genericList
    :   params+=generic
        (COMMA params+=generic)*
    ;

generic
    :   variance=varianceSpec?
        name=ident
    ;

varianceSpec
    :   OUT # Covariant
    |   IN # Contravariant
    |   IN OUT # Invariant
    ;

typeExprList
    :   typeExprs+=typeExpr
        (COMMA typeExprs+=typeExpr)*
    ;

typeExpr
    :   lit=primitiveLit # TypeExprPrimitiveLit
    |   nameTypeExpr # TypeExprName
    |   pointerTypeExpr # TypeExprPointer
    |   lhs=typeExpr AMP rhs=typeExpr # TypeExprIntersection
    |   lhs=typeExpr PIPE rhs=typeExpr # TypeExprUnion
    ;

nameTypeExpr
    :   typeName=fullName
        typeArgs=typeArgSpec?
    ;

pointerTypeExpr
    :   ASTERISK
        base=typeExpr
    ;

typeArgSpec
    :   L_ANGLE (list=typeArgList COMMA?)? R_ANGLE
    ;

typeArgList
    :   typeArgs+=typeArg
        (COMMA typeArgs+=typeArg)*
    ;

typeArg
    :   variance=varianceSpec? typeExpr # TypeArgTypeExpr
    |   QUESTION # TypeArgWildcard
    ;

block
    :   stmt # BlockLoneStmt
    |   L_BRACE stmts+=stmt* R_BRACE # BlockBraced
    ;

stmt
    :   variableDecl # StmtVariableDecl
    |   ifStmt # StmtIf
    |   assignStmt # StmtAssign
    |   inner=expr SEMICOLON # StmtExpr
    ;

ifStmt
    :   IF
        L_PAREN condition=expr R_PAREN
        thenBranch=block
        (ELSE elseBranch=block)?
    ;

assignStmt
    :   lhs=access
        op=assignOp
        rhs=expr
        SEMICOLON
    ;

assignOp
    :   EQ # OpAssign
    |   PLUS_EQ # OpAddAssign
    |   MINUS_EQ # OpSubAssign
    |   ASTERISK_EQ # OpMulAssign
    |   SLASH_EQ # OpDivAssign
    |   PERCENT_EQ # OpModAssign
    |   AMP_EQ # OpBitAndAssign
    |   PIPE_EQ # OpBitOrAssign
    |   CARET_EQ # OpBitXorAssign
    |   L_ANGLE_L_ANGLE_EQ # OpLShiftAssign
    |   R_ANGLE_R_ANGLE_EQ # OpRShiftAssign
    ;

exprList
    :   exprs+=expr
        (COMMA exprs+=expr)*
    ;

atomicExpr
    :   L_PAREN inner=atomicExpr R_PAREN # AtomicExprParen
    |   lit=primitiveLit # AtomicExprPrimitiveLit
    |   signedNumLit # AtomicExprSignedNumLit
    |   arrayLitExpr # AtomicExprArrayLit
    |   access # AtomicExprAccess
    ;

signedNumLit
    :   sign lit=IntegerLit # SignedNumLitInt
    |   sign lit=FloatLit # SignedNumLitFloat
    ;

expr
    :   L_PAREN inner=expr R_PAREN # ExprParen
    |   lit=primitiveLit # ExprPrimitiveLit
    |   arrayLitExpr # ExprArrayLit
    |   base=access QUOTE # ExprPrev
    |   procCallExpr # ExprProcCall
    |   actionCallExpr # ExprActionCall
    |   instantiationExpr # ExprInstantiation
    |   access # ExprAccess
    |   op=unOp rhs=expr # ExprUnary
    |   lhs=access HAS concept=ident # ExprHasConcept
    |   lhs=expr IS type=typeExpr # ExprTypeComparison
    |   lhs=expr AS type=typeExpr # ExprCast
    |   lhs=expr op=mulBinOp rhs=expr # ExprMultiplicative
    |   lhs=expr op=addBinOp rhs=expr # ExprAdditive
    |   lhs=expr op=bitShiftOp rhs=expr # ExprShift
    |   lhs=expr AMP rhs=expr # ExprBitAnd
    |   lhs=expr CARET rhs=expr # ExprBitXor
    |   lhs=expr PIPE rhs=expr # ExprBitOr
    |   lhs=expr op=relOp rhs=expr # ExprRelational
    |   lhs=expr AMP_AMP rhs=expr # ExprAnd
    |   lhs=expr PIPE_PIPE rhs=expr # ExprOr
    ;

unOp
    :   PLUS # UnOpPlus
    |   MINUS # UnOpNeg
    |   TILDE # UnOpBitNot
    |   BANG # UnOpNot
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
    :   L_ANGLE L_ANGLE L_ANGLE # BinOpLogicalLeft
    |   R_ANGLE R_ANGLE R_ANGLE # BinOpLogicalRight
    |   L_ANGLE L_ANGLE # BinOpArithmeticLeft
    |   R_ANGLE R_ANGLE # BinOpArithmeticRight
    ;

relOp
    :   L_ANGLE_EQ # BinOpLessEquals
    |   R_ANGLE_EQ # BinOpGreaterEquals
    |   L_ANGLE # BinOpLess
    |   R_ANGLE # BinOpGreater
    |   EQ_EQ # BinOpEquals
    |   BANG_EQ # BinOpNotEquals
    |   IN # BinOpIn
    ;

primitiveLit
    :   IntegerLit # PrimitiveLitInt
    |   FloatLit # PrimitiveLitFloat
    |   StringLit # PrimitiveLitStringLit
    |   CharacterLit # PrimitiveLitChar
    |   TRUE # PrimitiveLitTrue
    |   FALSE # PrimitiveLitFalse
    |   NULL # PrimitiveLitNull
    ;

arrayLitExpr
    :   L_BRACKET (elems=exprList COMMA?)? R_BRACKET
    ;

procCallExpr
    :   callee=access
        typeArgs=typeArgSpec?
        L_PAREN (args=exprList COMMA?)? R_PAREN
    ;

actionCallExpr
    :   ACTION name=ident
        typeArgs=typeArgSpec?
        L_PAREN (args=exprList COMMA?)? R_PAREN
    ;

instantiationExpr
    :   NEW name=fullName
        typeArgs=typeArgSpec?
        L_PAREN (args=constructorArgList COMMA?)? R_PAREN
    ;

constructorArgList
    :   args+=constructorArg
        (COMMA args+=constructorArg)*
    ;

constructorArg
    :   STATE EQ state=ident # ConstructorArgState
    |   name=ident EQ value=expr # ConstructorArgVar
    ;

access
    :   name=ident # AccessName
    |   base=access DOT field=ident # AccessField
    |   base=access L_BRACKET index=expr R_BRACKET # AccessIndex
    |   name=ident typeArgs=typeArgSpec? L_PAREN inner=access R_PAREN DOT field=ident # AccessAutomatonField
    ;

ident
    :   Identifier
    |   STATIC
    |   IMPLEMENTS
    ;
