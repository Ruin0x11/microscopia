std = "lua51c+luajit"
ignore = {
   "212"  -- unused argument 'self'
}

files["scratch/**/*.lua"].ignore = {
   "111", -- setting non-standard global variable 'X'
   "113"  -- accessing undefined variable 'X'
}

globals = {
   "require",
   "data",
   "config",
   "mobdebug",
   "_CONSOLE",
   "_DEBUG",
   "_IS_LOVEJS",
   "_MOD_NAME",
   "love",
   "class",
   "inspect",
   "fun",
   "cpml",
   "_ppr",
   "save",
   "utf8",
   "help",
   "pause",

   math = {
      fields = {
         "clamp"
      }
   },
   string = {
      fields = {
         "split"
      }
   },
   table = {
      fields = {
         "unpack"
      }
   },
}

files["**/locale/**/*.lua"] = {ignore = {"212"}}

stds.i18n_jp = {
   globals = {
      "get",

      "you",
      "name",
      "basename",
      "itemname",
      "ordinal",
      "he",
      "his",
      "him",

      "kare_wa",
      "aru",
      "u",
      "ka",
      "ga",
      "kimi",
      "ore",
      "kana",
      "kure",
      "ta",
      "da",
      "dana",
      "daro",
      "tanomu",
      "noda",
      "yo",
      "na",
      "ru",
   }
}

files["**/locale/jp/**/*.lua"].std = "+i18n_jp"
files["**/locale/jp/*.lua"].std = "+i18n_jp"

stds.i18n_en = {
   globals = {
      "get",

      "you",
      "name",
      "basename",
      "itemname",
      "ordinal",
      "he",
      "his",
      "him",

      "s",
      "is",
      "have",
      "does",
      "his_owned",
      "himself",
      "trim_job",
      "name_nojob",
      "capitalize",
   }
}

files["**/locale/en/**/*.lua"].std = "+i18n_en"
files["**/locale/en/*.lua"].std = "+i18n_en"
