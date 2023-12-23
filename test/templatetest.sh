#!/bin/bash

set -e
set pipefail

TEST_DIR="$(cd $(dirname $0); pwd)"
cd "$TEST_DIR"

COMPILED_TEMPLATE="/tmp/compiled_templates.awk"

find template/pages -type f | awk '{ gsub("template/pages/", ""); print $0}' | awk -f ../bin/compile_templates.awk -v BASE_DIR=template/pages > "$COMPILED_TEMPLATE"


cmp <(echo '' | awk -f "$COMPILED_TEMPLATE" -f <(echo '{
  v["posts"][1]["title"] = "タイトル 空白が 入っていても 大丈夫";
  v["posts"][1]["blogname"] = "yammerjp";
  v["posts"][1]["id"] = 33;

  v["posts"][2]["title"] = "次の記事";
  v["posts"][2]["blogname"] = "yammerjp";
  v["posts"][2]["id"] = 33;

  print compiled_templates::render("_blogname/get.html", v)
}')) template/dist/_blogname/get.html


cmp <(echo '' | awk -f "$COMPILED_TEMPLATE" -f <(echo '{
  v["title"] = "タイトル 空白が 入っていても 大丈夫";
  v["content"] = "hello, world!\n<code>\nfoo\n</code>";
  v["created_at"] = "2023-12-23 11:25:00";

  print compiled_templates::render("_blogname/posts/_id/get.html", v)
}')) template/dist/_blogname/posts/_id/get.html
