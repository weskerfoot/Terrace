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
  /* TODO check for exceptions here, e.g. broken symlinks */
  MarkdownFile[] mdfiles = [];
  string[] subdirs = [];

  foreach (string name; dirEntries(directory, SpanMode.shallow)) {
    string extension = name.split(".").back;
    if (extension == "md") {
      /* TODO detect encoding of file */
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

string
renderTOC(DirTree tree)
{
  if (tree.mdfiles.length == 0) {
    return "";
  }

  string[] rootName = tree.mdfiles[0].name.split("/");

  return ("<h3>" ~ (rootName.length > 1 ? rootName[0..($-1)].join("/") : "root") ~ "</h3>") ~
            (("<ul>" ~ tree.mdfiles.map!((f) => "<li>" ~ f.name ~ "</li>").array.join(""))
              ~ (tree.subdirs.map!(renderTOC).array.join(""))
          ~ "</ul>");
}

void
createIndex()
  /* Creates the index.html file */
{

  if (!"./site".exists) "./site".mkdir;
}

void
main()
{
  DirTree tree = getFileTree("");
  writeln(renderTOC(tree));
}
