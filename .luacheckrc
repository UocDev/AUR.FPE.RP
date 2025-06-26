-- luacheck config

-- Include Busted test environment
std = "busted"

-- Ignore specific warnings if needed
ignore = {
  "611", -- trailing whitespace
}

-- Optional: only check .lua files inside these dirs
files = {
  "src",
  "tests",
  "package"
}
