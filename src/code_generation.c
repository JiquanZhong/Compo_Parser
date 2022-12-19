#include "ast.h"
#include "stdio.h"

#define SIMPLE_STRINGS_IMPL
#include "simple_strings.h"
#include <string.h>

const char HTML_HEADER[] = 	"<!DOCTYPE html>\n"
                            "<html>\n"
                            "  <head>\n"
                            "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
                            "    <meta charset=\"utf-8\">\n"
                            "    <title>Markdown to HTML</title>\n"
                            "    <link rel=\"stylesheet\" href=\"github-markdown.css\">\n"
                            "  </head>\n"
                            "  <body>\n"
                            "  <article class=\"markdown-body\">\n";

const char HTML_FOOTER[] = 	"  </article>\n"
                            "  </body>\n"
                            "</html>";

void add_indentation(string str, unsigned int indent_lvl) {
    for (int t = 0; t < indent_lvl; t++) {
        APPEND_ARR(str, "  ");
    }
}

#include <stdio.h>
#include <stdlib.h>

char* itoa(int val){
    if(val == 0){return STR("0");}
	static char buf[32] = {0};
	int i = 30;
	for(; val && i ; --i, val /= 10)
		buf[i] = "0123456789abcdef"[val % 10];
	return &buf[i+1];
}

string stroke_html(SvgInst* svg){
    string html = STR("");
    if(svg->color_stroke != NULL){
        html = STR("stroke=\"");
        APPEND_ARR(html,svg->color_stroke);
        APPEND_ARR(html,"\"");
    }
    return html;
}

string fill_html(SvgInst* svg){
    string html = STR("");
    if(svg->color_fill != NULL){
        html = STR("fill=\"");
        APPEND_ARR(html,svg->color_fill);
        APPEND_ARR(html,"\" ");
    }
    return html;
}

string code_generation_from_svg(SvgList* svg_list){
    SvgInst* svg = svg_list->svg;
    switch(svg->kind) {
        case Line: {
            string html = STR("    <line ");
            //0,0
            //获取了坐标链表的根结点
            SvgCoordList* coords_list = svg->coords;
            //获取坐标对象
            SvgCoord* coord = coords_list->coord;
            APPEND_ARR(html,"x1=\"");
            APPEND_ARR(html,itoa(coord->x));
            APPEND_ARR(html,"\" y1=\"");
            APPEND_ARR(html,itoa(coord->y));
            APPEND_ARR(html,"\" x2=\"");

            //get 100,100
            coords_list = coords_list->next;
            coord = coords_list->coord;
            APPEND_ARR(html,itoa(coord->x));
            APPEND_ARR(html,"\" y2=\"");
            APPEND_ARR(html,itoa(coord->y));
            APPEND_ARR(html,"\" ");


            APPEND_ARR(html,stroke_html(svg));
            APPEND_ARR(html,"/>\n");

            return html;
        }
        case Polyline: {
            string html = STR("    <polyline points=\"");
            SvgCoordList* coords_list = svg->coords;

            while(coords_list != NULL){
            SvgCoord* coord = coords_list->coord;
            APPEND_ARR(html,itoa(coord->x));
            APPEND_ARR(html,",");
            APPEND_ARR(html,itoa(coord->y));
            if(coords_list ->next != NULL){
                APPEND_ARR(html," ");
            }
            coords_list = coords_list->next;
            }
            
            APPEND_ARR(html,"\" ");
            APPEND_ARR(html,fill_html(svg));
            APPEND_ARR(html,stroke_html(svg));
            APPEND_ARR(html,"/> ");
            APPEND_ARR(html,"\n");
            return html;
        }
        case Circle: {
            string html = STR("    <circle cx=\"");
            SvgCoordList* coords_list = svg->coords;
            SvgCoord* coord = coords_list->coord;
            APPEND_ARR(html,itoa(coord->x));
            APPEND_ARR(html,"\" cy=\"");
            APPEND_ARR(html,itoa(coord->y));
            APPEND_ARR(html,"\" r=\"");
            APPEND_ARR(html,itoa(svg->rayon));
            APPEND_ARR(html,"\" ");
            APPEND_ARR(html,fill_html(svg));
            APPEND_ARR(html,stroke_html(svg));
            APPEND_ARR(html,"/> ");
            APPEND_ARR(html,"\n");
            return html;
        }
        case Ellipse: {
            string html = STR("    <ellipse cx=\"");
            SvgCoordList* coords_list = svg->coords;
            SvgCoord* coord = coords_list->coord;
            APPEND_ARR(html,itoa(coord->x));
            APPEND_ARR(html,"\" cy=\"");
            APPEND_ARR(html,itoa(coord->y));
            APPEND_ARR(html,"\" rx=\"");
            APPEND_ARR(html,itoa(svg->width));
            APPEND_ARR(html,"\" ry=\"");
            APPEND_ARR(html,itoa(svg->height));
            APPEND_ARR(html,"\" ");
            APPEND_ARR(html,fill_html(svg));
            APPEND_ARR(html,stroke_html(svg));
            APPEND_ARR(html,"/> ");
            APPEND_ARR(html,"\n");
            return html;
        }
        case Rect: {
            string html = STR("    <rect x=\"");
            SvgCoordList* coords_list = svg->coords;
            SvgCoord* coord = coords_list->coord;
            APPEND_ARR(html,itoa(coord->x));
            APPEND_ARR(html,"\" y=\"");
            APPEND_ARR(html,itoa(coord->y));
            APPEND_ARR(html,"\" width=\"");
            APPEND_ARR(html,itoa(svg->width));
            APPEND_ARR(html,"\" height=\"");
            APPEND_ARR(html,itoa(svg->height));
            APPEND_ARR(html,"\" ");
            APPEND_ARR(html,fill_html(svg));
            APPEND_ARR(html,stroke_html(svg));
            APPEND_ARR(html,"/> ");
            APPEND_ARR(html,"\n");
            return html;
        }
        case Text: {
            string html = STR("    <text x=\"");
            SvgCoordList* coords_list = svg->coords;
            SvgCoord* coord = coords_list->coord;
            APPEND_ARR(html,itoa(coord->x));
            APPEND_ARR(html,"\" y=\"");
            APPEND_ARR(html,itoa(coord->y));
            APPEND_ARR(html,"\" ");
            APPEND_ARR(html,fill_html(svg));
            APPEND_ARR(html,">");

            APPEND_ARR(html,svg->text);
            APPEND_ARR(html,"</text>\n");
            return html;
        }
        default: {
            return STR("");
        }
    }
}

string code_generation_from_dom(DOM* dom, unsigned int indent) {
    /*
    YOU HAVE TO COMPLETE THIS FUNCTION TO PRODUCE THE HTML EQUIVALENT FOR EACH DOM ELEMENT
    */
    if (dom == NULL) return STR("");

    switch (dom->dom_el) {
        case Document: {
            string html = STR("");
            add_indentation(html, indent);

            DomList *child = dom->children;

            while (child != NULL) {
                string child_html = code_generation_from_dom(child->dom, indent + 1);

                APPEND_STR(html, child_html);

                child = child->next;
            }

            return html;
        }
        case Header1: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h1>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h1>\n");

            return html;
        }
        case Header2: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h2>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h2>\n");

            return html;
        }
        case Header3: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h3>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h3>\n");

            return html;
        }
        case Header4: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h4>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h4>\n");

            return html;
        }
        case Header5: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h5>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h5>\n");

            return html;
        }
        case Header6: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h6>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h6>\n");

            return html;
        }
        case Quote: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<blockquote>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</blockquote>\n");

            return html;
        }
        case HRule: {
            string html = STR("");
            add_indentation(html, indent);
            APPEND_ARR(html, "<hr/>\n");

            return html;
        }
        case Paragraph: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<p>");

            DomList *child = dom->children;
            DOM *previous_child = NULL;

            while (child != NULL) {
                // We check here if we have two TextElement besides, it should have a space between.
                if (previous_child != NULL) {
                    if (previous_child->dom_el == TextElement) {
                        APPEND_ARR(html, "");
                    }
                } else {
                    add_indentation(html, indent + 1);
                }

                string content = code_generation_from_dom(child->dom, indent + 1); // Indentation not relevant here

                APPEND_STR(html, content);

                previous_child = child->dom;
                child = child->next;
            }

            // APPEND_ARR(html, "\n");
            add_indentation(html, indent);
            APPEND_ARR(html, "</p>\n");

            return html;
        }
        case TextElement: {
            string html = STR(dom->text);
            // APPEND_STR(html,"\n");
            return html;
        }
        case Bold: {
            string html = STR("<b>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</b>");

            return html;
        }
        case Struck: {
            string html = STR("<s>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</s>");

            return html;
        }
        case Italic: {
            string html = STR("<i>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</i>");

            return html;
        }
        case InlineCode: {
            string html = STR("<code>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</code>");

            return html;
        }
        case BlockCode: {
            string html = STR("  <pre><code>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "  </code></pre>\n");

            return html;
        }
        case SVG: {
            string html = STR("  <svg viewBox=\"");
            APPEND_ARR(html,itoa(dom->x_y->x));
            APPEND_ARR(html," ");
            APPEND_ARR(html,itoa(dom->x_y->y));
            APPEND_ARR(html," ");
            APPEND_ARR(html,itoa(dom->u_v->x));
            APPEND_ARR(html," ");
            APPEND_ARR(html,itoa(dom->u_v->y));
            APPEND_ARR(html,"\">\n");


            SvgList *svg_children = dom->svg_children;

            while (svg_children != NULL) {
                string child_html = code_generation_from_svg(svg_children);

                APPEND_STR(html, child_html);

                svg_children = svg_children->next;
            }
            
            APPEND_ARR(html, "  </svg>\n");
            return html;
        }
        default: {
            return STR("");
        }
    }
}

string code_generation(DOM* dom) {
    string final_code = STR(HTML_HEADER);
    string dom_code = code_generation_from_dom(dom, 0);

    APPEND_STR(final_code, dom_code);
    APPEND_ARR(final_code, HTML_FOOTER);

    spls_free_string(dom_code);

    return final_code;
}
