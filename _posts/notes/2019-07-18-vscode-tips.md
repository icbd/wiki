---
layout: post
title:  vscode tips
date:   2019-07-18
categories: notes
---

## 快捷键

定位当前文件在目录中的位置: `command 0`

光标回到上一个位置: `control -`

## 文件显示全路径

> settings.json

```json
{
   "window.title": "${activeEditorLong}${separator}${rootName}"
}
```

## 自定义 live templates

在 markdown 文件中, 快速建立 Jekyll header

> Code -> Preferences -> User Snippets -> New Global Snippets File
> ~/Library/Application Support/Code/User/snippets/my_snippets.code-snippets

```json
{
   "wiki header": {
      "scope": "markdown,md",
      "prefix": [
         "wiki"
      ],
      "body": [
         "---",
         "layout: post",
         "title: ${TM_FILENAME/\\d+-\\d+-\\d+-(.*)\\..+/$1/}",
         "date:   $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE",
         "categories: ${TM_DIRECTORY/(.*)\\/(\\w+)$/$2/}",
         "---",
         "",
         "## "
      ]
   }
}
```
