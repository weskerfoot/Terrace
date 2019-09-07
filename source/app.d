import std.stdio;
import std.algorithm;
import std.file;
import std.string;
import std.array;

/* markdown rendering imports */
import hunt.markdown.node.Node;
import hunt.markdown.parser.Parser;
import hunt.markdown.renderer.html.HtmlRenderer;

struct MarkdownFile
{
  string name;
  string content;

  string render() {
    Parser parser = Parser.builder().build();
    HtmlRenderer renderer = HtmlRenderer.builder().build();
    return "<p>" ~ renderer.render(parser.parse(content)) ~ "</p>";
  }
}

MarkdownFile[]
getMarkdown()
{

  MarkdownFile[] md_files = [];

  foreach (string name; dirEntries("", SpanMode.breadth)) {

    string extension = name.split(".").back;

    if (extension == "md") {
      MarkdownFile mdfile = {
        name: name,
        content: name.readText
      };

      md_files ~= [mdfile];
    }
  }
  return md_files;
}

string[]
createHeaderLinks()
{
  return [];
}

void
createIndex()
  /* Creates the index.html file */
{
  std.file.write("index.html",
                 map!((f) => f.render)(getMarkdown).join("\n"));
}

void
main()
{
  createIndex();
}
