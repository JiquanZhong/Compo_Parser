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

svg_instruction_list -> svg_instruction NEWLINE svg_instruction_list 
		      | ε

svg_instruction -> LINE svg_coord svg_coord svg_attribute
                 | POLYLINE svg_coord svg_coord svg_coord svg_attribute svg_attribute
                 | CIRCLE svg_coord NUMBER svg_attribute svg_attribute
                 | ELLIPSE svg_coord NUMBER NUMBER svg_attribute svg_attribute
                 | RECT svg_coord NUMBER NUMBER svg_attribute svg_attribute
                 | TEXT svg_coord STR svg_attribute
			
svg_attribute -> STR 
	       | ε

svg_coord -> NUMBER COMMA NUMBER
```

## The functionalities implemented

| Markdown                        | HTML                |
| ------------------------------- | ------------------- |
| Paragraph                       | <p> tag             |
| Bold text (**...**)             | <b> tag             |
| Italic text (*...*)             | <i> tag             |
| Underlined text (__...__)       | <u> tag             |
| Strikethrough text (~~...~~)    | <s> tag             |
| Titles (# to ######)            | <h1> to <h6> tags   |
| Quotes (> ...)                  | <blockquote> tag    |
| Inline code (`...`)             | <code> tag          |
| Block code (```...```)          | <pre> tag           |
| SVG extension (```xsvg  ...```) | See the table below |
| Horizontal rule (---)           | <hr> tag            |

For the SVG functionalities:

| SVG extension                                  | SVG            |
| ---------------------------------------------- | -------------- |
| line x1,y1 x2,y2 (color)                       | <line> tag     |
| polyline x1,y1 ...(color)                      | <polyline> tag |
| polygon x1,y1 ...(color-fill)  (color-stroke)  | <polygon> tag  |
| circle x,y r (color-fill)  (color-stroke)      | <circle> tag   |
| ellipse x,y rx ry  (color-fill) (color-stroke) | <ellipse> tag  |
| rect x,y w h (color-fill)  (color-stroke)      | <rect> tag     |

## **Test**

The test file for all functions is /tests/basic.md:

````markdown
# title1

## title2

### title3

#### title4

##### title5

###### title6

I'm a paragraph.
It's second line
It's third line

I am **bold**!

I'm ~~struck~~

I'm *italic*

> This is a quote

---

----------

I'm `Inline code`

```
first line code
second line code
third line code
```

```xsvg:0,0,100,100 
line 0,0 100,100 blue 
```

```xsvg:0,0,50,50
polyline 0,0 20,0 0,20 red black
```

```xsvg:0,0,50,50
polyline 0,0 20,0 0,20 red
```

```xsvg:0,0,50,50
circle 50,50 50 red blue
```

```xsvg:0,0,50,50
ellipse 10,10 5 10 red blue
```
  
```xsvg:0,0,50,50
rect 0,0 10 20 red black
```
  
```xsvg:0,0,200,100
text 0,50 "Mytext" red
```
````

And the output file is out/result.html:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="utf-8">
    <title>Markdown to HTML</title>
    <link rel="stylesheet" href="github-markdown.css">
  </head>
  <body>
  <article class="markdown-body">
  <h1>title1</h1>
  <h2>title2</h2>
  <h3>title3</h3>
  <h4>title4</h4>
  <h5>title5</h5>
  <h6>title6</h6>
  <p>    I'm a paragraph. <br/>It's second line <br/>It's third line  </p>
  <p>    I am  <b>bold</b> !  </p>
  <p>    I'm  <s>struck</s>  </p>
  <p>    I'm  <i>italic</i>  </p>
  <blockquote>This is a quote</blockquote>
  <hr/>
  <hr/>
  <p>    I'm  <code>Inline code</code>  </p>
<pre><code>first line code
second line code
third line code</code></pre>
  <svg viewBox="0 0 100 100">
    <line x1="0" y1="0" x2="100" y2="100" stroke="blue"/>
  </svg>
  <svg viewBox="0 0 50 50">
    <polyline points="0,0 20,0 0,20" fill="red" stroke="black"/> 
  </svg>
  <svg viewBox="0 0 50 50">
    <polyline points="0,0 20,0 0,20" fill="red" /> 
  </svg>
  <svg viewBox="0 0 50 50">
    <circle cx="50" cy="50" r="50" fill="red" stroke="blue"/> 
  </svg>
  <svg viewBox="0 0 50 50">
    <ellipse cx="10" cy="10" rx="5" ry="10" fill="red" stroke="blue"/> 
  </svg>
  <svg viewBox="0 0 50 50">
    <rect x="0" y="0" width="10" height="20" fill="red" stroke="black"/> 
  </svg>
  <svg viewBox="0 0 200 100">
    <text x="0" y="50" fill="red" >Mytext</text>
  </svg>
  </article>
  </body>
</html>
```
