# --- Theme creation ---

# t2f_theme creates valid theme object
theme <- t2f_theme(name = "test", scolor = "red!10")
expect_inherits(theme, "t2f_theme")
expect_equal(theme$name, "test")
expect_equal(theme$scolor, "red!10")

# built-in themes are accessible
expect_inherits(t2f_theme_minimal(), "t2f_theme")
expect_inherits(t2f_theme_apa(), "t2f_theme")
expect_inherits(t2f_theme_nature(), "t2f_theme")
expect_inherits(t2f_theme_nejm(), "t2f_theme")
expect_inherits(t2f_theme_lancet(), "t2f_theme")

# t2f_list_themes returns built-in themes
themes <- t2f_list_themes(builtin_only = TRUE)
expect_true("minimal" %in% themes)
expect_true("apa" %in% themes)
expect_true("nature" %in% themes)
expect_true("nejm" %in% themes)
expect_true("lancet" %in% themes)


# --- Theme set/get ---

# t2f_theme_set and t2f_theme_get work
old <- t2f_theme_set(NULL)
expect_null(t2f_theme_get())

t2f_theme_set("nejm")
current <- t2f_theme_get()
expect_inherits(current, "t2f_theme")
expect_equal(current$name, "nejm")
t2f_theme_set(old)


# --- Theme registration ---

# t2f_theme_register adds custom theme
jama <- t2f_theme(name = "jama", scolor = "white", striped = FALSE)
expect_message(t2f_theme_register(jama), "registered successfully")
expect_true("jama" %in% t2f_list_themes())
t2f_theme_clear()

# t2f_theme_register rejects non-theme objects
expect_error(
  t2f_theme_register(list(name = "fake")),
  "must be a t2f_theme object"
)

# t2f_theme_register prevents overwriting built-in themes
theme_nejm <- t2f_theme(name = "nejm")
expect_error(
  t2f_theme_register(theme_nejm),
  "Cannot register theme with built-in name"
)

# t2f_theme_register prevents duplicates without overwrite
theme1 <- t2f_theme(name = "custom1", scolor = "blue!10")
theme2 <- t2f_theme(name = "custom1", scolor = "red!10")
expect_message(t2f_theme_register(theme1), "registered successfully")
expect_error(t2f_theme_register(theme2), "already registered")
t2f_theme_clear()

# t2f_theme_register allows overwrite with flag
theme1 <- t2f_theme(name = "custom2", scolor = "blue!10")
theme2 <- t2f_theme(name = "custom2", scolor = "red!10")
t2f_theme_register(theme1)
expect_message(
  t2f_theme_register(theme2, overwrite = TRUE),
  "registered successfully"
)
retrieved <- zztab2fig:::get_builtin_theme("custom2")
expect_equal(retrieved$scolor, "red!10")
t2f_theme_clear()

# t2f_theme_register accepts custom name
theme <- t2f_theme(name = "internal_name", scolor = "green!10")
expect_message(
  t2f_theme_register(theme, name = "external_name"),
  "'external_name' registered"
)
expect_true("external_name" %in% t2f_list_themes())
t2f_theme_clear()

# registered themes work with t2f_theme_set
jama2 <- t2f_theme(
  name = "jama", scolor = "gray!5", font_size = "small"
)
t2f_theme_register(jama2)
t2f_theme_set("jama")
current <- t2f_theme_get()
expect_equal(current$name, "jama")
expect_equal(current$font_size, "small")
t2f_theme_set(NULL)
t2f_theme_clear()


# --- Theme unregistration ---

# t2f_theme_unregister removes custom theme
theme <- t2f_theme(name = "temp_theme")
t2f_theme_register(theme)
expect_true("temp_theme" %in% t2f_list_themes())
expect_message(t2f_theme_unregister("temp_theme"), "unregistered")
expect_false("temp_theme" %in% t2f_list_themes())

# t2f_theme_unregister handles missing theme
expect_message(
  result <- t2f_theme_unregister("nonexistent"),
  "not found"
)
expect_false(result)


# --- Theme clear ---

# t2f_theme_clear removes all custom themes
t2f_theme_register(t2f_theme(name = "a"))
t2f_theme_register(t2f_theme(name = "b"))
t2f_theme_register(t2f_theme(name = "c"))
expect_message(n <- t2f_theme_clear(), "Cleared 3")
expect_equal(n, 3)
expect_equal(t2f_list_themes(), t2f_list_themes(builtin_only = TRUE))


# --- get_builtin_theme ---

# finds registered custom themes
bmj <- t2f_theme(name = "bmj", scolor = "white", header_bold = TRUE)
t2f_theme_register(bmj)
retrieved <- zztab2fig:::get_builtin_theme("bmj")
expect_inherits(retrieved, "t2f_theme")
expect_equal(retrieved$name, "bmj")
t2f_theme_clear()

# errors for unknown theme
expect_error(
  zztab2fig:::get_builtin_theme("unknown_theme"),
  "Unknown theme"
)


# --- t2f_list_themes with custom ---

t2f_theme_register(t2f_theme(name = "custom_journal"))
all_themes <- t2f_list_themes()
builtin_themes <- t2f_list_themes(builtin_only = TRUE)
expect_true("custom_journal" %in% all_themes)
expect_false("custom_journal" %in% builtin_themes)
t2f_theme_clear()


# --- print.t2f_theme ---

theme <- t2f_theme_nejm()
output <- capture.output(print(theme))
expect_true(any(grepl("nejm", output)))
expect_true(any(grepl("Row shading", output)))
