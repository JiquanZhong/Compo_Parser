How to run the program:
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

   `    gcc $(if $(DEBUG),-g) -lql -o out/compo src/lex.yy.c src/y.tab.c src/ast.c src/code_generation.c` 

  In MacOS

   `    gcc $(if $(DEBUG),-g) -ll -o out/compo src/lex.yy.c src/y.tab.c src/ast.c src/code_generation.c`

5. Run `./out/compo tests/basic.md` basic.md is my testing markdown. The output html will be found in /out/result.html 

