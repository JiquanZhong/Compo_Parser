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
INLINE_CODE
BLOCK_CODE
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
quote ">"[[:blank:]]*
h6 "######"[[:blank:]]*
h5 "#####"[[:blank:]]*
h4 "####"[[:blank:]]*
h3 "###"[[:blank:]]*
h2 "##"[[:blank:]]*
h1 "#"[[:blank:]]*

%x BOLD_MODE TEXT_MODE UNDERLINE_MODE STRUCK_MODE ITALIC_MODE

%%

<INITIAL>[[:blank:]]*{newline} {
    return NEWLINE;
};

([[:blank:]]*{newline}){2} {
    return BLANK_LINE;
};

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

<TEXT_MODE>({newline}|{bold}|{underline}|{struck}|{italic}|^{quote}|^{h1}|^{h2}|^{h3}|^{h4}|^{h5}|^{h6})(.|\n)* {
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
