import std.stdio;
import std.algorithm;
import std.file;
import std.string;
import std.array;
import std.format;
import std.typecons;

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

/* Represents a directory tree with associated list of markdown files */
/* This allows for basically any structure, all you need are markdown files anywhere */
/* The tree will be displayed alongside every page, with collapsable links, etc */
/* A table of contents will be put at the top of every page to navigate as well */
struct DirTree
{
  MarkdownFile[] mdfiles;
  DirTree[] subdirs;
}

DirTree
getFileTree(string directory)
{
  MarkdownFile[] mdfiles = [];
  string[] subdirs = [];

  foreach (string name; dirEntries(directory, SpanMode.shallow)) {
    string extension = name.split(".").back;
    if (extension == "md") {
      mdfiles ~= MarkdownFile(name, name.readText);
    }
    else if (name.isDir) {
      subdirs ~= name;
    }
  }

  DirTree[] children = subdirs
                       .map!((d) => getFileTree(d))
                       .filter!((dtree) => dtree.mdfiles || dtree.subdirs)
                       .array;

  return DirTree(mdfiles, children);
}


void
createIndex()
  /* Creates the index.html file */
{

  mdfiles.each!(f => f.name.split("/").writeln);

  if (!"./site".exists) "./site".mkdir;
}

void
main()
{
  getFileTree("");
}
