%option noyywrap

%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

#define yylval cool_yylval
#define yylex  cool_yylex

#define MAX_STR_CONST 1025
#define YY_NO_UNPUT

extern FILE *fin;

#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

int nested_comment_level = 0;
char string_buf[MAX_STR_CONST];
char *string_buf_ptr;
int string_too_long;

void string_add(char c) {
  if (string_buf_ptr - string_buf < MAX_STR_CONST - 1) {
    *string_buf_ptr++ = c;
  } else {
    string_too_long = 1;
  }
}

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

%}

%x STRING
%x INLINE_COMMENT
%x NESTED_COMMENT

DIGIT               [0-9]
NUMBER              {DIGIT}+
LETTER              [a-zA-Z_]
WHITESPACE          [ \n\f\r\t\v]
ESCAPED_CHAR        \\[^\n\0]
ESCAPED_NEWLINE     \\\n
STRING_CHAR         [^\\\n\"\0]+

TYPEID              [A-Z]({LETTER}|{DIGIT})*
OBJECTID            [a-z]({LETTER}|{DIGIT})*

DARROW              =>
ASSIGN              <-
LE                  <=

OPS                 [-+*\/:~<=(){};.,@]

%%

\" {
  string_too_long = 0;
  string_buf_ptr = string_buf;
  BEGIN(STRING);
}

<STRING>\" {
  if (string_too_long) {
    BEGIN(INITIAL);
    cool_yylval.error_msg = "String constant too long";
    return ERROR;
  } else {
    BEGIN(INITIAL);
    *string_buf_ptr = '\0';
    cool_yylval.symbol = stringtable.add_string(string_buf);
    return STR_CONST;
  }
}

<STRING>{ESCAPED_NEWLINE} {
  curr_lineno++;
}

<STRING>\n {
  BEGIN(INITIAL);
  curr_lineno++;
  cool_yylval.error_msg = "Unterminated string constant";
  return ERROR;
}

<STRING><<EOF>> {
  BEGIN(INITIAL);
  cool_yylval.error_msg = "EOF in string constant";
  return ERROR;
}

<STRING>\0 {
  BEGIN(INITIAL);
  cool_yylval.error_msg = "NULL in string constant";
  return ERROR;
}

<STRING>{ESCAPED_CHAR} {
  char c;
  switch (yytext[1]) {
    case 'b':  c = '\b'; break;
    case 't':  c = '\t'; break;
    case 'n':  c = '\n'; break;
    case 'f':  c = '\f'; break;
    default:   c = yytext[1];
  }
  string_add(c);
}

<STRING>{STRING_CHAR} {
  char *yptr = yytext;
  while ( *yptr ) {
    string_add(*yptr);
    yptr++;
  }
}

{NUMBER} {
  cool_yylval.symbol = inttable.add_string(yytext);
  return INT_CONST; 
}

{DARROW} return DARROW;
{ASSIGN} return ASSIGN;
{LE}     return LE;

{OPS} {
  return yytext[0];
}

\n curr_lineno++;

{WHITESPACE} ;

(?i:class)          return CLASS;
(?i:else)           return ELSE;
(?i:fi)             return FI;
(?i:if)             return IF;
(?i:in)             return IN;
(?i:inherits)       return INHERITS;
(?i:isvoid)         return ISVOID;
(?i:let)            return LET;
(?i:loop)           return LOOP;
(?i:pool)           return POOL;
(?i:then)           return THEN;
(?i:while)          return WHILE;
(?i:case)           return CASE;
(?i:esac)           return ESAC;
(?i:new)            return NEW;
(?i:of)             return OF;
(?i:not)            return NOT;
t(?i:rue)           cool_yylval.boolean = true;  return BOOL_CONST;
f(?i:alse)          cool_yylval.boolean = false; return BOOL_CONST;

-- {
  BEGIN(INLINE_COMMENT);
}

<INLINE_COMMENT>\n {
  BEGIN(INITIAL);
  curr_lineno++;
}

<INLINE_COMMENT,NESTED_COMMENT>. {}

<INITIAL,NESTED_COMMENT>"(*" {
  if (nested_comment_level == 0) {
    BEGIN(NESTED_COMMENT);
  }
  nested_comment_level++;
}

<NESTED_COMMENT>"*)"  if (!--nested_comment_level) { BEGIN(INITIAL); }

<NESTED_COMMENT>\n curr_lineno++;

<INLINE_COMMENT,NESTED_COMMENT><<EOF>> {
  BEGIN(INITIAL);
  yylval.error_msg = "EOF in comment";
  return ERROR;
}

{TYPEID} {
  cool_yylval.symbol = idtable.add_string(yytext);
  return TYPEID;
}

{OBJECTID} {
  cool_yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;
}

.  {
  cool_yylval.error_msg = yytext;
  return ERROR;
}

%%
