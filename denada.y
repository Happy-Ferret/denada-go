%{

  /*

	Copyright 2014: Xogeny, Inc.

	CAUTION: If this file is a Go source file (*.go), it was generated
	automatically by '$ go tool yacc' from a *.y file - DO NOT EDIT in that case!

  */

package denada

import (
	"bytes"
	"fmt"
	"strings"

	"github.com/cznic/strutil"
)

%}

%union {
    identifier string
    bool       bool
    number     interface{}
	string     string
	elements   []Element
	element    Element
    expr       interface{}
    dict       map[string]interface{}
}

%token	BOOLEAN
%token	IDENTIFIER
%token	NUMBER
%token	STRING
%token  SEMI
%token  LPAREN
%token  RPAREN
%token  LBRACE
%token  RBRACE
%token  EQUALS
%token  COMMA

// Tokens
%type <bool> BOOLEAN
%type <string> IDENTIFIER
%type <number> NUMBER
%type <string> STRING

// Rules
%type <expr> Expr

%type <string> Description

%type <element> Elem
%type <element> Declaration
%type <element> Definition
%type <element> Preface
%type <element> QualifiersAndId QualifiersAndId1

%type <elements> File File1
%type <elements> Start

%type <dict> Modification Modifiers Modifiers1 Modifiers11 PrefaceModifiers

%start Start

%%

Declaration
: Preface Description SEMI {
  $$ = $1;
  $$.Description = $2;
}
| Preface EQUALS Expr Description SEMI {
  $$ = $1;
  $$.Value = $3;
  $$.Description = $4;
}

Description
: /* EMPTY */ { $$ = "" }
| STRING { $$ = $1 }

Definition
: Preface Description LBRACE File RBRACE {
  $$ = $1;
  $$.Description = $2;
  $$.Contents = $4;
}

Expr
: STRING { $$ = $1 }
| NUMBER { $$ = $1 }
| BOOLEAN { $$ = $1 }

File
: File1 { $$ = $1 }

File1
: /* EMPTY */ {	$$ = []Element{} }
| File1 Elem {
  $$ = append($1, $2);
}

Elem
: Definition { $$ = $1 }
| Declaration {	$$ = $1 }

Modification
: IDENTIFIER EQUALS Expr {
  $$ = map[string]interface{}{};
  $$[$1] = $3;
}

Modifiers
: LPAREN Modifiers1 RPAREN {
  $$ = $2;
}

Modifiers1
: /* EMPTY */ {	$$ = map[string]interface{}{} }
| Modification Modifiers11 {
  $$ = $2;
  for k, v := range($1) {
	  $$[k] = v;
  }
}

Modifiers11
: /* EMPTY */ {	$$ = map[string]interface{}{} }
| Modifiers11 COMMA Modification {
  $$ = $1;
  for k, v := range($3) {
	  $$[k] = v;
  }
}

Preface
: QualifiersAndId PrefaceModifiers {
  $$ = $1;
  $1.Modifications = $2;
}

PrefaceModifiers
: /* EMPTY */ {	$$ = map[string]interface{}{} }
| Modifiers	{ $$ = $1 }

QualifiersAndId
: QualifiersAndId1 IDENTIFIER {
  $1.Qualifiers = append($1.Qualifiers, $2);
  $$ = $1;
}

QualifiersAndId1
: /* EMPTY */ {	$$ = Element{} }
| QualifiersAndId1 IDENTIFIER {
  $1.Qualifiers = append($1.Qualifiers, $2);
  $$ = $1;
}

Start
: File {
  _parserResult = $1;
}

%%

var _parserResult interface{}

func _dump() {
	s := fmt.Sprintf("%#v", _parserResult)
	s = strings.Replace(s, "%", "%%", -1)
	s = strings.Replace(s, "{", "{%i\n", -1)
	s = strings.Replace(s, "}", "%u\n}", -1)
	s = strings.Replace(s, ", ", ",\n", -1)
	var buf bytes.Buffer
	strutil.IndentFormatter(&buf, ". ").Format(s)
	buf.WriteString("\n")
	a := strings.Split(buf.String(), "\n")
	for _, v := range a {
		if strings.HasSuffix(v, "(nil)") || strings.HasSuffix(v, "(nil),") {
			continue
		}
	
		fmt.Println(v)
	}
}
