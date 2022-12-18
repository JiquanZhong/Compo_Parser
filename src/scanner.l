%{
/*********** C CODE (YOU DO NOT HAVE TO MODIFY IT) ******************/
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ast.h"
#include "y.tab.h"

/* BEGIN MODE SYSTEM DECLARATION */
int mode_caller[8];
int mode_caller_len = 0;

void mode_caller_push(int mode);
int mode_caller_peek(void);
int mode_caller_pop(void);

#define BEGIN_MODE(mode) mode_caller_push(YY_START); BEGIN((mode));
#define END_MODE BEGIN(mode_caller_pop());
/* END MODE SYSTEM DECLARATION */

/* BEGIN STRING MANIPULATION DECLARATION */
#define STRBUFCAP 1024

char* strbuf = NULL;
size_t strbuflen = 0;

void strbufapp(char c);
char* strbufclr(void);
char* str_copy(char *str);
/* END STRING MANIPULATION DECLARATION */

/*********** END OF C CODE ******************/

/*
Here is my personal list of tokens for my grammar.
You are welcome to use it if your grammar does not match what was expected:

NEWLINE
BLANK_LINE
BOLD
ITALIC
UNDERLINE
STRUCK
H1
H2
H3
H4
H5
H6
QUOTE
EXCLAM
LPAREN
RPAREN
LBRACKET
RBRACKET
HR
BLOCK_CODE
INLINE_CODE
XSVG_BEGIN
XSVG_END
COMMA
LINE
POLYLINE
POLYGON
CIRCLE
ELLIPSE
RECT
XSVG_TEXT
TEXT
STR
NUMBER
*/

/** YOU WILL HAVE TO COMPLETE THE DOCUMENT BELOW **/
%}

newline "\n"
bold "**"
underline "__"
struck "~~"
italic "*"
blockcodestart "```\n"
blockcodeend "\n```"
blockcode "```"
inlinecode "`"
hrule "---"[-]*
quote ">"[[:blank:]]*
h6 "######"[[:blank:]]*
h5 "#####"[[:blank:]]*
h4 "####"[[:blank:]]*
h3 "###"[[:blank:]]*
h2 "##"[[:blank:]]*
h1 "#"[[:blank:]]*

%x BOLD_MODE TEXT_MODE UNDERLINE_MODE STRUCK_MODE ITALIC_MODE BLOCK_CODE_MODE INLINE_CODE_MODE SVG_MODE

%%

<INITIAL,BLOCK_CODE_MODE,SVG_MODE>[[:blank:]]*{newline} {
    return NEWLINE;
};

([[:blank:]]*{newline}){2} {
    return BLANK_LINE;
};

^{hrule} {
    return HRULE;
}

^{quote} {
    return QUOTE;
}

^{h6} {
    return H6;
}

^{h5} {
    return H5;
}

^{h4} {
    return H4;
}

^{h3} {
    return H3;
}

^{h2} {
    return H2;
}

^{h1} {
    return H1;
}

<INITIAL>{bold}	{
    BEGIN_MODE(BOLD_MODE); // You can switch to another mode

    return BOLD;
};

<INITIAL>{underline}	{
    BEGIN_MODE(UNDERLINE_MODE); // You can switch to another mode

    return UNDERLINE;
};

<INITIAL>{struck}	{
    BEGIN_MODE(STRUCK_MODE); // You can switch to another mode

    return STRUCK;
};

<INITIAL>{italic}	{
    BEGIN_MODE(ITALIC_MODE); // You can switch to another mode

    return ITALIC;
};

<INITIAL>{blockcodestart}	{
    BEGIN_MODE(BLOCK_CODE_MODE); // You can switch to another mode

    return BLOCKCODE;
};

<INITIAL>{inlinecode}	{
    BEGIN_MODE(INLINE_CODE_MODE); // You can switch to another mode

    return INLINECODE;
};

<BOLD_MODE>{bold} {
    END_MODE; // It will go back to the previous mode
    return BOLD;
};

<UNDERLINE_MODE>{underline} {
    END_MODE; // It will go back to the previous mode
    return UNDERLINE;
};

<STRUCK_MODE>{struck} {
    END_MODE; // It will go back to the previous mode
    return STRUCK;
};

<ITALIC_MODE>{italic} {
    END_MODE; // It will go back to the previous mode
    return ITALIC;
};

<BLOCK_CODE_MODE>{blockcodeend} {
    END_MODE; // It will go back to the previous mode
    return BLOCKCODE;
};

<INLINE_CODE_MODE>{inlinecode} {
    END_MODE; // It will go back to the previous mode
    return INLINECODE;
};


<INITIAL,BOLD_MODE>. {
    BEGIN_MODE(TEXT_MODE);
    strbufapp(*yytext);
};

<INITIAL,UNDERLINE_MODE>. {
    BEGIN_MODE(TEXT_MODE);
    strbufapp(*yytext);
};

<INITIAL,STRUCK_MODE>. {
    BEGIN_MODE(TEXT_MODE);
    strbufapp(*yytext);
}

<INITIAL,ITALIC_MODE>. {
    BEGIN_MODE(TEXT_MODE);
    strbufapp(*yytext);
}

<INITIAL,BLOCK_CODE_MODE>. {
    BEGIN_MODE(TEXT_MODE);
    strbufapp(*yytext);
}

<INITIAL,INLINE_CODE_MODE>. {
    BEGIN_MODE(TEXT_MODE);
    strbufapp(*yytext);
}

{blockcode}"xsvg:" {
    BEGIN_MODE(SVG_MODE);

    return SVG_BEGIN;
};

<SVG_MODE>{blockcode} {
    END_MODE;

    return SVG_END;
};

<SVG_MODE>"," {
    return COMMA;
};

<SVG_MODE>-?[[:digit:]]+ {
    yylval.number = atoi(yytext);

    return NUMBER;
};

<SVG_MODE>^"line" {
    return LINE;
};

<SVG_MODE>([[:alnum:]]|"#")+ {
    char* yytextcpy = malloc(strlen(yytext) + 1);
    yylval.text = strcpy(yytextcpy, yytext);
    return STR;
};

<TEXT_MODE>({newline}|{bold}|{underline}|{struck}|{italic}|{blockcodeend}|{inlinecode}|^{hrule}|^{quote}|^{h1}|^{h2}|^{h3}|^{h4}|^{h5}|^{h6})(.|\n)* {
    END_MODE;

    // We give the full capture to Flex to be analyzed again
    // otherwise the content will be lost
    yy_scan_string(yytext);

    char* txt = strbufclr(); // We retrieve the global string made with strbufapp()
    char *copy = str_copy(txt); // We have to make a copy of the global string or the yytext when needed
    yylval.text = copy;
    return TEXT;
};

<TEXT_MODE><<EOF>> {
    // <<EOF>> means the end of the markdown file.
    END_MODE;

    char* txt = strbufclr();
    char *copy = str_copy(txt);
    yylval.text = copy;

    return TEXT;
};

<TEXT_MODE>. {
    strbufapp(*yytext);
};

%%

/*********** C CODE (YOU DO NOT HAVE TO MODIFY IT) ******************/
void mode_caller_push(int mode) {
    mode_caller[mode_caller_len++] = mode;
}

int mode_caller_peek(void) {
    return mode_caller_len == 0 ? INITIAL : mode_caller[mode_caller_len - 1];
}

int mode_caller_pop(void) {
    int caller = mode_caller_peek();
    if (mode_caller_len > 0) {
        mode_caller_len--;
    }
    return caller;
}

void strbufapp(char c) {
    if (strbuf == NULL) {
        strbuf = malloc(sizeof(char) * STRBUFCAP);
    }
    if (strbuflen >= STRBUFCAP - 2) {
        char* new_strbuf = malloc(sizeof(char) * 2 * STRBUFCAP);
        strncpy(new_strbuf, strbuf, strbuflen);
        free(strbuf);
        strbuf = new_strbuf;
    }
    strbuf[strbuflen++] = c;
}

char* strbufclr(void) {
    strbuf[strbuflen] = '\0';
    strbuflen = 0;
    return strbuf;
}

char* str_copy(char *str) {
    char* copy = malloc(strlen(str) + 1);

    strcpy(copy, str);

    return copy;
}

/*********** END OF C CODE ******************/
