## How to run the program
1. Put the target markdown file in tests directory

2. Installing Flex(version >= 2.5.35) and Bison(version >= 3.8.2)

3. Change the Makefile permissions if necessary
  ```
  sudo chmod 777 Makefile
  ```

4. Compiling the object file

  ```
  ./Makefile
  ```

  Attention:

  The Makefile should be changed as: 

  In linux or windows,

  `gcc $(if $(DEBUG),-g) -lql -o out/compo src/lex.yy.c src/y.tab.c src/ast.c src/code_generation.c` 

  In MacOS

  `gcc $(if $(DEBUG),-g) -ll -o out/compo src/lex.yy.c src/y.tab.c src/ast.c src/code_generation.c`

5. Run `./out/compo tests/basic.md` basic.md is my testing markdown. The output html will be found in /out/result.html 

## Grammar rules
```
document -> block_list

block_list -> block BLANK_LINE block_list
	     | block

block -> HRULE
       | QUOTE TEXT
       | H1 TEXT
       | H2 TEXT
       | H3 TEXT
       | H4 TEXT
       | H5 TEXT
       | H6 TEXT
       | BLOCKCODE paragraph BLOCKCODE
       | paragraph
       | svg

Paragraph -> line NEWLINE paragraph 
		| line

Line -> text line
	| text

text -> TEXT
      | BOLD text BOLD
      | UNDERLINE text UNDERLINE
      | STRUCK text STRUCK
      | ITALIC text ITALIC
      | INLINECODE text INLINECODE
		
For the SVG part, the definition of grammar is as follos:

Svg -> SVG_BEGIN svg_coord COMMA svg_coord NEWLINE svg_instruction_list SVG_END

svg_instruction_list -> svg_instruction NEWLINE svg_instruction_list | ε

svg_instruction -> LINE svg_coord svg_coord svg_attribute
                 | POLYLINE svg_coord svg_coord svg_coord svg_attribute svg_attribute
                 | CIRCLE svg_coord NUMBER svg_attribute svg_attribute
                 | ELLIPSE svg_coord NUMBER NUMBER svg_attribute svg_attribute
                 | RECT svg_coord NUMBER NUMBER svg_attribute svg_attribute
                 | TEXT svg_coord STR svg_attribute
			
svg_attribute -> STR | ε

svg_coord -> NUMBER COMMA NUMBER
```