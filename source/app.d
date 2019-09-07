import std.stdio;
import std.algorithm;
import std.file;
import std.string;
import std.array;
import std.format;

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


void
createIndex()
  /* Creates the index.html file */
{
  MarkdownFile[] mdfiles = getMarkdown;

  mdfiles.each!(f => f.name.split("/").writeln);

  if (!"./site".exists) "./site".mkdir;

  string
  headerLink(MarkdownFile f)
  {
    string filename = f.name.replace("/", "_");
    std.file.write("./site/" ~ filename ~ ".html", f.render);
    return `<a href="/site/%s">%s</a></br>`.format(f.name.replace("/", "_"), f.name);
  }

  std.file.write("index.html",
                 mdfiles.map!(headerLink).join("\n"));
}

void
main()
{
  createIndex();
}
