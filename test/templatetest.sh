#!/bin/bash

set -e
set pipefail

TEMPLATE_DIR="$(cd $(dirname $0); pwd)"
cd "$TEMPLATE_DIR/template"

COMPILED_TEMPLATE="/tmp/compiled_templates.awk"

find ./ -type f | sed 's#^./##g'| awk -f ../../misc/compile_templates.awk > "$COMPILED_TEMPLATE"

diff <(echo '' | awk -f "$COMPILED_TEMPLATE" -f <(echo '{
  v["posts"][1]["title"] = "タイトル 空白が 入っていても 大丈夫";
  v["posts"][1]["account_name"] = "yammerjp";
  v["posts"][1]["id"] = 33;

  v["posts"][2]["title"] = "次の記事";
  v["posts"][2]["account_name"] = "yammerjp";
  v["posts"][2]["id"] = 33;

  print compiled_templates::render("pages/_account_name/get.html", v)
}')) dist/_account_name/get.html


cmp <(echo '' | awk -f "$COMPILED_TEMPLATE" -f <(echo '{
  v["title"] = "タイトル 空白が 入っていても 大丈夫";
  v["content"] = "hello, world!\n<code>\nfoo\n</code>";
  v["created_at"] = "2023-12-23 11:25:00";

  print compiled_templates::render("pages/_account_name/posts/_id/get.html", v)
}')) dist/_account_name/posts/_id/get.html
